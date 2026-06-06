import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_bot_page.dart';
import 'main.dart';
import 'smart_dashboard.dart';
import 'storage_service.dart';

class HomePageUI extends StatefulWidget {
  const HomePageUI({super.key});

  @override
  State<HomePageUI> createState() => _HomePageUIState();
}

class _HomePageUIState extends State<HomePageUI> {
  final List<String> _babyAvatars = const ['👶', '🧒', '👦', '👧'];
  final List<String> _elderlyAvatars = const ['👵', '👴', '🧓'];

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

  String _formatBirthDate(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return birthDate;
    }
  }

  Future<void> _showPersonDialog({
    Map<String, dynamic>? person,
    String? personId,
  }) async {
    final nameController = TextEditingController(
      text: person?['name']?.toString() ?? '',
    );

    final currentType = person?['type']?.toString() ?? 'baby';

    String selectedType = currentType;
    String selectedAvatar =
        person?['avatar']?.toString() ??
        (currentType == 'baby' ? _babyAvatars.first : _elderlyAvatars.first);

    DateTime? selectedDate;
    final existingBirthDate = person?['birthDate']?.toString();

    if (existingBirthDate != null && existingBirthDate.isNotEmpty) {
      selectedDate = DateTime.tryParse(existingBirthDate);
    }

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark =
                Theme.of(dialogContext).brightness == Brightness.dark;
            final avatars = selectedType == 'baby'
                ? _babyAvatars
                : _elderlyAvatars;

            if (!avatars.contains(selectedAvatar)) {
              selectedAvatar = avatars.first;
            }

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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 35,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
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
                                  color: const Color(
                                    0xFF14B8A6,
                                  ).withOpacity(0.32),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              person == null
                                  ? Icons.person_add_alt_1_rounded
                                  : Icons.edit_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            person == null ? 'Add Person' : 'Edit Person',
                            style: Theme.of(dialogContext)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage profile details and avatar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextField(
                            controller: nameController,
                            decoration: _dialogInputDecoration(
                              context: dialogContext,
                              label: 'Name',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: _dialogInputDecoration(
                              context: dialogContext,
                              label: 'Type',
                              icon: Icons.category_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'baby',
                                child: Text('Baby'),
                              ),
                              DropdownMenuItem(
                                value: 'elderly',
                                child: Text('Elderly'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setDialogState(() {
                                selectedType = value;
                                selectedAvatar = value == 'baby'
                                    ? _babyAvatars.first
                                    : _elderlyAvatars.first;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );

                              if (pickedDate != null) {
                                setDialogState(() => selectedDate = pickedDate);
                              }
                            },
                            child: InputDecorator(
                              decoration: _dialogInputDecoration(
                                context: dialogContext,
                                label: 'Birth Date',
                                icon: Icons.calendar_month_outlined,
                              ),
                              child: Text(
                                selectedDate == null
                                    ? 'Choose a date'
                                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Choose Avatar',
                              style: Theme.of(dialogContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: avatars.map((avatar) {
                              final isSelected = avatar == selectedAvatar;

                              return InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  setDialogState(() {
                                    selectedAvatar = avatar;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  width: 64,
                                  height: 64,
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
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
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
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final name = nameController.text.trim();

                                        if (name.isEmpty ||
                                            selectedDate == null) {
                                          return;
                                        }

                                        final data = {
                                          'name': name,
                                          'birthDate': selectedDate!
                                              .toIso8601String(),
                                          'avatar': selectedAvatar,
                                          'type': selectedType,
                                        };

                                        if (personId == null) {
                                          await StorageService.addPerson(data);
                                        } else {
                                          await StorageService.updatePerson(
                                            personId,
                                            data,
                                          );
                                        }

                                        if (!mounted || !dialogContext.mounted) return;
                                        Navigator.pop(dialogContext);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        person == null ? 'Add' : 'Save',
                                        style: const TextStyle(
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
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deletePerson(String id) async {
    await StorageService.deletePerson(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Person deleted successfully.')),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _GlassCard(
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF38BDF8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF14B8A6).withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CarePal Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Manage baby and elderly profiles from one clean dashboard.',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: _GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFF14B8A6).withOpacity(0.10),
              ),
              child: Icon(icon, color: const Color(0xFF14B8A6)),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: _GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              size: 54,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(height: 12),
            const Text(
              'No family members yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a baby or an elderly profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonCard({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String personId,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final age = _calculateAge(data['birthDate']?.toString() ?? '');
    final type = data['type']?.toString() ?? 'baby';
    final typeLabel = type == 'baby' ? 'Baby' : 'Elderly';

    final List<Color> avatarGradient = type == 'baby'
        ? const [Color(0xFF38BDF8), Color(0xFF14B8A6)]
        : const [Color(0xFF14B8A6), Color(0xFF0EA5E9)];

    final IconData typeIcon = type == 'baby'
        ? Icons.child_care_rounded
        : Icons.elderly_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SmartDashboard(
                personId: personId,
                data: {...data, 'id': personId},
              ),
            ),
          );
        },
        child: _GlassCard(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ]
                    : [
                        Colors.white.withOpacity(0.86),
                        Colors.white.withOpacity(0.55),
                      ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -28,
                  top: -28,
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarGradient.last.withOpacity(
                        isDark ? 0.12 : 0.18,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: avatarGradient),
                          boxShadow: [
                            BoxShadow(
                              color: avatarGradient.first.withOpacity(0.28),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Text(
                          data['avatar']?.toString() ?? '🙂',
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name']?.toString() ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: typeIcon,
                                  text: typeLabel,
                                  color: avatarGradient.first,
                                ),
                                _InfoChip(
                                  icon: Icons.cake_rounded,
                                  text: '$age years',
                                  color: avatarGradient.last,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 17,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black45,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Birth date: ${_formatBirthDate(data['birthDate']?.toString() ?? '')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        icon: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.04),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showPersonDialog(person: data, personId: personId);
                          } else if (value == 'delete') {
                            _deletePerson(personId);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBotFab() {
    return Positioned(
      left: 22,
      bottom: 0,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withOpacity(0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'chatbot',
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatBotPage()),
            );
          },
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAddFab() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14B8A6).withOpacity(0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'addPerson',
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: _showPersonDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          children: [_buildChatBotFab(), _buildAddFab()],
        ),
      ),

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
                          'Home',
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
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: StorageService.peopleStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Something went wrong.'),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          final babies = docs
                              .where((doc) => doc.data()['type'] == 'baby')
                              .length;

                          final elderly = docs
                              .where((doc) => doc.data()['type'] == 'elderly')
                              .length;

                          if (docs.isEmpty) {
                            return ListView(
                              children: [
                                _buildHeader(context),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      context,
                                      'Babies',
                                      '0',
                                      Icons.child_care_rounded,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSummaryCard(
                                      context,
                                      'Elderly',
                                      '0',
                                      Icons.elderly_rounded,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                _buildEmptyState(context),
                              ],
                            );
                          }

                          return ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildSummaryCard(
                                    context,
                                    'Babies',
                                    '$babies',
                                    Icons.child_care_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildSummaryCard(
                                    context,
                                    'Elderly',
                                    '$elderly',
                                    Icons.elderly_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ...docs.map((doc) {
                                return _buildPersonCard(
                                  context: context,
                                  data: doc.data(),
                                  personId: doc.id,
                                );
                              }),
                              const SizedBox(height: 80),
                            ],
                          );
                        },
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.14 : 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(isDark ? 0.28 : 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _dialogInputDecoration({
  required BuildContext context,
  required String label,
  required IconData icon,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.95),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
    ),
  );
}
