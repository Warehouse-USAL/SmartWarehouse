class ProductImage {
  const ProductImage({
    required this.url,
    this.alt,
    this.isPrimary = false,
  });

  final String url;
  final String? alt;
  final bool isPrimary;
}
