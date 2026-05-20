import 'package:catalog/catalog.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:dartz/dartz.dart';

/// Mock alineado al contrato
/// `docs/superpowers/specs/2026-05-19-api-contracts-design.md`.
class MockCatalogRepository implements CatalogRepository {
  static const _electronics = Category(id: 'electronics', name: 'Electrónica', productCount: 3);
  static const _home = Category(id: 'home', name: 'Hogar', productCount: 3);
  static const _sports = Category(id: 'sports', name: 'Deportes', productCount: 2);
  static const _books = Category(id: 'books', name: 'Libros', productCount: 2);

  static const _categories = <Category>[_electronics, _home, _sports, _books];

  static const _ars = 'ARS';

  static final _products = <Product>[
    Product(
      id: 'p1',
      sku: 'SKU-001',
      name: 'Auriculares Inalámbricos',
      category: _electronics,
      price: Money(amount: 4999900, currency: _ars),
      stock: Stock(available: 12, min: 5, reserved: 4),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 5),
      imageUrl: 'https://picsum.photos/seed/p1/400',
      description:
          'Auriculares Bluetooth con cancelación activa de ruido y 30h de batería.',
      location: ProductLocation(idZone: 'Z-A', idLine: 'L-01', idPosition: 'P-08', height: '0'),
      createdAt: null,
      images: [
        ProductImage(url: 'https://picsum.photos/seed/p1-1/600', alt: 'Vista frontal', isPrimary: true),
        ProductImage(url: 'https://picsum.photos/seed/p1-2/600', alt: 'Vista lateral'),
        ProductImage(url: 'https://picsum.photos/seed/p1-3/600', alt: 'Detalle controles'),
        ProductImage(url: 'https://picsum.photos/seed/p1-4/600', alt: 'Estuche'),
      ],
      shipping: Shipping(shipsToday: true, cutoffTime: '16:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Marca', value: 'Acme Audio'),
        Spec(label: 'Modelo', value: 'AC-700'),
        Spec(label: 'Peso', value: '250 g'),
        Spec(label: 'Batería', value: '30 h'),
      ],
    ),
    Product(
      id: 'p2',
      sku: 'SKU-002',
      name: 'Smartwatch Pro',
      category: _electronics,
      price: Money(amount: 8999900, currency: _ars),
      stock: Stock(available: 5, min: 3, reserved: 1),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 3),
      imageUrl: 'https://picsum.photos/seed/p2/400',
      description:
          'Smartwatch resistente al agua con monitor cardíaco y GPS.',
      location: ProductLocation(idZone: 'Z-A', idLine: 'L-01', idPosition: 'P-12', height: '1'),
      images: [
        ProductImage(url: 'https://picsum.photos/seed/p2-1/600', alt: 'Frontal', isPrimary: true),
        ProductImage(url: 'https://picsum.photos/seed/p2-2/600', alt: 'Lateral'),
      ],
      shipping: Shipping(shipsToday: true, cutoffTime: '16:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Pantalla', value: '1.4" AMOLED'),
        Spec(label: 'Resistencia', value: '5 ATM'),
        Spec(label: 'Batería', value: '7 días'),
      ],
    ),
    Product(
      id: 'p3',
      sku: 'SKU-003',
      name: 'Cafetera Express',
      category: _home,
      price: Money(amount: 6500000, currency: _ars),
      stock: Stock(available: 8, min: 4, reserved: 0),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 4),
      imageUrl: 'https://picsum.photos/seed/p3/400',
      description: 'Cafetera express de 15 bares con espumador de leche integrado.',
      location: ProductLocation(idZone: 'Z-B', idLine: 'L-03', idPosition: 'P-04', height: '0'),
      images: [
        ProductImage(url: 'https://picsum.photos/seed/p3-1/600', alt: 'Frontal', isPrimary: true),
        ProductImage(url: 'https://picsum.photos/seed/p3-2/600', alt: 'Espumador'),
      ],
      shipping: Shipping(shipsToday: true, cutoffTime: '15:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Presión', value: '15 bares'),
        Spec(label: 'Capacidad', value: '1.2 L'),
      ],
    ),
    Product(
      id: 'p4',
      sku: 'SKU-004',
      name: 'Aspiradora Robot',
      category: _home,
      price: Money(amount: 12000000, currency: _ars),
      stock: Stock(available: 3, min: 2, reserved: 0),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 2),
      imageUrl: 'https://picsum.photos/seed/p4/400',
      description: 'Robot aspirador con mapeo láser y control por app.',
      location: ProductLocation(idZone: 'Z-B', idLine: 'L-04', idPosition: 'P-09', height: '2'),
      shipping: Shipping(shipsToday: false, cutoffTime: '14:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Autonomía', value: '120 min'),
        Spec(label: 'Mapeo', value: 'LIDAR'),
      ],
    ),
    Product(
      id: 'p5',
      sku: 'SKU-005',
      name: 'Pelota de Fútbol',
      category: _sports,
      price: Money(amount: 1550000, currency: _ars),
      stock: Stock(available: 40, min: 10, reserved: 5),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 10),
      imageUrl: 'https://picsum.photos/seed/p5/400',
      description: 'Pelota oficial talla 5, ideal para campo o calle.',
      location: ProductLocation(idZone: 'Z-C', idLine: 'L-02', idPosition: 'P-15', height: '0'),
      shipping: Shipping(shipsToday: true, cutoffTime: '17:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Talla', value: '5'),
        Spec(label: 'Material', value: 'PU'),
      ],
    ),
    Product(
      id: 'p6',
      sku: 'SKU-006',
      name: 'Mancuernas 5kg (par)',
      category: _sports,
      price: Money(amount: 2200000, currency: _ars),
      stock: Stock(available: 15, min: 5, reserved: 2),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 6),
      imageUrl: 'https://picsum.photos/seed/p6/400',
      description: 'Par de mancuernas de hierro recubiertas en goma.',
      location: ProductLocation(idZone: 'Z-C', idLine: 'L-05', idPosition: 'P-02', height: '1'),
      shipping: Shipping(shipsToday: true, cutoffTime: '16:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Peso', value: '5 kg c/u'),
      ],
    ),
    Product(
      id: 'p7',
      sku: 'SKU-007',
      name: 'El Quijote',
      category: _books,
      price: Money(amount: 950000, currency: _ars),
      stock: Stock(available: 25, min: 8, reserved: 0),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 10),
      imageUrl: 'https://picsum.photos/seed/p7/400',
      description: 'Edición de bolsillo, tapa blanda, 1200 páginas.',
      location: ProductLocation(idZone: 'Z-D', idLine: 'L-01', idPosition: 'P-03', height: '0'),
      shipping: Shipping(shipsToday: true, cutoffTime: '17:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Páginas', value: '1200'),
        Spec(label: 'Formato', value: 'Bolsillo'),
      ],
    ),
    Product(
      id: 'p8',
      sku: 'SKU-008',
      name: 'Clean Code',
      category: _books,
      price: Money(amount: 1850000, currency: _ars),
      stock: Stock(available: 10, min: 4, reserved: 1),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 5),
      imageUrl: 'https://picsum.photos/seed/p8/400',
      description: 'Clásico de Robert C. Martin sobre buenas prácticas de software.',
      location: ProductLocation(idZone: 'Z-D', idLine: 'L-02', idPosition: 'P-07', height: '0'),
      shipping: Shipping(shipsToday: true, cutoffTime: '16:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Autor', value: 'Robert C. Martin'),
        Spec(label: 'Páginas', value: '464'),
      ],
    ),
    Product(
      id: 'p9',
      sku: 'SKU-009',
      name: 'Teclado Mecánico',
      category: _electronics,
      price: Money(amount: 5600000, currency: _ars),
      stock: Stock(available: 0, min: 5, reserved: 0),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 5),
      imageUrl: 'https://picsum.photos/seed/p9/400',
      description: 'Teclado mecánico RGB con switches red.',
      location: ProductLocation(idZone: 'Z-A', idLine: 'L-02', idPosition: 'P-05', height: '1'),
      shipping: Shipping(shipsToday: false, cutoffTime: '16:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Switch', value: 'Red'),
        Spec(label: 'Layout', value: 'TKL'),
      ],
    ),
    Product(
      id: 'p10',
      sku: 'SKU-010',
      name: 'Tostadora 2 Panes',
      category: _home,
      price: Money(amount: 1890000, currency: _ars),
      stock: Stock(available: 18, min: 6, reserved: 2),
      orderConstraints: OrderConstraints(maxQuantityPerOrder: 6),
      imageUrl: 'https://picsum.photos/seed/p10/400',
      description: 'Tostadora con 6 niveles de tostado y bandeja recoge migas.',
      location: ProductLocation(idZone: 'Z-B', idLine: 'L-01', idPosition: 'P-06', height: '0'),
      shipping: Shipping(shipsToday: true, cutoffTime: '15:00', pickupLocation: 'Bay 14'),
      specs: [
        Spec(label: 'Potencia', value: '850 W'),
      ],
    ),
  ];

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    Iterable<Product> filtered = _products;
    if (categoryId != null) {
      filtered = filtered.where((p) => p.category.id == categoryId);
    }
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((p) => p.matchesQuery(search));
    }
    final all = filtered.toList(growable: false);
    final total = all.length;
    final start = (page - 1) * pageSize;
    if (start >= total) {
      return Right(ProductsPage(
        items: const [],
        page: page,
        pageSize: pageSize,
        total: total,
        hasNext: false,
      ));
    }
    final end = (start + pageSize).clamp(0, total);
    final slice = all.sublist(start, end);
    return Right(ProductsPage(
      items: slice,
      page: page,
      pageSize: pageSize,
      total: total,
      hasNext: end < total,
    ));
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Right(List.unmodifiable(_categories));
  }

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final found = _products.where((p) => p.id == id);
    if (found.isEmpty) {
      return const Left(CatalogFailure('Producto no encontrado'));
    }
    return Right(found.first);
  }
}
