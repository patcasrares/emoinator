class BaseException implements Exception {
  late final String message;

  BaseException(this.message);

  @override
  String toString() {
    return message;
  }
}
