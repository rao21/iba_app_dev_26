import 'package:equatable/equatable.dart';

/// Something went wrong fetching data, described in terms the domain layer
/// understands — never a raw exception from whatever the data layer happens
/// to use underneath (http, Firestore, a local database, anything else).
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The data source reached its backend, but the backend returned an error
/// (a non-200 status, a malformed response, or the request failed outright).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
