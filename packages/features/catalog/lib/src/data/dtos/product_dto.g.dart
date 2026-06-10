// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => _ProductDto(
  id: json['id'] as String,
  sku: json['sku'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  category: json['category'] as String? ?? 'other',
  imageUrl: json['image_url'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => ProductImageDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  price: json['price'] == null
      ? null
      : PriceDto.fromJson(json['price'] as Map<String, dynamic>),
  specs:
      (json['specs'] as List<dynamic>?)
          ?.map((e) => SpecDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  stock: json['stock'] == null
      ? null
      : StockDto.fromJson(json['stock'] as Map<String, dynamic>),
  orderConstraints: json['order_constraints'] == null
      ? null
      : OrderConstraintsDto.fromJson(
          json['order_constraints'] as Map<String, dynamic>,
        ),
  location: json['location'] == null
      ? null
      : ProductLocationDto.fromJson(json['location'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ProductDtoToJson(_ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'image_url': instance.imageUrl,
      'images': instance.images.map((e) => e.toJson()).toList(),
      'price': instance.price?.toJson(),
      'specs': instance.specs.map((e) => e.toJson()).toList(),
      'stock': instance.stock?.toJson(),
      'order_constraints': instance.orderConstraints?.toJson(),
      'location': instance.location?.toJson(),
      'created_at': instance.createdAt,
    };
