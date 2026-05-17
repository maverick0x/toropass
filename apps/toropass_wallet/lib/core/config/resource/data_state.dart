abstract class DataState<T> {
  final T? data;
  final int? code;
  final String? path;
  final String? error;
  final int? progress;
  final String? message;

  const DataState({
    this.data,
    this.error,
    this.code,
    this.path,
    this.progress,
    this.message,
  });

  @override
  String toString() {
    return 'Data state';
  }
}

class DataLoading<T> extends DataState<T> {
  const DataLoading() : super();

  @override
  String toString() {
    return 'Data loading';
  }
}

class DataInitial<T> extends DataState<T> {
  const DataInitial({super.data});

  @override
  String toString() {
    return 'initial';
  }
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess({super.data});

  @override
  String toString() {
    return 'Data success';
  }
}

class DataProgress<T> extends DataState<T> {
  const DataProgress({super.progress});

  @override
  String toString() {
    return 'Data progress: $progress%';
  }
}

class DataFailed<T> extends DataState<T> {
  final StackTrace? trace;
  const DataFailed({
    super.code,
    super.path,
    super.error,
    super.message,
    this.trace,
  });

  @override
  String toString() {
    return 'Data Failed: $error';
  }
}
