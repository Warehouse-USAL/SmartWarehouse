/// Categorías del catálogo. Espejo exacto del enum `ProductCategory` del backend
/// (ver `wh-backend/src/main/java/com/usal/whbackend/domain/ProductCategory.java`).
///
/// `key` es el identificador que matchea el enum del back (mayúsculas, sin
/// acentos): lo que el back devuelve en el campo `category` de un producto y lo
/// que el front envía como `?category=` al filtrar.
/// `label` es el nombre en español que se muestra en la UI.
enum ProductCategory {
  tecnologia(key: 'TECNOLOGIA', label: 'Tecnología'),
  herramientas(key: 'HERRAMIENTAS', label: 'Herramientas'),
  alimentos(key: 'ALIMENTOS', label: 'Alimentos'),
  otros(key: 'OTROS', label: 'Otros');

  const ProductCategory({required this.key, required this.label});

  final String key;
  final String label;

  /// Parsea el `category` recibido del back. Devuelve `null` si el valor no
  /// matchea ningún miembro del enum — el caller decide si lo descarta o lo
  /// mapea a `otros`. Tolera variaciones de case por seguridad.
  static ProductCategory? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final upper = raw.toUpperCase();
    for (final c in ProductCategory.values) {
      if (c.key == upper) return c;
    }
    return null;
  }
}
