import 'package:orders/orders.dart';

/// Construye un [OrderDestination] partiendo de [OrderDestination.defaults].
///
/// Existe además de esa constante porque `defaults` no puede expresar los
/// opcionales del bloque `address` (`department`, `floor`), que es justo lo
/// que un test que los ejercita necesita variar.
///
/// Los parámetros son nullable en vez de tener el default en la firma porque
/// leer un campo de un objeto `const` no es una expresión constante en Dart.
OrderDestination anOrderDestination({
  String? area,
  String? street,
  String? postalCode,
  String? department,
  String? floor,
}) =>
    OrderDestination(
      area: area ?? OrderDestination.defaults.area,
      street: street ?? OrderDestination.defaults.street,
      postalCode: postalCode ?? OrderDestination.defaults.postalCode,
      department: department,
      floor: floor,
    );
