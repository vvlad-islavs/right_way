import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:right_way/core/core.dart';

@RoutePage()
class TodayPlanScreen extends StatelessWidget {
  const TodayPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Завтрак', 'Овсянка с ягодами', 'Овсянка, вода/молоко, ягоды, орехи.'),
      ('Обед', 'Курица + гречка', 'Куриная грудка, гречка, салат.'),
      ('Ужин', 'Рыба + овощи', 'Запеченная рыба, брокколи, лимон.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('План на сегодня')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (time, title, recipe) = items[index];
          return Card(
            child: ListTile(
              title: Text('$time — $title'),
              subtitle: const Text('Нажми, чтобы открыть рецепт'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.router.push(
                RecipeRoute(title: title, recipe: recipe),
              ),
            ),
          );
        },
      ),
    );
  }
}

