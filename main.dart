import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const HabitApp());

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Streak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
      ),
      home: const HabitHomePage(),
    );
  }
}

class Habit {
  final String id;
  final String name;
  final String emoji;
  int streak;
  bool completedToday;
  int totalCompleted;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    this.streak = 0,
    this.completedToday = false,
    this.totalCompleted = 0,
  });
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  final List<Habit> _habits = [
    Habit(id: '1', name: 'Пить 2 литра воды', emoji: '💧'),
    Habit(id: '2', name: 'Читать 20 минут', emoji: '📖'),
    Habit(id: '3', name: 'Зарядка 15 минут', emoji: '🏃'),
  ];

  int _points = 0;
  int _freezes = 0;
  int _day = 1;

  static const int _costPerFreeze = 50;
  static const int _pointsPerHabit = 10;
  static const int _perfectDayBonus = 20;
  static const List<String> _emojiChoices = [
    '⭐', '💧', '📖', '🏃', '🧘', '🥗', '💤', '🎯', '✍️', '🎵',
  ];

  int get _completedToday => _habits.where((h) => h.completedToday).length;
  double get _progress =>
      _habits.isEmpty ? 0 : _completedToday / _habits.length;

  void _toggleHabit(Habit habit) {
    setState(() {
      if (habit.completedToday) {
        habit.completedToday = false;
        habit.streak -= 1;
        habit.totalCompleted -= 1;
        _points -= _pointsPerHabit;
      } else {
        habit.completedToday = true;
        habit.streak += 1;
        habit.totalCompleted += 1;
        _points += _pointsPerHabit;
      }
    });
  }

  void _buyFreeze() {
    if (_points < _costPerFreeze) {
      _showSnack('Нужно $_costPerFreeze 🪙 — у вас $_points');
      return;
    }
    setState(() {
      _points -= _costPerFreeze;
      _freezes += 1;
    });
    _showSnack('Куплена заморозка ❄️');
  }

  void _endDay() {
    final allDone =
        _habits.isNotEmpty && _habits.every((h) => h.completedToday);
    int freezesUsed = 0;
    int streaksReset = 0;

    setState(() {
      for (final habit in _habits) {
        if (!habit.completedToday && habit.streak > 0) {
          if (_freezes > 0) {
            _freezes -= 1;
            freezesUsed += 1;
          } else {
            habit.streak = 0;
            streaksReset += 1;
          }
        }
        habit.completedToday = false;
      }
      if (allDone) _points += _perfectDayBonus;
      _day += 1;
    });

    String msg;
    if (allDone) {
      msg = '🎉 Идеальный день! +$_perfectDayBonus очков';
    } else if (freezesUsed > 0) {
      msg = '❄️ Заморозок потрачено: $freezesUsed';
    } else if (streaksReset > 0) {
      msg = 'Серии сброшены: $streaksReset';
    } else {
      msg = 'День $_day';
    }
    _showSnack(msg);
  }

  Future<void> _addHabit() async {
    final controller = TextEditingController();
    String selectedEmoji = _emojiChoices.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF14101E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Новая привычка',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Например, медитация',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Иконка',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emojiChoices.map((e) {
                      final selected = e == selectedEmoji;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedEmoji = e),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: selected
                                ? const LinearGradient(colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFFEC4899),
                                  ])
                                : null,
                            color: selected
                                ? null
                                : Colors.white.withOpacity(0.06),
                          ),
                          child: Text(e,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена',
                            style: TextStyle(color: Colors.white60)),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899),
                            ]),
                          ),
                          child: const Text(
                            'Добавить',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final name = controller.text.trim();
    if (result == true && name.isNotEmpty) {
      setState(() {
        _habits.add(Habit(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          emoji: selectedEmoji,
        ));
      });
    }
  }

  Future<void> _confirmDelete(Habit habit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF14101E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Удалить привычку?',
            style: TextStyle(color: Colors.white)),
        content: Text('${habit.emoji} ${habit.name}',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена',
                style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить',
                style: TextStyle(color: Color(0xFFEC4899))),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _habits.remove(habit));
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1E1730),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 2),
      ));
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0714),
      body: Stack(
        children: [
          // Фоновые градиентные свечения
          Positioned(
            top: -120,
            left: -100,
            child: _glow(const Color(0xFF8B5CF6), 340),
          ),
          Positioned(
            top: 180,
            right: -140,
            child: _glow(const Color(0xFFEC4899), 300),
          ),
          Positioned(
            bottom: -140,
            left: 40,
            child: _glow(const Color(0xFF06B6D4), 320),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildRingSection(),
                const SizedBox(height: 16),
                _buildStatChips(),
                const SizedBox(height: 12),
                Expanded(child: _buildHabitList()),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.35), color.withOpacity(0.0)],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFA78BFA),
                      Color(0xFFEC4899),
                      Color(0xFF22D3EE),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Habit Streak',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Формируй привычки каждый день',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          _dayOrb(),
        ],
      ),
    );
  }

  Widget _dayOrb() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
        ]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0A0714),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_day',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'день',
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PROGRESS RING ====================

  Widget _buildRingSection() {
    return Center(
      child: SizedBox(
        width: 190,
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(190, 190),
              painter: _RingPainter(
                progress: _progress,
                trackColor: Colors.white.withOpacity(0.08),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_completedToday из ${_habits.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STAT CHIPS ====================

  Widget _buildStatChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statChip(
          icon: CustomPaint(size: const Size(22, 22), painter: _CoinPainter()),
          value: '$_points',
          label: 'очки',
        ),
        const SizedBox(width: 12),
        _statChip(
          icon: CustomPaint(
            size: const Size(22, 22),
            painter: _SnowPainter(color: const Color(0xFF67E8F9)),
          ),
          value: '$_freezes',
          label: 'заморозки',
        ),
      ],
    );
  }

  Widget _statChip({
    required Widget icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  // ==================== HABIT LIST ====================

  Widget _buildHabitList() {
    if (_habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.3),
                  const Color(0xFF22D3EE).withOpacity(0.3),
                ]),
              ),
              child: const Center(
                child: Text('🪴', style: TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Пока нет привычек',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Нажмите + чтобы добавить первую',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _habits.length,
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      itemBuilder: (context, index) => _buildHabitTile(_habits[index]),
    );
  }

  Widget _buildHabitTile(Habit habit) {
    final completed = habit.completedToday;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onLongPress: () => _confirmDelete(habit),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(completed ? 0.55 : 0.18),
                const Color(0xFFEC4899).withOpacity(completed ? 0.45 : 0.10),
              ],
            ),
          ),
          padding: const EdgeInsets.all(1.5),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF14101E),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              children: [
                _habitAvatar(habit.emoji, completed),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CustomPaint(
                            size: const Size(14, 14),
                            painter: _FlamePainter(
                                color: const Color(0xFFFF6B35)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.streak}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 14),
                          CustomPaint(
                            size: const Size(14, 14),
                            painter: _CheckPainter(
                                color: const Color(0xFF00E5A0)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.totalCompleted}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleHabit(habit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: completed
                          ? const LinearGradient(colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899),
                            ])
                          : null,
                      border: completed
                          ? null
                          : Border.all(
                              color: Colors.white24, width: 1.5),
                      boxShadow: completed
                          ? [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6)
                                    .withOpacity(0.5),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: completed
                        ? Center(
                            child: CustomPaint(
                              size: const Size(22, 22),
                              painter: _CheckPainter(
                                  color: Colors.white,
                                  strokeWidthFactor: 0.16),
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _habitAvatar(String emoji, bool completed) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [
          const Color(0xFF8B5CF6).withOpacity(completed ? 0.9 : 0.5),
          const Color(0xFF22D3EE).withOpacity(completed ? 0.9 : 0.5),
        ]),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0A0714),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  // ==================== BOTTOM BAR ====================

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: _actionButton(
                iconPainter: _SnowPainter(color: const Color(0xFF67E8F9)),
                label: 'Заморозка',
                sublabel: '$_costPerFreeze 🪙',
                onTap: _buyFreeze,
                gradientColors: const [
                  Color(0xFF06B6D4),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _addHabit,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ]),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(22, 22),
                    painter: _PlusPainter(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                iconPainter: _MoonPainter(color: const Color(0xFFFFD3A5)),
                label: 'Завершить',
                sublabel: 'день',
                onTap: _habits.isEmpty ? null : _endDay,
                gradientColors: const [
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required CustomPainter iconPainter,
    required String label,
    required String sublabel,
    required VoidCallback? onTap,
    required List<Color> gradientColors,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withOpacity(0.25),
                gradientColors[1].withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: gradientColors[0].withOpacity(0.4),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(size: const Size(22, 22), painter: iconPainter),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== CUSTOM PAINTERS ====================

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;

  _RingPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final shader = const SweepGradient(
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
          Color(0xFF22D3EE),
          Color(0xFF8B5CF6),
        ],
        stops: [0.0, 0.4, 0.8, 1.0],
        transform: GradientRotation(-pi / 2),
      ).createShader(rect);
      final paint = Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

class _CheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidthFactor;

  _CheckPainter({required this.color, this.strokeWidthFactor = 0.18});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * strokeWidthFactor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.42, size.height * 0.75)
      ..lineTo(size.width * 0.82, size.height * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.color != color;
}

class _PlusPainter extends CustomPainter {
  final Color color;

  _PlusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlusPainter old) => old.color != color;
}

