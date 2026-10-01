// Exceptions métier auth (mappées depuis FirebaseAuthException
// dans le datasource, messages FR affichés côté UI).
sealed class AuthException implements Exception {
  const AuthException();
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException();
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException();
}

class EmailInUseException extends AuthException {
  const EmailInUseException();
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException();
}

class UserDisabledException extends AuthException {
  const UserDisabledException();
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException();
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException();
}

class NetworkAuthException extends AuthException {
  const NetworkAuthException();
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException();
}

class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException();
}

class UnknownAuthException extends AuthException {
  const UnknownAuthException();
}
