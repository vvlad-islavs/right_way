import 'package:right_way/features/today_plan/domain/domain.dart';

String mealTypeRu(String type) {
  switch (type) {
    case 'breakfast':
      return 'Завтрак';
    case 'lunch':
      return 'Обед';
    case 'dinner':
      return 'Ужин';
    case 'snack':
      return 'Перекус';
    default:
      return type.isEmpty ? 'Приём пищи' : type;
  }
}

String formatRecipe(MealEntity meal) {
  final buf = StringBuffer();
  if (meal.ingredients.isNotEmpty) {
    buf.writeln('Ингредиенты:');
    for (final i in meal.ingredients) {
      buf.writeln('· ${i.name} — ${i.amount} ${i.unit}');
    }
    buf.writeln();
  }
  if (meal.steps.isNotEmpty) {
    buf.writeln('Шаги:');
    var step = 1;
    for (final s in meal.steps) {
      buf.writeln('$step. $s');
      step++;
    }
  }
  final t = buf.toString().trim();
  return t.isEmpty ? 'Нет деталей рецепта.' : t;
}

const _weekdayShort = ['', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

String weekdayShortRu(int weekDay) {
  if (weekDay < 1 || weekDay > 7) return '';
  return _weekdayShort[weekDay];
}
