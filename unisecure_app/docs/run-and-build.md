# Run and build

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --dart-define=API_BASE_URL=https://api.example.test/api/v1
```

iOS builds require the local Xcode toolchain and signing configuration. No production credentials, tokens, signing keys or Firebase files belong in this repository.
