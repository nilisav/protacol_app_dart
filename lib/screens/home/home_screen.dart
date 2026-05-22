import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/workspace.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).loadWorkspace());
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return homeState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ошибка: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(homeProvider.notifier).loadWorkspace(),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();
        final ws = data.workspace;

        return RefreshIndicator(
          onRefresh: () => ref.read(homeProvider.notifier).loadWorkspace(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WelcomeSection(
                quotes: ws.quotes,
                daysSinceRegistration: ws.daysSinceRegistration,
              ),
              const SizedBox(height: 16),
              _QuickMetrics(
                todayPotential: ws.realizedPotential.today,
                yesterdayPotential: ws.realizedPotential.yesterday,
                mood: ws.mood,
                completedGoals: ws.completedGoals,
                surveyStatus: ws.surveyInfo?.status,
              ),
              const SizedBox(height: 16),
              _PotentialBars(
                month: ws.realizedPotential.month,
                week: ws.realizedPotential.week,
              ),
              const SizedBox(height: 16),
              _DynamicsSection(dynamics: ws.realizedPotential.dynamics),
              const SizedBox(height: 16),
              _AchievementsGrid(achievements: ws.achievements),
              const SizedBox(height: 16),
              _NewsSection(news: ws.news),
            ],
          ),
        );
      },
    );
  }
}

// Виджеты-заглушки

class _WelcomeSection extends StatelessWidget {
  final List<dynamic> quotes;
  final int daysSinceRegistration;

  const _WelcomeSection({
    required this.quotes,
    required this.daysSinceRegistration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                quotes.isNotEmpty
                    ? '«${quotes.first.text}»'
                    : 'С возвращением!',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                const Text('Дней в проекте', style: TextStyle(fontSize: 12)),
                Text(
                  '$daysSinceRegistration',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMetrics extends StatelessWidget {
  final int todayPotential;
  final int yesterdayPotential;
  final String? mood;
  final int completedGoals;
  final String? surveyStatus;

  const _QuickMetrics({
    required this.todayPotential,
    required this.yesterdayPotential,
    this.mood,
    required this.completedGoals,
    this.surveyStatus,
  });

  String _moodEmoji(String? mood) {
    const map = {
      'Энергичный': '⚡',
      'Спокойный': '😌',
      'Творческий': '🎨',
      'Тревожный': '😰',
      'Раздраженный': '😤',
      'Грустный': '😢',
      'Радостный': '😊',
      'Апатичный': '😑',
      'Мотивированный': '💪',
      'Выгоревший': '😮‍💨',
    };
    return map[mood] ?? '😐';
  }

  @override
  Widget build(BuildContext context) {
    final diff = todayPotential - yesterdayPotential;
    final sign = diff >= 0 ? '+' : '';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricCard(
          title: 'Реализованный потенциал',
          value: '$todayPotential%',
          subtitle: '$sign$diff%',
        ),
        _MetricCard(title: 'Настроение', value: _moodEmoji(mood)),
        _MetricCard(title: 'Целей достигнуто', value: '$completedGoals'),
        _MetricCard(
          title: 'Опросник',
          value: surveyStatus == 'completed'
              ? '✓'
              : surveyStatus == null
              ? '⏲'
              : '✗',
          subtitle: surveyStatus == 'completed'
              ? 'Пройден'
              : surveyStatus == null
              ? 'Не назначен'
              : 'Не пройден',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const _MetricCard({required this.title, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PotentialBars extends StatelessWidget {
  final int month;
  final int week;

  const _PotentialBars({required this.month, required this.week});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Реализованный потенциал',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('МЕСЯЦ', style: TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: month.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$month%'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('НЕДЕЛЯ', style: TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: week.toDouble(),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$week%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicsSection extends StatelessWidget {
  final Dynamics dynamics;

  const _DynamicsSection({required this.dynamics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Динамика за 90 дней',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Средний потенциал',
                  value: '${dynamics.average}%',
                ),
                _StatItem(
                  label: 'Темп роста',
                  value:
                      '${dynamics.growth >= 0 ? "+" : ""}${dynamics.growth}%',
                  isPositive: dynamics.growth >= 0,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dynamics.daily.map((d) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: d.potential.toDouble(),
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _StatItem({
    required this.label,
    required this.value,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Наши достижения',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: achievements.take(6).map((a) {
            final days = a.createdAt.difference(a.updatedAt).inDays.abs();
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('$days дн.'),
                      Text('${a.targetValue} ${a.type}'),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _NewsSection extends StatelessWidget {
  final NewsData news;

  const _NewsSection({required this.news});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Новости', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Новости проекта',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        ...news.project
            .take(3)
            .map(
              (n) => ListTile(
                dense: true,
                title: Text(n.title, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  n.previewText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        const SizedBox(height: 8),
        Text(
          'Исследования и советы',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        ...news.research
            .take(3)
            .map(
              (n) => ListTile(
                dense: true,
                title: Text(n.title, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  n.previewText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
      ],
    );
  }
}