class _SnowPainter extends CustomPainter {
  final Color color;

  _SnowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, end, paint);

      final bp = Offset(
        center.dx + radius * 0.6 * cos(angle),
        center.dy + radius * 0.6 * sin(angle),
      );
      final branchLen = radius * 0.32;
      for (final d in [-pi / 4, pi / 4]) {
        final bend = angle + d;
        final be = Offset(
          bp.dx + branchLen * cos(bend),
          bp.dy + branchLen * sin(bend),
        );
        canvas.drawLine(bp, be, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter old) => old.color != color;
}

class _FlamePainter extends CustomPainter {
  final Color color;

  _FlamePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..quadraticBezierTo(
          size.width * 0.95, size.height * 0.4,
          size.width * 0.8, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.72, size.height,
          size.width * 0.5, size.height)
      ..quadraticBezierTo(
          size.width * 0.28, size.height,
          size.width * 0.2, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.05, size.height * 0.4,
          size.width * 0.5, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) => old.color != color;
}

class _MoonPainter extends CustomPainter {
  final Color color;

  _MoonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.5),
        radius: size.width * 0.45,
      ));
    final inner = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.65, size.height * 0.35),
        radius: size.width * 0.42,
      ));
    final result = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(result, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) => old.color != color;
}

class _CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    final shader = const LinearGradient(
      colors: [Color(0xFFFFE066), Color(0xFFFFA500)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, Paint()..shader = shader);

    final innerPaint = Paint()
      ..color = const Color(0xFFFFF3C4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08;
    canvas.drawCircle(center, r * 0.55, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) => false;
}
