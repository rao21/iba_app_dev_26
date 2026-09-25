class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
}

