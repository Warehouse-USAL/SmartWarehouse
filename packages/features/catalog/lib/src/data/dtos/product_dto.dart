import 'package:catalog/src/data/dtos/order_constraints_dto.dart';
import 'package:catalog/src/data/dtos/price_dto.dart';
import 'package:catalog/src/data/dtos/product_image_dto.dart';
import 'package:catalog/src/data/dtos/product_location_dto.dart';
import 'package:catalog/src/data/dtos/spec_dto.dart';
import 'package:catalog/src/data/dtos/stock_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

@freezed
sealed class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String sku,
    required String name,
    String? description,
    @Default('other') String category,
    String? imageUrl,
    @Default([]) List<ProductImageDto> images,
    PriceDto? price,
    @Default([]) List<SpecDto> specs,
    StockDto? stock,
    OrderConstraintsDto? orderConstraints,
    ProductLocationDto? location,
    String? createdAt,
  }) = _ProductDto;

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);
}
