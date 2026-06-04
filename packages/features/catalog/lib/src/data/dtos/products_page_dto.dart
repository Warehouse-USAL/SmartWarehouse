import 'package:catalog/src/data/dtos/pagination_dto.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'products_page_dto.freezed.dart';
part 'products_page_dto.g.dart';

@freezed
sealed class ProductsPageDto with _$ProductsPageDto {
  const factory ProductsPageDto({
    @Default([]) List<ProductDto> products,
    PaginationDto? pagination,
  }) = _ProductsPageDto;

  factory ProductsPageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductsPageDtoFromJson(json);
}
