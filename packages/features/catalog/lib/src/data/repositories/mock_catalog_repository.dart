import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/products_page.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:dartz/dartz.dart';

class MockCatalogRepository implements CatalogRepository {
  static const _categories = <Category>[
    Category(id: 'electronics', name: 'Electrónica'),
    Category(id: 'home', name: 'Hogar'),
    Category(id: 'sports', name: 'Deportes'),
    Category(id: 'books', name: 'Libros'),
  ];

  static final _products = <Product>[
    const Product(
      id: 'p1',
      sku: 'SKU-001',
      name: 'Auriculares Inalámbricos',
      price: 49999.0,
      category: Category(id: 'electronics', name: 'Electrónica'),
      imageUrl: 'https://picsum.photos/seed/p1/400',
      description: 'Auriculares Bluetooth con cancelación activa de ruido y 30h de batería.',
      stock: 12,
    ),
    const Product(
      id: 'p2',
      sku: 'SKU-002',
      name: 'Smartwatch Pro',
      price: 89999.0,
      category: Category(id: 'electronics', name: 'Electrónica'),
      imageUrl: 'https://picsum.photos/seed/p2/400',
      description: 'Smartwatch resistente al agua con monitor cardíaco y GPS.',
      stock: 5,
    ),
    const Product(
      id: 'p3',
      sku: 'SKU-003',
      name: 'Cafetera Express',
      price: 65000.0,
      category: Category(id: 'home', name: 'Hogar'),
      imageUrl: 'https://picsum.photos/seed/p3/400',
      description: 'Cafetera express de 15 bares con espumador de leche integrado.',
      stock: 8,
    ),
    const Product(
      id: 'p4',
      sku: 'SKU-004',
      name: 'Aspiradora Robot',
      price: 120000.0,
      category: Category(id: 'home', name: 'Hogar'),
      imageUrl: 'https://picsum.photos/seed/p4/400',
      description: 'Robot aspirador con mapeo láser y control por app.',
      stock: 3,
    ),
    const Product(
      id: 'p5',
      sku: 'SKU-005',
      name: 'Pelota de Fútbol',
      price: 15500.0,
      category: Category(id: 'sports', name: 'Deportes'),
      imageUrl: 'https://picsum.photos/seed/p5/400',
      description: 'Pelota oficial talla 5, ideal para campo o calle.',
      stock: 40,
    ),
    const Product(
      id: 'p6',
      sku: 'SKU-006',
      name: 'Mancuernas 5kg (par)',
      price: 22000.0,
      category: Category(id: 'sports', name: 'Deportes'),
      imageUrl: 'https://picsum.photos/seed/p6/400',
      description: 'Par de mancuernas de hierro recubiertas en goma.',
      stock: 15,
    ),
    const Product(
      id: 'p7',
      sku: 'SKU-007',
      name: 'El Quijote',
      price: 9500.0,
      category: Category(id: 'books', name: 'Libros'),
      imageUrl: 'https://picsum.photos/seed/p7/400',
      description: 'Edición de bolsillo, tapa blanda, 1200 páginas.',
      stock: 25,
    ),
    const Product(
      id: 'p8',
      sku: 'SKU-008',
      name: 'Clean Code',
      price: 18500.0,
      category: Category(id: 'books', name: 'Libros'),
      imageUrl: 'https://picsum.photos/seed/p8/400',
      description: 'Clásico de Robert C. Martin sobre buenas prácticas de software.',
      stock: 10,
    ),
    const Product(
      id: 'p9',
      sku: 'SKU-009',
      name: 'Teclado Mecánico',
      price: 56000.0,
      category: Category(id: 'electronics', name: 'Electrónica'),
      imageUrl: 'https://picsum.photos/seed/p9/400',
      description: 'Teclado mecánico RGB con switches red.',
      stock: 0,
    ),
    const Product(
      id: 'p10',
      sku: 'SKU-010',
      name: 'Tostadora 2 Panes',
      price: 18900.0,
      category: Category(id: 'home', name: 'Hogar'),
      imageUrl: 'https://picsum.photos/seed/p10/400',
      description: 'Tostadora con 6 niveles de tostado y bandeja recoge migas.',
      stock: 18,
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
