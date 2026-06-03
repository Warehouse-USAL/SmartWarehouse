import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/product_detail_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required CatalogRepository repository,
    required String productId,
  })  : _repository = repository,
        _productId = productId,
        super(const ProductDetailState.loading()) {
    pageController = PageController();
    load();
  }

  final CatalogRepository _repository;
  final String _productId;
  late final PageController pageController;

  Future<void> load() async {
    emit(const ProductDetailState.loading());
    final result = await _repository.getProductById(_productId);
    result.fold(
      (failure) =>
          emit(ProductDetailState.error(failure.message ?? 'Error cargando producto')),
      (product) => emit(ProductDetailState.ready(product: product)),
    );
  }

  void setQty(int qty) {
    final s = state;
    if (s is ProductDetailReady) emit(s.copyWith(qty: qty));
  }

  void setActiveTab(int tab) {
    final s = state;
    if (s is ProductDetailReady) emit(s.copyWith(activeTab: tab));
  }

  /// Llamado por PageView.onPageChanged cuando el usuario hace swipe.
  void onPageChanged(int index) {
    final s = state;
    if (s is ProductDetailReady) emit(s.copyWith(activeImage: index));
  }

  /// Llamado al tap de un thumbnail; anima la página y actualiza el state.
  Future<void> jumpToImage(int index) async {
    final s = state;
    if (s is ProductDetailReady) emit(s.copyWith(activeImage: index));
    if (pageController.hasClients) {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
