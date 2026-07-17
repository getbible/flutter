sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

final class ApiFormatException extends AppException {
  const ApiFormatException(super.message, [super.cause]);
}

final class StorageException extends AppException {
  const StorageException(super.message, [super.cause]);
}

final class BackupException extends AppException {
  const BackupException(super.message, [super.cause]);
}
