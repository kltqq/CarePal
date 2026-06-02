import 'dart:ui';

import 'package:flutter/material.dart';

import 'alerts_service.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  Widget _animatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
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

  @override
  Widget build(BuildContext context) {
    const topics = [
      {
        'title': 'Healthy Meals',
        'subtitle': 'Simple food balance tips for older adults',
        'icon': Icons.restaurant_menu,
      },
      {
        'title': 'Medicine Routine',
        'subtitle': 'Keep medicine times organized',
        'icon': Icons.medication_outlined,
      },
      {
        'title': 'Daily Movement',
        'subtitle': 'Light walking and stretching reminders',
        'icon': Icons.directions_walk,
      },
    ];

    return _ModernPageShell(
      title: 'Learning Module',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = topics[index];

          return _animatedItem(
            _ModernListCard(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
            ),
            index,
          );
        },
      ),
    );
  }
}

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  Widget _animatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
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

  Widget _infoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    int index,
  ) {
    return Expanded(
      child: _animatedItem(
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _GradientIcon(icon: icon),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
        index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ModernPageShell(
      title: 'Health Monitoring',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              _infoCard(
                context,
                'Heart Rate',
                '74 bpm',
                Icons.favorite_border,
                0,
              ),
              const SizedBox(width: 12),
              _infoCard(context, 'Oxygen', '98%', Icons.air, 1),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoCard(
                context,
                'Pressure',
                '120/80',
                Icons.monitor_heart_outlined,
                2,
              ),
              const SizedBox(width: 12),
              _infoCard(
                context,
                'Temperature',
                '36.8°C',
                Icons.thermostat_outlined,
                3,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _animatedItem(
            const _GlassCard(
              child: Text(
                'This page shows a clean frontend summary for vital signs without connecting to real devices.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            4,
          ),
        ],
      ),
    );
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  Widget _animatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
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

  @override
  Widget build(BuildContext context) {
    const alerts = [
      'Medicine reminder at 8:00 PM',
      'Hydration reminder',
      'Light walk recommended today',
    ];

    return _ModernPageShell(
      title: 'Smart Alerts',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alert = alerts[index];

          return _animatedItem(
            _GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const _GradientIcon(
                    icon: Icons.notifications_active_outlined,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      alert,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await AlertsService.addAlert('Alert marked as checked.');
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as checked')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                ],
              ),
            ),
            index,
          );
        },
      ),
    );
  }
}

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  Widget _animatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
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

  @override
  Widget build(BuildContext context) {
    const doctors = [
      'Dr. Ahmad - General Care',
      'Dr. Lina - Nutrition',
      'Dr. Omar - Follow-up Consultation',
    ];

    return _ModernPageShell(
      title: 'Remote Consultation',
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doctor = doctors[index];

          return _animatedItem(
            _GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const _GradientIcon(icon: Icons.person_outline_rounded),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Frontend appointment preview only',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking request sent to $doctor'),
                            ),
                          );
                        },
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            index,
          );
        },
      ),
    );
  }
}

class _ModernPageShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _ModernPageShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        _CircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
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

class _ModernListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ModernListCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _GradientIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;

  const _GradientIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF38BDF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
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
