import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'main_screen.dart';
import 'recorder.dart';
import 'signup_page.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);
const String _themePreferenceKey = 'theme_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _loadSavedThemeMode();
  runApp(const MyApp());
}

Future<void> _loadSavedThemeMode() async {
  final preferences = await SharedPreferences.getInstance();
  final savedMode = preferences.getString(_themePreferenceKey);
  appThemeMode.value = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
}

Future<void> _saveThemeMode(ThemeMode mode) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString(
    _themePreferenceKey,
    mode == ThemeMode.dark ? 'dark' : 'light',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static void toggleTheme() {
    final nextMode = appThemeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    appThemeMode.value = nextMode;
    _saveThemeMode(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CarePal',
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AuthWrapper(),
          routes: {
            LoginPage.routeName: (_) => const LoginPage(),
            SignupPage.routeName: (_) => const SignupPage(),
            MainScreen.routeName: (_) => const MainScreen(),
            RecorderPage.routeName: (_) => const RecorderPage(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();
        }

        return const AuthChoicePage();
      },
    );
  }
}

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF101828), const Color(0xFF1D2939)]
                    : [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)],
              ),
            ),
          ),

          /// Top circle
          Positioned(
            top: -80,
            right: -70,
            child: _GlowCircle(
              size: 210,
              color: isDark
                  ? const Color(0xFF14B8A6).withValues(alpha: 0.22)
                  : const Color(0xFF38BDF8).withValues(alpha: 0.35),
            ),
          ),

          /// Bottom circle
          Positioned(
            bottom: -90,
            left: -70,
            child: _GlowCircle(
              size: 230,
              color: isDark
                  ? const Color(0xFF0EA5E9).withValues(alpha: 0.18)
                  : const Color(0xFF2DD4BF).withValues(alpha: 0.35),
            ),
          ),

          /// Main UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        'CarePal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: MyApp.toggleTheme,
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 105,
                          width: 105,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.health_and_safety_rounded,
                            size: 58,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Welcome to CarePal',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          'Your smart companion for babies and elderly care.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
                              ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, LoginPage.routeName);
                            },
                            icon: const Icon(Icons.login_rounded),
                            label: const Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                SignupPage.routeName,
                              );
                            },
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: const Text(
                              'Create Account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'Care made simple',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative circle.
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
