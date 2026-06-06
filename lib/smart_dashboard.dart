import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'recorder.dart';
import 'baby_features_pages.dart';
import 'old_features_pages.dart';

class SmartDashboard extends StatelessWidget {
  final String personId;
  final Map<String, dynamic> data;

  const SmartDashboard({super.key, required this.personId, required this.data});

  bool get isBaby => data['type'] == 'baby';

  int _calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - birth.year;

      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }

      return age;
    } catch (_) {
      return 0;
    }
  }

  Widget _animatedItem({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildChart({
    required String title,
    required List<double> values,
    required BuildContext context,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _animatedItem(
      index: index,
      child: _GlassCard(
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  minY: values.reduce((a, b) => a < b ? a : b) - 2,
                  maxY: values.reduce((a, b) => a > b ? a : b) + 2,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 4,
                      color: const Color(0xFF14B8A6),
                      spots: List.generate(
                        values.length,
                        (i) => FlSpot(i.toDouble(), values[i]),
                      ),
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF14B8A6).withOpacity(0.25),
                            const Color(0xFF14B8A6).withOpacity(0.02),
                          ],
                        ),
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

  Widget _buildInfoBox(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: _animatedItem(
        index: index,
        child: _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF14B8A6), Color(0xFF38BDF8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF14B8A6).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
    required int index,
    bool highlight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = highlight
        ? const [Color(0xFFFF6B6B), Color(0xFFFF8E53)]
        : const [Color(0xFF14B8A6), Color(0xFF38BDF8)];

    return _animatedItem(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: _GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradient),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withOpacity(0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.04),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = data['name']?.toString() ?? 'Dashboard';
    final avatar = data['avatar']?.toString() ?? (isBaby ? '👶' : '👵');
    final birthDate = data['birthDate']?.toString() ?? '';
    final age = _calculateAge(birthDate);

    final firstChart = isBaby
        ? <double>[96, 94, 98, 97, 95]
        : <double>[72, 74, 75, 73, 76];

    final secondChart = isBaby
        ? <double>[7, 6, 8, 7, 8]
        : <double>[97, 98, 98, 97, 99];

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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _animatedItem(
                            index: 0,
                            child: _GlassCard(
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'person-avatar-$personId',
                                    child: Container(
                                      width: 82,
                                      height: 82,
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
                                            ).withOpacity(0.32),
                                            blurRadius: 24,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        avatar,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        _SmallPill(
                                          text: isBaby
                                              ? 'Baby Profile'
                                              : 'Elderly Profile',
                                          icon: isBaby
                                              ? Icons.child_care_rounded
                                              : Icons.elderly_rounded,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Age: $age years',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildChart(
                            title: 'Heart Rate Overview',
                            values: firstChart,
                            context: context,
                            index: 1,
                          ),

                          _buildChart(
                            title: isBaby
                                ? 'Sleep Overview'
                                : 'Oxygen Level Overview',
                            values: secondChart,
                            context: context,
                            index: 2,
                          ),

                          Row(
                            children: [
                              _buildInfoBox(
                                context,
                                isBaby ? 'Feeding' : 'Blood Pressure',
                                isBaby ? '120 ml' : '120 / 80',
                                isBaby
                                    ? Icons.local_drink_outlined
                                    : Icons.monitor_heart_outlined,
                                3,
                              ),
                              const SizedBox(width: 12),
                              _buildInfoBox(
                                context,
                                isBaby ? 'Diapers' : 'Temperature',
                                isBaby ? '5 / day' : '36.8 °C',
                                isBaby
                                    ? Icons.baby_changing_station
                                    : Icons.thermostat_outlined,
                                4,
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          _animatedItem(
                            index: 5,
                            child: Text(
                              'Features',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (isBaby) ...[
                            _buildFeatureCard(
                              context,
                              icon: Icons.mic_rounded,
                              title: 'Baby Cry AI',
                              subtitle:
                                  'Record baby sound and analyze it with AI.',
                              page: const RecorderPage(),
                              highlight: true,
                              index: 6,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.warning_amber_rounded,
                              title: 'Emergency Guide',
                              subtitle:
                                  'Quick first-response notes for baby care.',
                              page: const EmergencyPage(),
                              index: 7,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.bedtime_outlined,
                              title: 'Feeding & Sleep',
                              subtitle:
                                  'Manual daily records for feeding and sleep.',
                              page: const FeedingSleepPage(),
                              index: 8,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.show_chart_rounded,
                              title: 'Growth Tracker',
                              subtitle:
                                  'Save height and weight records easily.',
                              page: const GrowthPage(),
                              index: 9,
                            ),
                          ] else ...[
                            _buildFeatureCard(
                              context,
                              icon: Icons.menu_book_rounded,
                              title: 'Learning Module',
                              subtitle:
                                  'Simple wellness tips for elderly care.',
                              page: const LearningPage(),
                              index: 6,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.monitor_heart_outlined,
                              title: 'Health Monitoring',
                              subtitle:
                                  'Vitals preview and health summary cards.',
                              page: const MonitoringPage(),
                              index: 7,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.notifications_active_outlined,
                              title: 'Smart Alerts',
                              subtitle: 'Helpful reminder list for daily care.',
                              page: const AlertsPage(),
                              index: 8,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.video_call_outlined,
                              title: 'Remote Consultation',
                              subtitle: 'Simple appointment booking interface.',
                              page: const ConsultationPage(),
                              index: 9,
                            ),
                          ],

                          const SizedBox(height: 30),
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
  final EdgeInsetsGeometry? margin;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: ClipRRect(
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

class _SmallPill extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SmallPill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6).withOpacity(isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF14B8A6)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
