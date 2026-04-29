import 'dart:convert';
import 'dart:developer';

import 'package:commons/helpers/persistence_helper/persistable_object.dart';
import 'package:commons/helpers/persistence_helper/persistence_failure.dart';
import 'package:commons/helpers/persistence_helper/persistence_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesPersistenceHelper implements PersistenceHelper {
  SharedPreferences? _preferencesInstance;

  Future<SharedPreferences> get _instance async {
    _preferencesInstance ??= await SharedPreferences.getInstance();
    return _preferencesInstance!;
  }

  @override
  Future<bool> exists(String key) async {
    try {
      return (await _instance).containsKey(key);
    } catch (e) {
      log('$e');
      return false;
    }
  }

  @override
  Future<Either<PersistenceFailure, T>> get<T>(
    String key,
    T Function(Map<String, dynamic> json) decoder,
  ) async {
    try {
      final data = (await _instance).getString(key);
      if (data == null) return const Left(PersistenceFailure.notFound());
      final json = jsonDecode(data);
      return Right(decoder(json));
    } catch (e) {
      log('$e');
      return Left(PersistenceFailure.other(e.toString()));
    }
  }

  @override
  Future<Option<PersistenceFailure>> remove(String key) async {
    try {
      final result = await (await _instance).remove(key);
      return result ? const None() : const Some(PersistenceFailure.notFound());
    } catch (e) {
      log('$e');
      return Some(PersistenceFailure.other(e.toString()));
    }
  }

  @override
  Future<Option<PersistenceFailure>> set(
    String key,
    PersistableObject object,
  ) async {
    try {
      final json = jsonEncode(object.toJson());
      final result = await (await _instance).setString(key, json);
      return result ? const None() : const Some(PersistenceFailure.other('Could not save data'));
    } catch (e) {
      log('$e');
      return Some(PersistenceFailure.other(e.toString()));
    }
  }
}
