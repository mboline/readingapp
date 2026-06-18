# Reading Assistant App – MongoDB Migration

## Overview

The Reading Assistant App has been migrated to use **MongoDB** as its primary data source, with automatic fallback to local JSON if the database is unavailable.

## What Changed

### Architecture
- **Before**: Data loaded from `assets/data/data.json` on app startup
- **After**: App attempts to connect to MongoDB; falls back to local JSON if offline

### New Files
- `lib/services/mongo_service.dart` – MongoDB connection and data fetching service

### Modified Files
- `lib/main.dart` – Updated to use `MongoService` for data initialization

## Getting Started

### Prerequisites
- Flutter 3.11.4 or later
- Dart 3.11.4 or later
- Internet connection for MongoDB (optional—app works offline with local JSON)

### Installation

```bash
flutter pub get
```

### Running the App

**For Web:**
```bash
flutter build web
flutter run -d chrome
```

**For Other Platforms:**
```bash
flutter run
```

## How It Works

1. **App Launch**: `_initData()` calls `MongoService.fetchAllData()`
2. **MongoDB Connection**: Service attempts to connect using the pre-configured URI
3. **Success**: Data is fetched from collections `words` and `phonograms`
4. **Fallback**: If connection fails, app loads from `assets/data/data.json`
5. **Caching**: Data is cached in memory; subsequent requests use cached data

### Console Output

On app startup, you'll see console messages indicating data source:

```
✓ Loaded data from MongoDB (1048 words, X phonograms)
```

Or if offline:

```
✗ MongoDB connection failed: ...
↓ Falling back to local JSON file...
✓ Loaded data from local JSON file (1048 words)
```

## MongoDB Configuration

The MongoDB URI is configured in `lib/services/mongo_service.dart`:

```dart
static const String _mongoUri = 'mongodb+srv://...';
static const String _dbName = 'WordInfo';
```

**Collections expected:**
- `words` – Contains word entries with fields: `_id`, `word`, `decodedInfo`, `imageUrl`, `audio_url`
- `phonograms` – Contains phonogram entries with fields: `_id`, `phonogram`, `samplewords`, etc.

## Adding New Words

### Option 1: Add to MongoDB (Recommended)
Insert documents directly into the MongoDB `words` collection. The app automatically pulls new data on next launch or refresh.

### Option 2: Add to Local JSON
Edit `assets/data/data.json` and add entries to the `words` array. Then rebuild the web app:

```bash
flutter build web
```

## Troubleshooting

### "MongoDB connection failed"
- **Cause**: Network unavailable or MongoDB URI is invalid
- **Solution**: App automatically falls back to local JSON. Check internet connection.

### Data not updating
- **Cause**: Cached data from previous session
- **Solution**: Call `MongoService().refresh()` to force a data reload, or restart the app.

### Web build size increased
- **Cause**: `mongo_dart` package added to build
- **Solution**: This is expected. Verify build succeeds with `flutter build web`.

## Deployment

### To Web Server
```bash
flutter build web
# Deploy the 'build/web' directory to your web host
```

The app will attempt MongoDB connection first; if unavailable, it serves data from the bundled JSON file.

### Environment Variables (Optional)
For sensitive credentials, you can move the MongoDB URI to environment variables:

```dart
// In mongo_service.dart
static const String _mongoUri = String.fromEnvironment('MONGO_URI', 
  defaultValue: 'mongodb+srv://...');
```

Build with:
```bash
flutter build web --dart-define=MONGO_URI='your-uri-here'
```

## Features

✅ Dual-mode data loading (MongoDB + local JSON fallback)
✅ Automatic caching for performance
✅ Error handling and logging
✅ Works offline with local data
✅ No additional configuration required after initial setup

## Future Enhancements

- Add data refresh button in UI
- Implement real-time sync with MongoDB changes
- Add user authentication for personalized word lists
- Cache management (clear cache, refresh on demand)

## Support

For issues or questions, contact info@phonogramuniversity.com
