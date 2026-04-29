import 'package:commons/helpers/injector/get_it_injector.dart';

typedef FactoryFunc<T> = T Function();
typedef FactoryFuncAsync<T> = Future<T> Function();

abstract class Injector {
  static Injector? _instance;

  /// get instance short access
  static Injector get i => _instance ??= GetItInjector();

  void registerFactory<T extends Object>(FactoryFunc<T> factoryFunc);

  void registerFactoryByName<T extends Object>(FactoryFunc<T> factoryFunc, String name);

  void registerSingleton<T extends Object>(T instance);

  void registerLazySingleton<T extends Object>(FactoryFunc<T> factoryFunc);

  Future<void> registerLazySingletonAsync<T extends Object>(FactoryFuncAsync<T> factoryFunc);

  void registerLazySingletonByName<T extends Object>(FactoryFunc<T> factoryFunc, String name);

  void clear();

  bool isRegistered<T extends Object>();

  T resolve<T extends Object>();

  T? resolveOrNull<T extends Object>();

  T resolveByName<T extends Object>(String name);

  static Injector register(Injector implementation) {
    _instance = implementation;
    return _instance!;
  }

  Future<T> resolveAsync<T extends Object>({bool ifExist = false});
}
