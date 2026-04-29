import 'package:commons/helpers/permissions/permission_type.dart';
import 'package:commons/helpers/permissions/permissions_handler_package/data/mappers/permission_type_mapper.dart';
import 'package:commons/helpers/permissions/permissions_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHandlerHelper implements PermissionsHelper {
  @override
  Future<bool> requestPermission(
    PermissionType permissionType, {
    ShowAppSettingsOpenModal? onShowAppSettingsOpenModal,
  }) async {
    final permission = PermissionTypeMapper(permissionType: permissionType).toPermission;
    final result = await permission.request();
    if (result.isGranted) return true;
    if (onShowAppSettingsOpenModal != null) return _showOpenSettingsDialog(onShowAppSettingsOpenModal, permissionType);
    return false;
  }

  Future<bool> _showOpenSettingsDialog(
    ShowAppSettingsOpenModal onShowAppSettingsOpenModal,
    PermissionType permissionType,
  ) async {
    final shouldOpenAppSettings = await onShowAppSettingsOpenModal();
    if (shouldOpenAppSettings) return _openAppSettings(permissionType);
    return false;
  }

  Future<bool> _openAppSettings(PermissionType permissionType) async {
    final didOpenSettings = await openSettings();
    if (didOpenSettings) return requestPermission(permissionType);
    return false;
  }

  @override
  Future<bool> openSettings() => openAppSettings();
}
