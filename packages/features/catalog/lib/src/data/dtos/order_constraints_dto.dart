import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_constraints_dto.freezed.dart';
part 'order_constraints_dto.g.dart';

@freezed
sealed class OrderConstraintsDto with _$OrderConstraintsDto {
  const factory OrderConstraintsDto({
    int? maxQuantityPerOrder,
  }) = _OrderConstraintsDto;

  factory OrderConstraintsDto.fromJson(Map<String, dynamic> json) =>
      _$OrderConstraintsDtoFromJson(json);
}
