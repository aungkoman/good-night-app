Implement a robust background audio player notification in Android using Kotlin/Java. The implementation should adhere to modern Android guidelines (API 33+) and include the following features:

1. **MediaStyle Notification:** Use NotificationCompat.MediaStyle along with a MediaSessionCompat token to display standard media controls seamlessly on the lock screen and notification shade.
2. **Action Buttons:** Include fully functional action buttons for:
   - Play / Pause (toggling dynamically based on the current playback state)
   - Skip to Next
   - Skip to Previous
3. **PendingIntents:** 
   - Each notification action must trigger a corresponding MediaButtonReceiver or a custom BroadcastReceiver to handle playback events cleanly.
   - Tapping the main body of the notification must bring the app's main Activity back to the foreground without restarting it (using FLAG_UPDATE_CURRENT or FLAG_IMMUTABLE where applicable).
4. **Metadata & Session State:** Display current track details (title, artist, album art) and properly update playback states (isPlaying, position) using MediaSessionCompat.Callback.
5. **Foreground Service:** Ensure the notification is bound to a foreground service so the OS does not kill the audio playback process when the app goes into the background.