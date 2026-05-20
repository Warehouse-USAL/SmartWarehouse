class Category {
  const Category({
    required this.id,
    required this.name,
    this.productCount,
  });

  final String id;
  final String name;

  /// Solo viene de `GET /categories`.
  final int? productCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
