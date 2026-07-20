package mm.com.software100.goodnight.goodnight

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.core.app.NotificationCompat
import androidx.media.app.NotificationCompat.MediaStyle

/**
 * Foreground service that owns the [MediaSessionCompat] and the media-style
 * notification shown in the notification shade and lock screen.
 *
 * ── Data flow ──────────────────────────────────────────────────────────────────
 *
 *  Flutter → [MethodChannel "goodnight/media"] → [MainActivity]
 *          → startForegroundService(Intent with EXTRA_*) → [onStartCommand]
 *          → updates MediaSession + rebuilds notification
 *
 *  Notification button tap → [onStartCommand] ACTION_*
 *          → [MediaChannelHolder.channel].invokeMethod(command)
 *          → Flutter [MediaNotificationService] → [PlayerProvider]
 *
 *  Hardware media key / Bluetooth → [MediaSessionCompat.Callback]
 *          → same path as above
 */
class GoodNightMediaService : Service() {

    // ── Constants ───────────────────────────────────────────────────────────────

    companion object {
        const val CHANNEL_ID   = "goodnight_audio_channel"
        const val NOTIFICATION_ID = 1001

        // Intent actions — triggered by notification button PendingIntents
        const val ACTION_PLAY     = "goodnight.ACTION_PLAY"
        const val ACTION_PAUSE    = "goodnight.ACTION_PAUSE"
        const val ACTION_NEXT     = "goodnight.ACTION_NEXT"
        const val ACTION_PREVIOUS = "goodnight.ACTION_PREVIOUS"

        // Intent extras for metadata updates from Flutter
        const val EXTRA_TITLE      = "title"
        const val EXTRA_ARTIST     = "artist"
        const val EXTRA_IS_PLAYING = "isPlaying"
    }

    // ── State ───────────────────────────────────────────────────────────────────

    private lateinit var mediaSession: MediaSessionCompat
    private lateinit var notificationManager: NotificationManager
    private val mainHandler = Handler(Looper.getMainLooper())

    private var currentTitle  = "Good Night"
    private var currentArtist = "Dhamma Talks"
    private var isPlaying     = false

    // ── Lifecycle ───────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        setupMediaSession()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            // Notification button taps → relay command to Flutter
            ACTION_PLAY     -> notifyFlutter("play")
            ACTION_PAUSE    -> notifyFlutter("pause")
            ACTION_NEXT     -> notifyFlutter("next")
            ACTION_PREVIOUS -> notifyFlutter("previous")
            else -> {
                // Metadata update from Flutter (normal update path)
                intent?.getStringExtra(EXTRA_TITLE)?.let  { currentTitle  = it }
                intent?.getStringExtra(EXTRA_ARTIST)?.let { currentArtist = it }
                isPlaying = intent?.getBooleanExtra(EXTRA_IS_PLAYING, isPlaying) ?: isPlaying
                pushToForeground()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        mediaSession.isActive = false
        mediaSession.release()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }

    // ── Setup ────────────────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Good Night Audio",
                NotificationManager.IMPORTANCE_LOW           // silent; no heads-up popup
            ).apply {
                description = "Background Buddhist Dhamma audio playback"
                setShowBadge(false)
                setSound(null, null)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun setupMediaSession() {
        mediaSession = MediaSessionCompat(this, "GoodNightSession").apply {
            setFlags(
                MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS or
                MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
            )
            // Bluetooth / headset hardware buttons → same Flutter callbacks
            setCallback(object : MediaSessionCompat.Callback() {
                override fun onPlay()           = notifyFlutter("play")
                override fun onPause()          = notifyFlutter("pause")
                override fun onSkipToNext()     = notifyFlutter("next")
                override fun onSkipToPrevious() = notifyFlutter("previous")
            })
            isActive = true
        }
    }

    // ── Notification ─────────────────────────────────────────────────────────────

    private fun pushToForeground() {
        syncSessionState()
        startForeground(NOTIFICATION_ID, buildNotification())
    }

    /**
     * Sync MediaSessionCompat metadata + playback state so the OS
     * lock-screen player and Android Auto show correct information.
     */
    private fun syncSessionState() {
        mediaSession.setMetadata(
            MediaMetadataCompat.Builder()
                .putString(MediaMetadataCompat.METADATA_KEY_TITLE,  currentTitle)
                .putString(MediaMetadataCompat.METADATA_KEY_ARTIST, currentArtist)
                .build()
        )
        mediaSession.setPlaybackState(
            PlaybackStateCompat.Builder()
                .setActions(
                    PlaybackStateCompat.ACTION_PLAY            or
                    PlaybackStateCompat.ACTION_PAUSE           or
                    PlaybackStateCompat.ACTION_PLAY_PAUSE      or
                    PlaybackStateCompat.ACTION_SKIP_TO_NEXT    or
                    PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS
                )
                .setState(
                    if (isPlaying) PlaybackStateCompat.STATE_PLAYING
                    else           PlaybackStateCompat.STATE_PAUSED,
                    PlaybackStateCompat.PLAYBACK_POSITION_UNKNOWN,
                    1.0f
                )
                .build()
        )
    }

    private fun buildNotification(): Notification {
        // Tapping the notification body → bring MainActivity to foreground (no restart)
        val contentIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Decode the full-colour launcher icon as the large (visible) notification icon
        val appIcon = BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)  // monochrome moon for status bar
            .setLargeIcon(appIcon)                     // full-colour app icon in notification card
            .setContentTitle(currentTitle)
            .setContentText(currentArtist)
            .setContentIntent(contentIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)   // show on lock screen
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(isPlaying)                                 // non-dismissible while playing
            .setSilent(true)
            // ── Action buttons ────────────────────────────────────────────────
            .addAction(                                            // 0 — Previous
                NotificationCompat.Action(
                    R.drawable.ic_skip_previous, "Previous",
                    serviceIntent(ACTION_PREVIOUS, requestCode = 1)
                )
            )
            .addAction(                                            // 1 — Play / Pause
                NotificationCompat.Action(
                    if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play,
                    if (isPlaying) "Pause" else "Play",
                    serviceIntent(if (isPlaying) ACTION_PAUSE else ACTION_PLAY, requestCode = 2)
                )
            )
            .addAction(                                            // 2 — Next
                NotificationCompat.Action(
                    R.drawable.ic_skip_next, "Next",
                    serviceIntent(ACTION_NEXT, requestCode = 3)
                )
            )
            .setStyle(
                MediaStyle()
                    .setMediaSession(mediaSession.sessionToken)
                    .setShowActionsInCompactView(0, 1, 2)          // show all 3 in compact view
            )
            .build()
    }

    /** Build a [PendingIntent] that fires [GoodNightMediaService.onStartCommand] with [action]. */
    private fun serviceIntent(action: String, requestCode: Int): PendingIntent =
        PendingIntent.getService(
            this, requestCode,
            Intent(this, GoodNightMediaService::class.java).apply { this.action = action },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

    // ── Flutter communication ────────────────────────────────────────────────────

    /**
     * Invoke a method on the Flutter side (e.g. "play", "pause", "next", "previous").
     * Must run on the main thread — Flutter channels are not thread-safe.
     */
    private fun notifyFlutter(command: String) {
        mainHandler.post {
            MediaChannelHolder.channel?.invokeMethod(command, null)
        }
    }
}
