import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/habit.dart';
import '../../providers/habits_provider.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(habitsProvider.notifier).loadHabits());
  }

  List<DateTime> get _days {
    final now = DateTime.now();
    return List.generate(4, (i) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 3 - i));
    });
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider); // можно read - как разовый вызов (использовать в др местах)
    final days = _days;

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Ошибка: $err')),
      data: (habits) {
        if (habits.isEmpty) {
          return const Center(child: Text('Нет привычек'));
        }
        return Column(
          children: [
            _DaysHeader(days: days),
            Expanded(
              child: ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return _HabitRow(
                    habit: habits[index],
                    days: days,
                    formatDate: _formatDate,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Заголовок с днями недели и числами
class _DaysHeader extends StatelessWidget {
  final List<DateTime> days;
  const _DaysHeader({required this.days});

  String _dayName(int weekday) {
    const names = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return names[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayFormatted =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Привычка',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          ...days.map((d) {
            final formatted =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            final isToday = formatted == todayFormatted;
            return Container(
              width: 44,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    _dayName(d.weekday),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Строка одной привычки
class _HabitRow extends ConsumerWidget {
  final Habit habit;
  final List<DateTime> days;
  final String Function(DateTime) formatDate;

  const _HabitRow({
    required this.habit,
    required this.days,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(habitsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Кнопки сессии + название
          SizedBox(
            width: 120,
            child: Row(
              children: [
                _SessionButton(
                  icon: Icons.play_arrow,
                  onTap: () => notifier.startSession(habit.id),
                  size: 20,
                ),
                const SizedBox(width: 4),
                _SessionButton(
                  icon: Icons.stop,
                  onTap: () => notifier.stopAndSaveSession(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(habit.title, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Чекбоксы по дням
          ...days.map((d) {
            final status = habit.statusForDate(d);
            final isChecked = status == 'completed';
            return SizedBox(
              width: 44,
              child: Checkbox(
                value: isChecked,
                onChanged: (val) {
                  notifier.saveChanges([
                    {
                      'habit_id': habit.id.toString(),
                      'date': formatDate(d),
                      'status': val == true ? 'completed' : 'not_completed',
                    },
                  ]);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Кнопка сессии
class _SessionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _SessionButton({
    required this.icon,
    required this.onTap,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: Colors.grey[400]),
    );
  }
}

// Нижняя панель
class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionChip(label: 'Редактировать', icon: Icons.edit),
            _ActionChip(label: 'Рекомендации', icon: Icons.lightbulb_outline),
            _ActionChip(label: 'Сессии', icon: Icons.timer),
            _ActionChip(label: 'Аналитика', icon: Icons.analytics),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ActionChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Тут модалки позже надо сделать
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
