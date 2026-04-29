import 'package:commons/helpers/persistence_helper/persistable_object.dart';
import 'package:commons/helpers/persistence_helper/persistence_failure.dart';
import 'package:dartz/dartz.dart';

abstract class PersistenceHelper {
  Future<Either<PersistenceFailure, T>> get<T>(
    String key,
    T Function(Map<String, dynamic>) decoder,
  );

  Future<Option<PersistenceFailure>> set(String key, PersistableObject object);

  Future<Option<PersistenceFailure>> remove(String key);

  Future<bool> exists(String key);
}
