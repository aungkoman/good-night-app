package mm.com.software100.goodnight.goodnight

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity — standard [FlutterActivity] with no custom engine management.
 *
 * Sets up the bidirectional [MethodChannel] "goodnight/media":
 *
 *   Flutter → Native:
 *     "updateNotification" { title, artist, isPlaying } → starts / updates [GoodNightMediaService]
 *     "stopNotification"                                → stops [GoodNightMediaService]
 *
 *   Native → Flutter (via [MediaChannelHolder]):
 *     "play" | "pause" | "next" | "previous"           → [GoodNightMediaService.notifyFlutter]
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val MEDIA_CHANNEL = "goodnight/media"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MEDIA_CHANNEL
        )

        // Expose the channel to GoodNightMediaService so it can call back into Flutter
        MediaChannelHolder.channel = channel

        channel.setMethodCallHandler { call, result ->
            @Suppress("UNCHECKED_CAST")
            when (call.method) {
                "updateNotification" -> {
                    val args      = call.arguments as Map<String, Any>
                    val title     = args["title"]     as? String  ?: ""
                    val artist    = args["artist"]    as? String  ?: ""
                    val isPlaying = args["isPlaying"] as? Boolean ?: false
                    startMediaService(title, artist, isPlaying)
                    result.success(null)
                }
                "stopNotification" -> {
                    stopService(Intent(this, GoodNightMediaService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startMediaService(title: String, artist: String, isPlaying: Boolean) {
        val intent = Intent(this, GoodNightMediaService::class.java).apply {
            putExtra(GoodNightMediaService.EXTRA_TITLE,      title)
            putExtra(GoodNightMediaService.EXTRA_ARTIST,     artist)
            putExtra(GoodNightMediaService.EXTRA_IS_PLAYING, isPlaying)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    override fun onDestroy() {
        MediaChannelHolder.channel = null
        super.onDestroy()
    }
}
