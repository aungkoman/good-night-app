package mm.com.software100.goodnight.goodnight

import io.flutter.plugin.common.MethodChannel

/**
 * Static holder for the Flutter [MethodChannel] that connects
 * [GoodNightMediaService] (native foreground service) back to the Dart side.
 *
 * Set by [MainActivity.configureFlutterEngine]; cleared in [MainActivity.onDestroy].
 * The service calls [channel]?.invokeMethod(…) on the main thread whenever
 * a notification button is tapped.
 */
object MediaChannelHolder {
    @Volatile
    var channel: MethodChannel? = null
}
