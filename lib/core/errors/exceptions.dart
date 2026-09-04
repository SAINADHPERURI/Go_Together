/// Base Exceptions for GoTogether
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, [super.code]);
}

class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

class AgeIncompatibleException extends AppException {
  const AgeIncompatibleException([String message = 'This trip is organized for a different age group community.'])
      : super(message, 'AGE_INCOMPATIBLE');
}

class TripFullException extends AppException {
  const TripFullException([String message = 'This trip has reached its maximum member capacity.'])
      : super(message, 'TRIP_FULL');
}

class DuplicateRequestException extends AppException {
  const DuplicateRequestException([String message = 'You have already submitted a join request for this trip.'])
      : super(message, 'DUPLICATE_REQUEST');
}

class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}
