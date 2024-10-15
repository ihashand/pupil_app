# puppil_app

A social app for pets

## Important commands

- **Update database**:
  flutter pub run build_runner build

- **While the previous update doesn't work**:
  flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs

- **Real device release version for testing**:
  flutter run --release

- **Cocoapod problem**:
  https://stackoverflow.com/questions/64443888/flutter-cocoapodss-specs-repository-is-too-out-of-date-to-satisfy-dependencies

  flutter clean
  Delete /ios/Pods
  Delete /ios/Podfile.lock
  flutter pub get
  from inside ios folder: pod install
  flutter run

- **Free up port 8080**:
  sudo lsof -i :8080
  sudo kill -9 51683

- **Firebase emulator**:
  firebase emulators:start

- **Tips for build issues**:
  - If you encounter issues on simulators or physical devices, try deleting the app and running a fresh build. This can often solve unexpected problems.
  - Additionally, remember to clean the build folders using: flutter clean
  - This can help fix issues, such as errors with Apple Maps on simulators.
