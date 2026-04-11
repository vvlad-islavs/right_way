import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:right_way/core/core.dart';

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
    final style = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: scrollableContentPadding(context),
        child: SelectableText(recipe, style: style),
      ),
    );
  }
}

