import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Пользователь',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'protacol.ru',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Профиль',
              onTap: () {
                Navigator.pop(context);
                // context.go('/profile');
              },
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Настройки',
              onTap: () {
                Navigator.pop(context);
                // context.go('/settings');
              },
            ),
            _MenuItem(
              icon: Icons.workspace_premium_outlined,
              label: 'Подписка',
              onTap: () {
                Navigator.pop(context);
                // context.go('/subscription');
              },
            ),
            _MenuItem(
              icon: Icons.feedback_outlined,
              label: 'Отзывы',
              onTap: () {
                Navigator.pop(context);
                // context.go('/feedback');
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            _MenuItem(
              icon: Icons.logout,
              label: 'Выйти',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : Colors.grey[400],
      ),
      title: Text(
        label,
        style: TextStyle(color: isDestructive ? Colors.redAccent : null),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
