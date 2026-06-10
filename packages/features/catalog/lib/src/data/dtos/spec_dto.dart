import 'package:freezed_annotation/freezed_annotation.dart';

part 'spec_dto.freezed.dart';
part 'spec_dto.g.dart';

@freezed
sealed class SpecDto with _$SpecDto {
  const factory SpecDto({
    required String label,
    required String value,
  }) = _SpecDto;

  factory SpecDto.fromJson(Map<String, dynamic> json) =>
      _$SpecDtoFromJson(json);
}
