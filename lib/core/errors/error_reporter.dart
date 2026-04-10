import 'dart:async';

class AppError {
  const AppError({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
}

abstract interface class ErrorReporter {
  Stream<AppError> get stream;
  void report(Object error, StackTrace stackTrace, {String? message});
  void reportMessage(String message);
}

class StreamErrorReporter implements ErrorReporter {
  final _controller = StreamController<AppError>.broadcast();

  @override
  Stream<AppError> get stream => _controller.stream;

  @override
  void report(Object error, StackTrace stackTrace, {String? message}) {
    _controller.add(
      AppError(
        message: message ?? error.toString(),
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  }

  @override
  void reportMessage(String message) {
    _controller.add(AppError(message: message));
  }

  void dispose() {
    _controller.close();
  }
}

