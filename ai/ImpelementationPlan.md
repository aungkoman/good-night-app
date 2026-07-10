# Good Night — Flutter App Implementation Plan

## Overview

**Good Night** is a premium Buddhist Dhamma talk (တရားတော်) audio streaming app for Myanmar users. The core philosophy:

> **"Open the app. Hear the Dhamma. Everything else is secondary."**

The data source is `all_mp3_links.json` — **95 Sayadaw collections, 20,000+ MP3 tracks** — bundled as a local asset. Audio streams from the original URLs. The app starts playing automatically on launch.

---

## Architecture

```
offline-first metadata (local JSON) + streamed audio (MP3 URLs)
```

- **Data Layer**: JSON asset → Dart models → in-memory cache
- **Audio Layer**: `just_audio` streaming from MP3 URLs
- **State Layer**: `provider` for app state (player + data)
- **UI Layer**: Clean screens consuming state, never touching raw JSON

---

## Package Dependencies

| Package | Purpose |
|---|---|
| `just_audio` | Audio playback / streaming |
| `audio_session` | Background audio + system controls |
| `provider` | State management |
| `shared_preferences` | Persist favorites, recently played, last position |
| `google_fonts` | Typography (Nunito / Inter) |
| `rxdart` | Debounced search stream |

---

## Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── extensions/
│       └── string_extensions.dart
├── models/
│   ├── dhamma_track.dart
│   └── sayadaw_collection.dart
├── services/
│   ├── data_service.dart        ← loads & caches JSON
│   ├── audio_service.dart       ← just_audio wrapper
│   └── preferences_service.dart ← SharedPreferences
├── providers/
│   ├── player_provider.dart
│   └── library_provider.dart
├── screens/
│   ├── home/
│   │   └── home_screen.dart     ← Now Playing (primary)
│   ├── library/
│   │   └── library_screen.dart  ← All collections
│   ├── search/
│   │   └── search_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── mini_player.dart
    ├── track_list_tile.dart
    ├── sayadaw_card.dart
    ├── now_playing_artwork.dart
    ├── playback_controls.dart
    ├── sleep_timer_sheet.dart
    └── common/
        ├── app_scaffold.dart
        └── empty_state.dart

assets/
└── data/
    └── dhamma_collection.json   ← copied from ai/all_mp3_links.json
```

---

## Screens

### 1. Home (Now Playing) — Primary Screen
- Full-screen artwork (animated gradient orb, calming dark background)
- Title + Sayadaw name
- Seek bar with elapsed/total time
- Controls: ⏮ 15s · ▶️/⏸ · ⏭ 15s
- Playback speed selector (0.75×, 1×, 1.25×, 1.5×)
- Sleep timer button (15, 30, 45, 60 min)
- Favorite toggle (heart icon)
- Smooth fade-in animation on track change

### 2. Library Screen
- Collection cards by Sayadaw (name + track count)
- Tap → opens track list for that Sayadaw
- Recently played section at top

### 3. Search Screen
- Instant local search (debounced 300ms)
- Searches title + Sayadaw name
- Shows matching tracks with Sayadaw attribution

### 4. Favorites Screen
- Locally persisted favorites (SharedPreferences)
- Beautiful empty state if none

### 5. Settings Screen
- Theme (dark only for now)
- Clear recently played
- Clear favorites
- App version

---

## Navigation

Bottom navigation bar — 5 tabs:
`Home` · `Library` · `Search` · `Favorites` · `Settings`

Persistent **mini player** above the bottom nav when not on Home screen.

---

## Design System

### Color Palette (Dark theme — calming night sky)
- Background: `#0A0E1A` (deep navy)
- Surface: `#12182B`
- Card: `#1A2238`
- Primary accent: `#8B7CF6` (soft violet)
- Secondary: `#C4B5FD`
- Text primary: `#F0F4FF`
- Text secondary: `#8892A4`

### Typography
- Font: **Nunito** (rounded, friendly, calm)
- Headlines: bold, large
- Body: regular weight
- Myanmar text: system font fallback

### Animations
- Rotating artwork orb with glow on play
- Seek bar smooth animation
- Page transitions: fade + slide
- Track list: staggered fade-in
- Mini player: slide-up reveal

---

## Startup Flow

```
main() → load JSON asset → parse 95 collections → cache in DataService
       → select first track of collection[0]
       → start streaming automatically
       → show HomeScreen with Now Playing
```

---

## Proposed Changes

### [NEW] pubspec.yaml — updated dependencies + assets
### [NEW] assets/data/dhamma_collection.json — copied from ai/all_mp3_links.json
### [MODIFY] lib/main.dart — complete rewrite
### [NEW] lib/app.dart
### [NEW] lib/core/theme/app_colors.dart
### [NEW] lib/core/theme/app_text_styles.dart
### [NEW] lib/core/theme/app_theme.dart
### [NEW] lib/core/constants/app_constants.dart
### [NEW] lib/models/dhamma_track.dart
### [NEW] lib/models/sayadaw_collection.dart
### [NEW] lib/services/data_service.dart
### [NEW] lib/services/audio_service.dart
### [NEW] lib/services/preferences_service.dart
### [NEW] lib/providers/player_provider.dart
### [NEW] lib/providers/library_provider.dart
### [NEW] lib/screens/home/home_screen.dart
### [NEW] lib/screens/library/library_screen.dart
### [NEW] lib/screens/search/search_screen.dart
### [NEW] lib/screens/favorites/favorites_screen.dart
### [NEW] lib/screens/settings/settings_screen.dart
### [NEW] lib/widgets/mini_player.dart
### [NEW] lib/widgets/track_list_tile.dart
### [NEW] lib/widgets/sayadaw_card.dart
### [NEW] lib/widgets/now_playing_artwork.dart
### [NEW] lib/widgets/playback_controls.dart
### [NEW] lib/widgets/sleep_timer_sheet.dart
### [NEW] lib/widgets/common/app_scaffold.dart
### [NEW] lib/widgets/common/empty_state.dart

---

## Verification Plan

### Build Verification
```
flutter pub get
flutter analyze
flutter build apk --debug
```

### Manual Verification
- App opens → audio starts automatically within 3 seconds
- Play/pause, seek, skip 15s work
- Speed control works
- Favorites persist across restarts
- Search returns instant results
- Library shows all 95 Sayadaw collections
- Mini player visible when navigating away from Home
- Sleep timer pauses after selected duration

---

> [!IMPORTANT]
> The JSON file is ~7.9 MB. It will be bundled as an asset. On first load it will be parsed once and cached in memory for the entire session — no re-reads.

> [!NOTE]
> `just_audio` requires Android `minSdkVersion 21`. We'll need to update `android/app/build.gradle` if needed.
