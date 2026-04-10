import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RecipeScreen extends StatelessWidget {
  const RecipeScreen({
    required this.title,
    required this.recipe,
    super.key,
  });

  final String title;
  final String recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(recipe),
      ),
    );
  }
}

