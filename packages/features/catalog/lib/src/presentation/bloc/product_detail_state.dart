import 'package:catalog/src/domain/entities/product.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_detail_state.freezed.dart';

@freezed
sealed class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState.loading() = ProductDetailLoading;
  const factory ProductDetailState.ready({
    required Product product,
    @Default(1) int qty,
    @Default(0) int activeTab,
    @Default(0) int activeImage,
  }) = ProductDetailReady;
  const factory ProductDetailState.error(String message) = ProductDetailError;
}
