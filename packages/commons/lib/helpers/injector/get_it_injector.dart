import 'package:commons/helpers/injector/injector.dart';
import 'package:get_it/get_it.dart';

class GetItInjector implements Injector {
  factory GetItInjector() => _singleton;

  GetItInjector._internal();

  static final GetItInjector _singleton = GetItInjector._internal();
  final GetIt _getIt = GetIt.asNewInstance();

  @override
  void registerFactory<T extends Object>(T Function() factoryFunc) {
    if (_isRegistered<T>()) {
      _getIt.unregister<T>();
    }

    _getIt.registerFactory<T>(factoryFunc);
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    if (_isRegistered<T>()) {
      _getIt.unregister<T>();
    }

    _getIt.registerLazySingleton<T>(factoryFunc);
  }

  @override
  void registerFactoryByName<T extends Object>(T Function() factoryFunc, String name) {
    if (_getIt.isRegistered<T>(instanceName: name)) {
      _getIt.unregister<T>(instanceName: name);
    }
    _getIt.registerFactory<T>(
      factoryFunc,
      instanceName: name,
    );
  }

  @override
  void registerLazySingletonByName<T extends Object>(T Function() factoryFunc, String name) {
    if (_getIt.isRegistered<T>(instanceName: name)) {
      _getIt.unregister<T>(instanceName: name);
    }
    _getIt.registerLazySingleton<T>(
      factoryFunc,
      instanceName: name,
    );
  }

  @override
  void registerSingleton<T extends Object>(T instance) {
    if (_isRegistered<T>()) {
      _getIt.unregister<T>();
    }
    _getIt.registerSingleton<T>(instance);
  }

  @override
  void clear() => _getIt.reset();

  @override
  T resolve<T extends Object>() {
    if (!_isRegistered<T>()) throw Exception('Injector: $T object was not found');
    return _getIt.get<T>();
  }

  @override
  T? resolveOrNull<T extends Object>() {
    if (!_isRegistered<T>()) return null;
    return resolve<T>();
  }

  @override
  T resolveByName<T extends Object>(String name) {
    return _getIt.get<T>(instanceName: name);
  }

  bool _isRegistered<T extends Object>() => _getIt.isRegistered<T>();

  @override
  Future<void> registerLazySingletonAsync<T extends Object>(Future<T> Function() factoryFunc) async {
    if (!_isRegistered<T>()) _getIt.registerFactoryAsync<T>(factoryFunc);
  }

  @override
  Future<T> resolveAsync<T extends Object>({bool ifExist = false}) async {
    if (ifExist && !_isRegistered<T>()) throw Exception('Injector: $T object was not found');
    return _getIt.getAsync<T>();
  }

  @override
  bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}
