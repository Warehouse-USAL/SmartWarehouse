import 'package:catalog/src/data/repositories/mock_catalog_repository.dart';
import 'package:catalog/src/data/repositories/remote_catalog_repository.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:catalog/src/presentation/bloc/product_detail_cubit.dart';
import 'package:catalog/src/presentation/pages/catalog_page.dart';
import 'package:catalog/src/presentation/pages/product_detail_page.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class CatalogFeatureBuilder {
  static void injectDependencies() {
    Injector.i
      ..registerLazySingleton<CatalogRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockCatalogRepository()
            : RemoteCatalogRepository(httpHelper: Injector.i.resolve<HttpHelper>()),
      )
      ..registerLazySingleton<CatalogCubit>(
        () => CatalogCubit(Injector.i.resolve<CatalogRepository>()),
      );
  }

  static Widget buildCatalogPage() {
    return CatalogPage(cubit: Injector.i.resolve<CatalogCubit>());
  }

  static Widget buildProductDetailPage(
    String productId, {
    required void Function(Product product) onAddToCart,
  }) {
    return ProductDetailPage(
      cubit: ProductDetailCubit(
        repository: Injector.i.resolve<CatalogRepository>(),
        productId: productId,
      ),
      onAddToCart: onAddToCart,
    );
  }
}
