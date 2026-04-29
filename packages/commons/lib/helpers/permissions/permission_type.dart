import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_type.freezed.dart';

@freezed
sealed class PermissionType with _$PermissionType {
  const factory PermissionType.camera() = CameraPermissionType;
}
