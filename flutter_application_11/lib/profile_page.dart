import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = 'CarePal User';
  String _avatar = '🙂';
  bool _notificationsEnabled = true;
  bool _loading = true;

  final List<String> _avatars = const ['🙂', '😄', '👩', '🧑', '👨', '🩺'];

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userRef {
    return _firestore.collection('users').doc(_uid);
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await _userRef.get();
      final data = doc.data();

      if (data == null) {
        await _userRef.set({
          'name': _auth.currentUser?.displayName ?? 'CarePal User',
          'avatar': '🙂',
          'notificationsEnabled': true,
          'email': _auth.currentUser?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final refreshedDoc = await _userRef.get();
      final refreshedData = refreshedDoc.data() ?? {};

      setState(() {
        _userName = refreshedData['name']?.toString() ?? 'CarePal User';
        _avatar = refreshedData['avatar']?.toString() ?? '🙂';
        _notificationsEnabled = refreshedData['notificationsEnabled'] ?? true;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateProfileField(Map<String, dynamic> data) async {
    await _userRef.set(data, SetOptions(merge: true));
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF38BDF8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.32),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Edit Name',
                      style: Theme.of(dialogContext).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Update your profile display name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 22),

                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.95),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFF14B8A6),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF14B8A6),
                                    Color(0xFF0EA5E9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF14B8A6,
                                    ).withOpacity(0.30),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  final newName = controller.text.trim();
                                  if (newName.isEmpty) return;

                                  await _updateProfileField({'name': newName});
                                  if (!mounted) return;

                                  setState(() => _userName = newName);
                                  Navigator.pop(dialogContext);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeAvatar() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 35,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF38BDF8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.32),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Choose Avatar',
                      style: Theme.of(dialogContext).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Select your profile avatar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _avatars.map((avatar) {
                        final isSelected = _avatar == avatar;

                        return InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () async {
                            await _updateProfileField({'avatar': avatar});

                            if (!mounted) return;

                            setState(() => _avatar = avatar);
                            Navigator.pop(dialogContext);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF14B8A6),
                                        Color(0xFF38BDF8),
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.white.withOpacity(0.95),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white.withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF14B8A6,
                                        ).withOpacity(0.28),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    await _updateProfileField({'notificationsEnabled': value});
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _itemTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassCard(
        padding: const EdgeInsets.all(14),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: danger
                  ? Colors.redAccent.withOpacity(0.12)
                  : const Color(0xFF14B8A6).withOpacity(0.12),
            ),
            child: Icon(
              icon,
              color: danger ? Colors.redAccent : const Color(0xFF14B8A6),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: danger
                  ? Colors.redAccent
                  : isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = _auth.currentUser?.email ?? '';

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF020617),
                    Color(0xFF0F172A),
                    Color(0xFF134E4A),
                  ]
                : const [
                    Color(0xFFDFF7FF),
                    Color(0xFFE8FFF4),
                    Color(0xFFFFF7ED),
                  ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: _GlowCircle(
                size: 210,
                color: isDark
                    ? const Color(0xFF14B8A6).withOpacity(0.22)
                    : const Color(0xFF38BDF8).withOpacity(0.35),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -70,
              child: _GlowCircle(
                size: 230,
                color: isDark
                    ? const Color(0xFF0EA5E9).withOpacity(0.18)
                    : const Color(0xFF2DD4BF).withOpacity(0.35),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        _CircleButton(
                          icon: isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          onTap: MyApp.toggleTheme,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _GlassCard(
                            child: Column(
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF14B8A6),
                                        Color(0xFF38BDF8),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF14B8A6,
                                        ).withOpacity(0.35),
                                        blurRadius: 26,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _avatar,
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _userName,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  email,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          _itemTile(
                            context: context,
                            icon: Icons.edit_outlined,
                            title: 'Edit Name',
                            onTap: _editName,
                          ),

                          _itemTile(
                            context: context,
                            icon: Icons.face_retouching_natural_outlined,
                            title: 'Change Avatar',
                            onTap: _changeAvatar,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _notificationsEnabled,
                                onChanged: _toggleNotifications,
                                secondary: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFF14B8A6,
                                    ).withOpacity(0.12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Color(0xFF14B8A6),
                                  ),
                                ),
                                title: const Text(
                                  'Notifications',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFF14B8A6,
                                    ).withOpacity(0.12),
                                  ),
                                  child: Icon(
                                    isDark
                                        ? Icons.dark_mode_rounded
                                        : Icons.light_mode_rounded,
                                    color: const Color(0xFF14B8A6),
                                  ),
                                ),
                                title: const Text(
                                  'Dark Mode',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                trailing: Switch(
                                  value: isDark,
                                  onChanged: (_) => MyApp.toggleTheme(),
                                ),
                              ),
                            ),
                          ),

                          _itemTile(
                            context: context,
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            onTap: _logout,
                            danger: true,
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.75),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(height: 46, width: 46, child: Icon(icon)),
      ),
    );
  }
}
