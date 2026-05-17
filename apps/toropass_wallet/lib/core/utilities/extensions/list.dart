extension ListExtensions<T> on List<T> {
  List<dynamic> mapWithIndex(dynamic Function(T, int) callback) {
    List<dynamic> result = [];
    List.generate(length, (index) {
      final item = this[index];
      result.add(callback(item, index));
    });
    return result;
  }
}
