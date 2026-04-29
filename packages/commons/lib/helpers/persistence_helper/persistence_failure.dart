import 'package:freezed_annotation/freezed_annotation.dart';

part 'persistence_failure.freezed.dart';

@freezed
sealed class PersistenceFailure with _$PersistenceFailure {
  const factory PersistenceFailure.notFound() = NotFoundPersistenceFailure;

  const factory PersistenceFailure.typeMismatch() = TypeMismatchPersistenceFailure;

  const factory PersistenceFailure.other(String error) = OtherPersistenceFailure;
}
