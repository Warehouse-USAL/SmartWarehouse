/// Categorías del catálogo. Espejo del enum `ProductCategory` del backend.
///
/// `key` es el identificador en inglés lowercase: lo que el back devuelve en
/// `GET /categories`, lo que viene en el campo `category` del producto y lo
/// que el front envía como `?category=` al filtrar.
/// `label` es el nombre en español que se muestra en la UI.
enum ProductCategory {
  technology(key: 'technology', label: 'Tecnología'),
  tools(key: 'tools', label: 'Herramientas'),
  food(key: 'food', label: 'Alimentos'),
  other(key: 'other', label: 'Otros');

  const ProductCategory({required this.key, required this.label});

  final String key;
  final String label;

  /// Parsea el `key` recibido del back. Devuelve `null` si el valor no matchea
  /// ningún miembro del enum — el caller decide si lo descarta o lo mapea a
  /// `other`.
  static ProductCategory? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    for (final c in ProductCategory.values) {
      if (c.key == lower) return c;
    }
    return null;
  }
}
