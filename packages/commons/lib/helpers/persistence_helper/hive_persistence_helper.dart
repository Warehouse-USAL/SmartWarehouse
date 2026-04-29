import 'dart:collection';

import 'package:commons/helpers/persistence_helper/persistable_object.dart';
import 'package:commons/helpers/persistence_helper/persistence_failure.dart';
import 'package:commons/helpers/persistence_helper/persistence_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HivePersistenceHelper implements PersistenceHelper {
  HivePersistenceHelper(this.hiveBoxKey);

  final String hiveBoxKey;
  Box? hiveBox;

  Future<void> initHiveBox() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    hiveBox = await Hive.openBox('storage');
  }

  @override
  Future<bool> exists(String key) async {
    if (hiveBox == null) await initHiveBox();
    return hiveBox!.containsKey(key);
  }

  @override
  Future<Either<PersistenceFailure, T>> get<T>(String key, T Function(Map<String, dynamic> json) decoder) async {
    if (hiveBox == null) await initHiveBox();
    final data = await hiveBox!.get(key);
    if (data == null) return const Left(PersistenceFailure.notFound());
    if (data is! Map<dynamic, dynamic>) {
      return const Left(PersistenceFailure.typeMismatch());
    }
    final hashMap = HashMap<String, dynamic>.from(data);
    return Right(decoder(hashMap));
  }

  @override
  Future<Option<PersistenceFailure>> remove(String key) async {
    if (hiveBox == null) await initHiveBox();
    return hiveBox!.delete(key).then(
          (_) => const None(),
          onError: (error, _) => Some(
            PersistenceFailure.other(error.toString()),
          ),
        );
  }

  @override
  Future<Option<PersistenceFailure>> set(
    String key,
    PersistableObject object,
  ) async {
    if (hiveBox == null) await initHiveBox();
    return hiveBox!.put(key, object.toJson()).then(
          (_) => const None(),
          onError: (error, _) => Some(
            PersistenceFailure.other(error.toString()),
          ),
        );
  }
}
