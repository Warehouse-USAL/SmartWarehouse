import 'package:catalog/catalog.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:dartz/dartz.dart';

/// Mock alineado al contrato `docs/superpowers/specs/2026-05-19-api-contracts-design.md`.
///
/// Las categorías originales del mock (`electronics`, `home`, `sports`,
/// `books`) ya no existen en el enum de dominio. Los items quedan distribuidos
/// entre `ProductCategory.tecnologia` (los electrónicos) y
/// `ProductCategory.otros` (el resto). El mock pierde variedad pero el flujo
/// end-to-end sigue siendo el real.
class MockCatalogRepository implements CatalogRepository {
  static const _ars = 'ARS';

  static const _defaultConstraints = OrderConstraints(maxQuantityPerOrder: 5);

  static final _products = <Product>[
    // technology (14)
    _make(1, 'Auriculares Inalámbricos', ProductCategory.tecnologia, 4999900, 12,
        desc: 'Auriculares Bluetooth con cancelación activa de ruido y 30h de batería.',
        zone: 'Z-A', line: 'L-01', position: 'P-08',
        specs: [
          Spec(label: 'Marca', value: 'Acme Audio'),
          Spec(label: 'Modelo', value: 'AC-700'),
          Spec(label: 'Batería', value: '30 h'),
        ]),
    _make(2, 'Smartwatch Pro', ProductCategory.tecnologia, 8999900, 5,
        desc: 'Smartwatch resistente al agua con monitor cardíaco y GPS.',
        zone: 'Z-A', line: 'L-01', position: 'P-12',
        specs: [
          Spec(label: 'Pantalla', value: '1.4" AMOLED'),
          Spec(label: 'Resistencia', value: '5 ATM'),
        ]),
    _make(3, 'Teclado Mecánico RGB', ProductCategory.tecnologia, 5600000, 0,
        desc: 'Teclado mecánico TKL con switches red e iluminación RGB.',
        zone: 'Z-A', line: 'L-02', position: 'P-05'),
    _make(4, 'Mouse Inalámbrico', ProductCategory.tecnologia, 2200000, 30,
        desc: 'Mouse ergonómico con sensor óptico de 16000 DPI.',
        zone: 'Z-A', line: 'L-02', position: 'P-06'),
    _make(5, 'Cargador USB-C 65W', ProductCategory.tecnologia, 1800000, 50,
        desc: 'Cargador GaN compacto compatible con notebooks y celulares.',
        zone: 'Z-A', line: 'L-03', position: 'P-01'),
    _make(6, 'Cable HDMI 2m', ProductCategory.tecnologia, 450000, 100,
        desc: 'Cable HDMI 2.1 4K@120Hz, 2 metros.',
        zone: 'Z-A', line: 'L-03', position: 'P-02'),
    _make(7, 'Webcam Full HD', ProductCategory.tecnologia, 3500000, 18,
        desc: 'Webcam 1080p con micrófono integrado y enfoque automático.',
        zone: 'Z-A', line: 'L-03', position: 'P-09'),
    _make(8, 'Parlante Bluetooth', ProductCategory.tecnologia, 2890000, 22,
        desc: 'Parlante portátil resistente al agua con 12h de autonomía.',
        zone: 'Z-A', line: 'L-04', position: 'P-01'),
    _make(9, 'Monitor 27" 4K', ProductCategory.tecnologia, 28900000, 7,
        desc: 'Monitor IPS 27" 4K UHD con HDR400.',
        zone: 'Z-A', line: 'L-04', position: 'P-08'),
    _make(10, 'SSD NVMe 1TB', ProductCategory.tecnologia, 6200000, 25,
        desc: 'SSD PCIe Gen 4 con velocidades de hasta 7000 MB/s.',
        zone: 'Z-A', line: 'L-05', position: 'P-03'),
    _make(11, 'Power Bank 20.000 mAh', ProductCategory.tecnologia, 1990000, 40,
        desc: 'Batería portátil con carga rápida 22.5W y triple salida.',
        zone: 'Z-A', line: 'L-05', position: 'P-07'),
    _make(12, 'Hub USB-C 7 en 1', ProductCategory.tecnologia, 2450000, 15,
        desc: 'Hub con HDMI, USB-A, lector SD y power delivery.',
        zone: 'Z-A', line: 'L-05', position: 'P-10'),
    _make(13, 'Auriculares con cable', ProductCategory.tecnologia, 890000, 60,
        desc: 'Auriculares in-ear con micrófono y aislamiento pasivo.',
        zone: 'Z-A', line: 'L-06', position: 'P-04'),
    _make(14, 'Router WiFi 6', ProductCategory.tecnologia, 7800000, 9,
        desc: 'Router de doble banda con soporte WiFi 6 y 4 antenas.',
        zone: 'Z-A', line: 'L-06', position: 'P-11'),

    // other (31) — hogar + deportes + libros colapsados
    _make(15, 'Cafetera Express', ProductCategory.otros, 6500000, 8,
        desc: 'Cafetera express de 15 bares con espumador integrado.',
        zone: 'Z-B', line: 'L-01', position: 'P-04',
        specs: [
          Spec(label: 'Presión', value: '15 bares'),
          Spec(label: 'Capacidad', value: '1.2 L'),
        ]),
    _make(16, 'Aspiradora Robot', ProductCategory.otros, 12000000, 3,
        desc: 'Robot aspirador con mapeo láser y control por app.',
        zone: 'Z-B', line: 'L-01', position: 'P-09'),
    _make(17, 'Tostadora 2 Panes', ProductCategory.otros, 1890000, 18,
        desc: 'Tostadora con 6 niveles de tostado y bandeja recoge migas.',
        zone: 'Z-B', line: 'L-02', position: 'P-06'),
    _make(18, 'Licuadora 1000W', ProductCategory.otros, 3590000, 14,
        desc: 'Licuadora de jarra de vidrio con motor de 1000W y 5 velocidades.',
        zone: 'Z-B', line: 'L-02', position: 'P-12'),
    _make(19, 'Microondas 25 L', ProductCategory.otros, 8400000, 6,
        desc: 'Microondas digital con grill y 10 niveles de potencia.',
        zone: 'Z-B', line: 'L-03', position: 'P-02'),
    _make(20, 'Pava Eléctrica', ProductCategory.otros, 1450000, 35,
        desc: 'Pava de acero inoxidable de 1.7L con apagado automático.',
        zone: 'Z-B', line: 'L-03', position: 'P-08'),
    _make(21, 'Set de Sartenes', ProductCategory.otros, 4200000, 20,
        desc: 'Set de 3 sartenes antiadherentes aptas para inducción.',
        zone: 'Z-B', line: 'L-04', position: 'P-01'),
    _make(22, 'Ventilador de Pie', ProductCategory.otros, 2890000, 11,
        desc: 'Ventilador de pie con 3 velocidades y oscilación.',
        zone: 'Z-B', line: 'L-04', position: 'P-07'),
    _make(23, 'Plancha a Vapor', ProductCategory.otros, 1750000, 28,
        desc: 'Plancha con suela cerámica y golpe de vapor.',
        zone: 'Z-B', line: 'L-05', position: 'P-03'),
    _make(24, 'Almohada Memory Foam', ProductCategory.otros, 1290000, 45,
        desc: 'Almohada viscoelástica con funda lavable.',
        zone: 'Z-B', line: 'L-05', position: 'P-10'),
    _make(25, 'Juego de Sábanas', ProductCategory.otros, 2400000, 32,
        desc: 'Sábanas de algodón 200 hilos, queen size.',
        zone: 'Z-B', line: 'L-06', position: 'P-05'),
    _make(26, 'Lámpara LED de Mesa', ProductCategory.otros, 1690000, 19,
        desc: 'Lámpara con regulación de intensidad y temperatura de color.',
        zone: 'Z-B', line: 'L-06', position: 'P-12'),
    _make(27, 'Set Cuchillos Cocina', ProductCategory.otros, 3990000, 12,
        desc: 'Set de 5 cuchillos de acero inoxidable con taco de madera.',
        zone: 'Z-B', line: 'L-07', position: 'P-04'),
    _make(28, 'Pelota de Fútbol', ProductCategory.otros, 1550000, 40,
        desc: 'Pelota oficial talla 5, ideal para campo o calle.',
        zone: 'Z-C', line: 'L-01', position: 'P-15'),
    _make(29, 'Mancuernas 5kg (par)', ProductCategory.otros, 2200000, 15,
        desc: 'Par de mancuernas de hierro recubiertas en goma.',
        zone: 'Z-C', line: 'L-02', position: 'P-02'),
    _make(30, 'Mat de Yoga', ProductCategory.otros, 1850000, 26,
        desc: 'Mat antideslizante de 6mm, 183x61 cm.',
        zone: 'Z-C', line: 'L-02', position: 'P-08'),
    _make(31, 'Cinta de Correr', ProductCategory.otros, 38900000, 4,
        desc: 'Cinta motorizada con 12 programas y velocidad hasta 14 km/h.',
        zone: 'Z-C', line: 'L-03', position: 'P-01'),
    _make(32, 'Bicicleta Fija', ProductCategory.otros, 18900000, 6,
        desc: 'Bicicleta fija magnética con monitor LCD.',
        zone: 'Z-C', line: 'L-03', position: 'P-07'),
    _make(33, 'Botella Térmica', ProductCategory.otros, 1190000, 50,
        desc: 'Botella de acero inoxidable de 750ml con tapa anti-derrame.',
        zone: 'Z-C', line: 'L-04', position: 'P-03'),
    _make(34, 'Bolso Deportivo', ProductCategory.otros, 2390000, 22,
        desc: 'Bolso de 40 L resistente al agua con compartimentos.',
        zone: 'Z-C', line: 'L-04', position: 'P-10'),
    _make(35, 'Bandas Elásticas (set)', ProductCategory.otros, 990000, 60,
        desc: 'Set de 5 bandas elásticas de diferentes resistencias.',
        zone: 'Z-C', line: 'L-05', position: 'P-05'),
    _make(36, 'Guantes de Box', ProductCategory.otros, 3200000, 13,
        desc: 'Guantes de box 12 oz con cierre de velcro.',
        zone: 'Z-C', line: 'L-05', position: 'P-11'),
    _make(37, 'El Quijote', ProductCategory.otros, 950000, 25,
        desc: 'Edición de bolsillo, tapa blanda, 1200 páginas.',
        zone: 'Z-D', line: 'L-01', position: 'P-03',
        specs: [
          Spec(label: 'Páginas', value: '1200'),
        ]),
    _make(38, 'Clean Code', ProductCategory.otros, 1850000, 10,
        desc: 'Clásico de Robert C. Martin sobre buenas prácticas de software.',
        zone: 'Z-D', line: 'L-01', position: 'P-07'),
    _make(39, 'Sapiens', ProductCategory.otros, 1490000, 18,
        desc: 'De animales a dioses: breve historia de la humanidad.',
        zone: 'Z-D', line: 'L-02', position: 'P-02'),
    _make(40, 'Pragmatic Programmer', ProductCategory.otros, 1990000, 8,
        desc: 'Lecciones para mejorar tu oficio como desarrollador.',
        zone: 'Z-D', line: 'L-02', position: 'P-09'),
    _make(41, 'Cien años de soledad', ProductCategory.otros, 1290000, 22,
        desc: 'Obra maestra de Gabriel García Márquez.',
        zone: 'Z-D', line: 'L-03', position: 'P-04'),
    _make(42, 'Atomic Habits', ProductCategory.otros, 1690000, 30,
        desc: 'Pequeños cambios, grandes resultados — James Clear.',
        zone: 'Z-D', line: 'L-03', position: 'P-12'),
    _make(43, '1984', ProductCategory.otros, 1090000, 35,
        desc: 'Novela distópica clásica de George Orwell.',
        zone: 'Z-D', line: 'L-04', position: 'P-06'),
    _make(44, 'Thinking, Fast and Slow', ProductCategory.otros, 1990000, 11,
        desc: 'Daniel Kahneman sobre los dos sistemas del pensamiento.',
        zone: 'Z-D', line: 'L-04', position: 'P-13'),
    _make(45, 'Designing Data-Intensive Apps', ProductCategory.otros, 2890000, 7,
        desc: 'Guía técnica de arquitectura de sistemas de datos.',
        zone: 'Z-D', line: 'L-05', position: 'P-05'),
  ];

  static Product _make(
    int id,
    String name,
    ProductCategory category,
    int priceCents,
    int stock, {
    required String desc,
    required String zone,
    required String line,
    required String position,
    List<Spec>? specs,
  }) {
    final paddedId = id.toString().padLeft(3, '0');
    return Product(
      id: 'p$id',
      sku: 'SKU-$paddedId',
      name: name,
      category: category,
      price: Money(amount: priceCents, currency: _ars),
      stock: Stock(
        available: stock,
        min: stock > 0 ? (stock ~/ 4).clamp(1, 10) : 5,
        reserved: 0,
      ),
      orderConstraints: _defaultConstraints,
      imageUrl: 'https://picsum.photos/seed/p$id/400',
      description: desc,
      location: ProductLocation(idZone: zone, idLine: line, idPosition: position, height: '0'),
      specs: specs,
    );
  }

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    Iterable<Product> filtered = _products;
    if (category != null) {
      filtered = filtered.where((p) => p.category == category);
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
  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Right(ProductCategory.values);
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
