import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прогресс')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text('Трек веса'),
              subtitle: Text('Скоро: история и график'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text('Калории и соблюдение'),
              subtitle: Text('Скоро: метрики по дням'),
            ),
          ),
        ],
      ),
    );
  }
}

