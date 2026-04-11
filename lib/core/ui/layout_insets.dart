import 'package:flutter/widgets.dart';

/// Отступы для прокручиваемого контента: [base] с каждой стороны плюс
/// [MediaQuery.padding] (вырезы, индикатор «домой», клавиатура учитывается отдельно через resize).
EdgeInsets scrollableContentPadding(BuildContext context, {double base = 16}) {
  final p = MediaQuery.paddingOf(context);
  return EdgeInsets.fromLTRB(
    base + p.left,
    base + p.top,
    base + p.right,
    base + p.bottom,
  );
}
