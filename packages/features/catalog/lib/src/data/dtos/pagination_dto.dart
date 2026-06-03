import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_dto.freezed.dart';
part 'pagination_dto.g.dart';

@freezed
sealed class PaginationDto with _$PaginationDto {
  const factory PaginationDto({
    @Default(0) int page,
    @Default(20) int size,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
  }) = _PaginationDto;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);
}
