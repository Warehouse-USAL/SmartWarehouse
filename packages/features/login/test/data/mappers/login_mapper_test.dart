import 'package:flutter_test/flutter_test.dart';
import 'package:login/src/data/dtos/login_response_dto.dart';
import 'package:login/src/data/mappers/login_mapper.dart';

void main() {
  group('LoginResponseDtoMapper.toEntity', () {
    test('parses a real login response', () {
      final json = <String, dynamic>{
        'token': 'jwt-abc',
        'user': {
          'id': 'u1',
          'name': 'Admin',
          'email': 'admin@example.com',
          'role': 'SUPERADMIN',
        },
      };
      final tokens = LoginResponseDto.fromJson(json).toEntity();
      expect(tokens.accessToken, 'jwt-abc');
      expect(tokens.user?.email, 'admin@example.com');
      expect(tokens.user?.role, 'SUPERADMIN');
    });

    test('handles missing user', () {
      final tokens = LoginResponseDto.fromJson(<String, dynamic>{
        'token': 'jwt-only',
      }).toEntity();
      expect(tokens.accessToken, 'jwt-only');
      expect(tokens.user, isNull);
    });
  });
}
