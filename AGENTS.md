# AGENTS.md

## Project Structure

- `lib/main.dart` is the Flutter entry point. It initializes Firebase, builds `MyApp`, and routes users through `AuthWrapper`.
- `lib/` contains the Flutter application code:
  - `main.dart`: app bootstrap, theme mode notifier, auth gate, initial login/signup choice page.
  - `main_screen.dart`: main authenticated shell with bottom navigation for Home, Alerts, and Profile.
  - `home_page.dart`: profile/person dashboard, add/edit/delete people, opens chatbot and per-person dashboard.
  - `smart_dashboard.dart`: baby/elderly dashboard and feature navigation.
  - `baby_features_pages.dart`: baby emergency, feeding/sleep, and growth screens.
  - `old_features_pages.dart`: elderly learning, monitoring, alerts, and consultation screens.
  - `login_page.dart` / `signup_page.dart`: Firebase email/password auth flows.
  - `profile_page.dart`: user profile, avatar/name preferences, notification toggle, logout.
  - `chat_bot_page.dart` / `chatbot_service.dart`: chatbot UI and HTTP client.
  - `recorder.dart` / `fake_ai_service.dart`: demo baby sound recorder and fake AI result generator.
  - `storage_service.dart` / `alerts_service.dart`: Firestore access helpers.
  - `app_theme.dart`: app colors, themes, and shared shell/card widgets.
  - `firebase_options.dart`: FlutterFire-generated Firebase config for Android and web.
- `lib/Back_end/` contains a local Python FastAPI chatbot backend using TinyLlama.
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, and `macos/` are Flutter platform folders.
- `test/widget_test.dart` currently contains the default counter test and does not match this app.
- `pubspec.yaml` defines Flutter/Dart dependencies and assets.
- `analysis_options.yaml` enables `flutter_lints`.

## Flutter Commands

- Install dependencies: `flutter pub get`
- Analyze code: `flutter analyze`
- Run the app: `flutter run`
- Run on Chrome: `flutter run -d chrome`
- Run on Android emulator: `flutter run -d emulator`
- Build Android APK: `flutter build apk`
- Build web: `flutter build web`
- Check outdated packages: `flutter pub outdated`

## Backend Commands

Run these from `lib/Back_end`:

- Create a virtual environment: `python -m venv .venv`
- Activate on Windows PowerShell: `.venv\Scripts\Activate.ps1`
- Install backend dependencies: `pip install -r requirements.txt`
- Start the API: `uvicorn main:app --host 0.0.0.0 --port 8000`
- Health check endpoint: `GET http://localhost:8000/`
- Chat endpoint: `POST http://localhost:8000/chat` with JSON body `{"message":"..."}`

The Flutter chatbot client currently targets `http://10.0.2.2:8000`, which is suitable for Android emulator access to the host machine. Use a platform-aware base URL before relying on this outside Android emulator development.

## Testing Commands

- Run all Flutter tests: `flutter test`
- Run a single test file: `flutter test test/widget_test.dart`
- Run analyzer before commits or handoff: `flutter analyze`

Only run tests when the user explicitly asks for them. The current `test/widget_test.dart` is a scaffold counter test and should be replaced before it is treated as meaningful coverage.

## Coding Conventions

- Use Dart/Flutter idioms and keep widgets small enough to read.
- Prefer shared widgets from `app_theme.dart` or extracted local widgets over copying `_GlassCard`, `_GlowCircle`, and `_CircleButton` into more files.
- Keep Firebase access in service classes where practical instead of embedding database logic directly in UI widgets.
- Use `context.mounted` or `mounted` correctly after `await` before using a `BuildContext`.
- Avoid broad `catch (_)` blocks unless the UI intentionally ignores the error; prefer surfacing useful error states.
- Keep user-visible strings valid UTF-8. Several current strings show mojibake and should be fixed carefully.
- Replace deprecated `withOpacity` calls with `withValues(alpha: ...)` when modernizing UI code.
- Use explicit dependency constraints in `pubspec.yaml`.
- Do not hardcode production secrets, hosts, or environment-specific URLs in widgets or services.

## Rules For Making Changes

- Do not modify app code until the user asks for implementation.
- Do not run `flutter test` unless explicitly requested.
- Before changing code, inspect the relevant files and existing patterns.
- Keep changes scoped to the requested behavior.
- Do not revert user changes or generated platform files unless explicitly requested.
- After code changes, run `flutter analyze` unless the user says not to.
- For Firebase changes, update both app code and documented Firestore collection expectations.
- For backend changes, document any new Python dependency in `lib/Back_end/requirements.txt`.
- For navigation changes, update route constants and verify the full path from auth gate to destination screen.
- For platform-specific behavior, document which targets are supported and which are not.
