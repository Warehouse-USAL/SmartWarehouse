// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_model.freezed.dart';
part 'refresh_token_model.g.dart';

@freezed
class RefreshTokenModel with _$RefreshTokenModel {
  const factory RefreshTokenModel({
    @JsonKey(name: 'accessToken') required String token,
    @JsonKey(name: 'refreshToken') required String refreshToken,
  }) = _RefreshTokenModel;

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) => _$RefreshTokenModelFromJson(json);
}
