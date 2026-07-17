import 'package:equatable/equatable.dart';

/// Lightweight sealed-style Result type used by every repository method.
///
/// Using this instead of throwing exceptions across layers keeps error
/// handling explicit at the provider/UI level (loading / data / error
/// states), and makes it trivial to swap the mock data source for a real
/// API/Dio implementation later — the contract (`Result<T>`) never changes.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is ResultFailure<T>) return failure(self.failure);
    throw StateError('Unknown Result subtype');
  }

  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}

/// Base failure type surfaced to the UI layer for error states + retries.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network and try again.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end. Please try again shortly.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The content you were looking for could not be found.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to load saved data on this device.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
