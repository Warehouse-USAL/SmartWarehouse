import 'package:commons/helpers/permissions/permission_type.dart';

typedef ShowAppSettingsOpenModal = Future<bool> Function();

abstract class PermissionsHelper {
  Future<bool> requestPermission(PermissionType permission, {ShowAppSettingsOpenModal? onShowAppSettingsOpenModal});

  Future<bool> openSettings();
}
