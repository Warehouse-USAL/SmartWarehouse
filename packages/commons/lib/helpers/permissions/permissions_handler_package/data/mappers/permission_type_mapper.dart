import 'package:commons/helpers/permissions/permission_type.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionTypeMapper {
  PermissionTypeMapper({required this.permissionType});

  final PermissionType permissionType;

  Permission get toPermission => permissionType.when(
        camera: () => Permission.camera,
      );
}
