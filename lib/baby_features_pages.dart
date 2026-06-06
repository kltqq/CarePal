import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alerts_service.dart';
import 'fake_ai_service.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = ['Fever', 'Choking', 'Crying Nonstop', 'Fall'];

    return _ModernPageShell(
      title: 'Emergency Guide',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final title = items[index];

          return _AnimatedItem(
            index: index,
            child: _GlassCard(
              padding: const EdgeInsets.all(14),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const _GradientIcon(
                  icon: Icons.warning_amber_rounded,
                  danger: true,
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text('Tap to view a quick response note'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () async {
                  await AlertsService.addAlert(
                    'Emergency guide opened: $title',
                  );
                  if (!context.mounted) return;

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      title: Text(title),
                      content: Text(FakeAIService.emergencyTip(title)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeedingSleepPage extends StatefulWidget {
  const FeedingSleepPage({super.key});

  @override
  State<FeedingSleepPage> createState() => _FeedingSleepPageState();
}

class _FeedingSleepPageState extends State<FeedingSleepPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _recordsRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('feeding_sleep_records');
  }

  Future<void> _addRecord() async {
    final timeController = TextEditingController();
    final feedController = TextEditingController();
    final sleepController = TextEditingController();

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
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
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _GradientIcon(icon: Icons.add_rounded),
                      const SizedBox(height: 18),
                      Text(
                        'Add Daily Record',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: timeController,
                        decoration: _inputDecoration(
                          context,
                          'Time',
                          Icons.schedule,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: feedController,
                        decoration: _inputDecoration(
                          context,
                          'Feeding Amount',
                          Icons.local_drink_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: sleepController,
                        decoration: _inputDecoration(
                          context,
                          'Sleep Duration',
                          Icons.bedtime_outlined,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (timeController.text.trim().isEmpty ||
                                    feedController.text.trim().isEmpty ||
                                    sleepController.text.trim().isEmpty) {
                                  return;
                                }

                                await _recordsRef.add({
                                  'time': timeController.text.trim(),
                                  'feed': feedController.text.trim(),
                                  'sleep': sleepController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                await AlertsService.addAlert(
                                  'New feeding and sleep record added.',
                                );

                                if (!mounted || !dialogContext.mounted) return;
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _parseSleepHours(String sleepValue) {
    final cleaned = sleepValue.replaceAll('h', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  Widget _summaryCard(String title, String value, IconData icon, int index) {
    return Expanded(
      child: _AnimatedItem(
        index: index,
        child: _GlassCard(
          child: Column(
            children: [
              _GradientIcon(icon: icon),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ModernPageShell(
      title: 'Feeding & Sleep',
      floatingActionButton: _GradientFab(onTap: _addRecord),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _recordsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final totalFeeds = docs.length;
          final totalSleep = docs.fold<double>(0, (sum, doc) {
            final data = doc.data();
            return sum + _parseSleepHours(data['sleep']?.toString() ?? '');
          });

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  _summaryCard(
                    'Feeds',
                    '$totalFeeds',
                    Icons.baby_changing_station,
                    0,
                  ),
                  const SizedBox(width: 12),
                  _summaryCard(
                    'Sleep',
                    '${totalSleep.toStringAsFixed(1)} h',
                    Icons.bedtime_outlined,
                    1,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                const _GlassCard(
                  child: Text(
                    'No records yet. Use the + button to add the first record.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ...docs.map((doc) {
                final item = doc.data();
                return _AnimatedItem(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const _GradientIcon(icon: Icons.schedule),
                        title: Text(
                          item['time']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          'Feeding: ${item['feed'] ?? ''} • Sleep: ${item['sleep'] ?? ''}',
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class GrowthPage extends StatefulWidget {
  const GrowthPage({super.key});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _aiComment = 'Enter weight and height to get a demo AI note.';

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _growthRef {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('growth_records');
  }

  Future<void> _analyzeAndSave() async {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0;

    final comment = FakeAIService.generateGrowthComment(weight, height);
    setState(() => _aiComment = comment);

    await _growthRef.add({
      'weight': weight,
      'height': height,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await AlertsService.addAlert('Growth tracker data updated.');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ModernPageShell(
      title: 'Growth Tracker',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _AnimatedItem(
            index: 0,
            child: _GlassCard(
              child: Column(
                children: [
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      context,
                      'Weight (kg)',
                      Icons.monitor_weight_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      context,
                      'Height (cm)',
                      Icons.height_rounded,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _analyzeAndSave,
                      child: const Text('Analyze'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _AnimatedItem(
            index: 1,
            child: _GlassCard(
              child: Text(
                _aiComment,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _AnimatedItem(
            index: 2,
            child: _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Growth Notes',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text('• Weight can be tracked weekly.'),
                  Text('• Height can be checked every 2-4 weeks.'),
                  Text('• Consistent records make future charts more useful.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _growthRef
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }

              final docs = snapshot.data!.docs;

              return _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saved Growth Records',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...docs.map((doc) {
                      final data = doc.data();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Weight: ${data['weight']} kg | Height: ${data['height']} cm\n${data['comment']}',
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(
  BuildContext context,
  String label,
  IconData icon,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.95),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
  );
}

class _ModernPageShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const _ModernPageShell({
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
                        _CircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(child: child),
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

class _AnimatedItem extends StatelessWidget {
  final Widget child;
  final int index;

  const _AnimatedItem({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final bool danger;

  const _GradientIcon({required this.icon, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final colors = danger
        ? const [Color(0xFFFF6B6B), Color(0xFFFF8E53)]
        : const [Color(0xFF14B8A6), Color(0xFF38BDF8)];

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;

  const _GradientFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: const Color(0xFF14B8A6),
      child: const Icon(Icons.add_rounded, color: Colors.white),
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
