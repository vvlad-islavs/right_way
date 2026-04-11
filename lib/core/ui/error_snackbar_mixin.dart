import 'dart:async';

import 'package:flutter/material.dart';
import 'package:right_way/core/core.dart';

mixin ErrorSnackBarMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<AppError>? _errorsSub;

  @protected
  ErrorReporter get errorReporter => di<ErrorReporter>();

  @protected
  bool get showErrorsAsSnackbars => true;

  /// If true, shows snackbar only when this route is current (prevents duplicates
  /// when multiple tab screens are kept alive).
  @protected
  bool get showOnlyWhenRouteIsCurrent => true;

  @protected
  SnackBar buildErrorSnackBar(AppError error) => SnackBar(content: Text(error.uiMessage));

  @protected
  void onAppError(AppError error) {
    if (!showErrorsAsSnackbars) return;
    if (!mounted) return;
    if (showOnlyWhenRouteIsCurrent) {
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) return;
    }
    showAppSnackBar(context, error.uiMessage);
  }

  @override
  void initState() {
    super.initState();
    _errorsSub = errorReporter.stream.listen(onAppError);
  }

  @override
  void dispose() {
    _errorsSub?.cancel();
    super.dispose();
  }
}

