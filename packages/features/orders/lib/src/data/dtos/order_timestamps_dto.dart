import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_timestamps_dto.freezed.dart';
part 'order_timestamps_dto.g.dart';

@freezed
sealed class OrderTimestampsDto with _$OrderTimestampsDto {
  const factory OrderTimestampsDto({
    String? createdAt,
    String? startedAt,
    String? completedAt,
  }) = _OrderTimestampsDto;

  factory OrderTimestampsDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTimestampsDtoFromJson(json);
}
