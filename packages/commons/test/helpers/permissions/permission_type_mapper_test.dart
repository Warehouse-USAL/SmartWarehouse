import 'package:commons/helpers/permissions/permission_type.dart';
import 'package:commons/helpers/permissions/permissions_handler_package/data/mappers/permission_type_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  test('maps camera to Permission.camera', () {
    final mapper = PermissionTypeMapper(
      permissionType: const PermissionType.camera(),
    );

    expect(mapper.toPermission, Permission.camera);
  });
}
