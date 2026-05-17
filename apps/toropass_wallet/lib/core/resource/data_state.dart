abstract class DataState<T> {
  final T? data;
  final String? error;
  final int? progress;
  final String? summary;
  final dynamic errorData;
  final int? code;

  const DataState({
    this.data,
    this.error,
    this.code,
    this.progress,
    this.errorData,
    this.summary,
  });

  @override
  String toString() {
    return 'DataState(data: $data, error: $error, progress: $progress, summary: $summary, errorData: $errorData, code: $code)';
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
    return 'Data initial';
  }
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);

  @override
  String toString() {
    return 'Data success';
  }
}

class DataProgress<T> extends DataState<T> {
  const DataProgress(int progress) : super(progress: progress);

  @override
  String toString() {
    return 'Data progress: $progress%';
  }
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(String? error, {super.errorData, super.summary})
    : super(error: error);

  @override
  String toString() {
    return 'Data Failed: $error';
  }
}
