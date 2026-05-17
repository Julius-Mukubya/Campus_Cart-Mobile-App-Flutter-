/// Exception thrown by repository layer when data operations fail.
class RepositoryException implements Exception {
  final String message;
  final String? operation;
  final dynamic originalError;

  RepositoryException(
    this.message, {
    this.operation,
    this.originalError,
  });

  @override
  String toString() {
    final buf = StringBuffer('RepositoryException: $message');
    if (operation != null) buf.write(' (operation: $operation)');
    if (originalError != null) buf.write('; cause: $originalError');
    return buf.toString();
  }
}