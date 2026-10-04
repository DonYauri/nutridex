# NutriDex

Run:
    flutter create .            # generates android/ios folders if missing
    flutter pub get
    flutter run --dart-define=GEMINI_API_KEY=your_key

Optional: --dart-define=GEMINI_MODEL=<model name> to change the Gemini model.

iOS: add NSCameraUsageDescription and NSPhotoLibraryUsageDescription to Info.plist.
Android: minSdkVersion 21+ (set in android/app/build.gradle).
