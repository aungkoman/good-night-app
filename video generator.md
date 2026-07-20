## Video Generator Flutter App Architecture & Implementation Plan

Building a background video generation app in Flutter—especially one that stitches audio, dynamic images, and animated text overlays into standard aspect ratios ($16:9$ or $9:16$)—requires a reliable architecture. Because heavy video rendering can block the main isolate, processing must happen in a native background service or worker thread.

---

### Core Workflow & Architecture

```
[ User Taps "Generate" ] 
       │
       ▼
[ Isolate / Background Task ]
  ├── 1. Fetch & Cache Assets (Audio + Random Buddha Image via URLs)
  ├── 2. Initialize Video Compositing Engine (FFmpeg / Native Platform Channel)
  ├── 3. Apply Text Overlay & Dynamic Animations (Zoom/Pan + Subtitles)
  └── 4. Render & Export MP4 File to App Cache
       │
       ▼
[ Local Notification Triggered ] ──> [ User Plays / Exports to Gallery ]

```

---

### 1. Key Flutter Packages

* **`flutter_local_notifications`**: To alert the user when background rendering finishes.
* **`path_provider`**: To locate safe directories for caching downloaded audio/images and saving the final output.
* **`video_player` / `chewie**`: For in-app preview and playback of the generated video.
* **`gal`**: A modern package to save media directly to the device's gallery (TikTok, Instagram, and YouTube ready).
* **`ffmpeg_kit_flutter_full_gpl`** (or a custom platform channel): The engine that powers programmatic video composition, image scaling, text drawing, and audio mixing in the background.

---

### 2. State & Data Model Structure

Define a clean data model to handle the generation payload passed to your background worker:

```dart
class VideoJobConfig {
  final String audioUrl;
  final List<String> imageUrls;
  final String dhammaText;
  final String aspectRatio; // "16:9" or "9:16"
  
  VideoJobConfig({
    required this.audioUrl,
    required this.imageUrls,
    required this.dhammaText,
    required this.aspectRatio,
  });
}

```

---

### 3. Background Video Generation Engine (FFmpeg Core Command)

To create a live-event feel with animated images and text overlays, you can script an FFmpeg command. For a **9:16 vertical video** (ideal for TikTok/Reels/Shorts, $1080 \times 1920$) with a subtle zoom animation (`scale` filter) and text overlay:

```dart
Future<void> generateDhammaVideo(VideoJobConfig config, String outputPath) async {
  // 1. Resolve dimensions based on ratio selection
  int width = config.aspectRatio == "9:16" ? 1080 : 1920;
  int height = config.aspectRatio == "9:16" ? 1920 : 1080;

  // 2. Construct FFmpeg filter complex:
  // - Scales and crops the random Buddha image to fit target resolution
  // - Applies a slow zoom effect (zoompan) for "live event" motion
  // - Overlays the Dhamma text cleanly
  String filterComplex = 
      "[0:v]scale=$width:$height:force_original_aspect_ratio=decrease," +
      "pad=$width:$height:(ow-iw)/2:(oh-ih)/2,format=yuv420p[v]";

  // Example FFmpeg execution string (adapt paths accordingly)
  String command = 
      "-y -loop 1 -i input_image.jpg -i input_audio.mp3 " +
      "-filter_complex \"$filterComplex\" " +
      "-map \"[v]\" -map 1:a " +
      "-c:v libx264 -tune stillimage -c:a aac -b:a 192k " +
      "-shortest $outputPath";

  // Execute via FFmpegKit
  // await FFmpegKit.executeAsync(command, (session) async { ... });
}

```

---

### 4. Implementation Steps

#### Step 1: Asset Preparation & Random Selection

When the user triggers generation, randomly select a Buddha image URL from your provided list, download both the image and the audio file into temporary local storage (`getApplicationDocumentsDirectory()`).

#### Step 2: Background Task Handling

Offload the rendering process using a background isolate or a foreground service plugin (`flutter_background_service`) so that if the user minimizes the app, the video rendering process continues uninterrupted.

#### Step 3: Notification & Gallery Export

Once `FFmpegKit` returns a successful session code:

1. Fire a local notification: *"Your Dhamma video is ready to view!"*
2. Save the resulting file path into your app's state.
3. Allow the user to preview it immediately using `video_player`, and give them a prominent **"Export to Gallery"** button utilizing the `Gal.putVideo()` method.


Yes, **FFmpeg** binaries or pre-compiled libraries are bundled directly inside your app package through the `ffmpeg_kit_flutter` package.

Here is how it works under the hood:

* **No external user downloads required:** Your users do not need to manually download FFmpeg or any command-line tools. Everything needed to process the video runs locally on their device hardware inside your app sandbox.
* **App Bundle Size Impact:** Because FFmpeg contains comprehensive multimedia codecs, it will add to your final app binary size (APK/AAB for Android, IPA for iOS).
* **Choosing the Right Package Variant:** `ffmpeg_kit_flutter` comes in different package builds (like `min`, `full`, `video`, etc.). To handle standard video encoding, image scaling, and audio mixing out of the box, you will typically use the **`full`** or **`video`** package variant in your `pubspec.yaml`:

```yaml
dependencies:
  ffmpeg_kit_flutter_full_gpl: ^6.0.2 # or the latest stable version

```
