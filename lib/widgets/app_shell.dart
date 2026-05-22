import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'side_menu.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String? title;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    this.title,
    this.actions,
  });

  static const _destinations = [
    {'label': 'Главная', 'icon': Icons.home, 'path': '/home'},
    {'label': 'Привычки', 'icon': Icons.check_circle, 'path': '/habits'},
    {'label': 'Цели', 'icon': Icons.flag, 'path': '/goals'},
    {'label': 'Дневник', 'icon': Icons.book, 'path': '/diary'},
    {'label': 'Задачи', 'icon': Icons.task, 'path': '/tasks'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: actions,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            bottom: 12,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_destinations.length, (index) {
                      final d = _destinations[index];
                      final isSelected = index == currentIndex;
                      return GestureDetector(
                        onTap: () => context.go(d['path'] as String),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              d['icon'] as IconData,
                              size: 22,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              d['label'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
