abstract class UseCase<T, Params> {
  Future<T> call(Params params);
  Stream<T> callStream(Params params) async* {}
  Stream<T> downloadStream(Params params, Function(int, int)? onProgress) async* {}
}
