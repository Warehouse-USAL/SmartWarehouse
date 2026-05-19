

## 1. `POST /auth/login`

Autentica con email/password, devuelve token y datos del usuario.

### Request

```http
POST /auth/login
Content-Type: application/json
```

```json
{
  "email": "ana.lopez@smartwarehouse.com",
  "password": "••••••••"
}
```

### Response — 200 OK

```json
{
  "token": "eyJhbGciOiJI...",
  "user": {
    "id": "u_8f2a",
    "name": "Ana López",
    "email": "ana.lopez@smartwarehouse.com",
    "role": "operator"
  }
}
```

### 2. `GET /products`

Lista paginada del catálogo con filtros.

### Request

```http
GET /products?search=auricular&category=electronics&page=1&page_size=20&in_stock_only=false
Authorization: Bearer <token>
```
```json
{
  "category_id": "electronics",
  "pagination": {
    "page": 1,
    "page_size": 20
  }
}
```

### Response — 200 OK

```json
{
  "products": [
    {
      "id": "p1",
      "sku": "SKU-001",
      "name": "Auriculares Inalámbricos",
      "category": {
        "id": "electronics",
        "name": "Electrónica"
      },
      "image-url": "https://cdn.sw.io/products/p1/thumb.webp",
      "price": {
        "amount": 4999900,
        "currency": "ARS"
      },
      "stock": {
        "available": 12,
        "min": 5,
        "reserved": 4
      },
      "order_constrains": {
        "max_quantity_per_order": 5
      },
      "location:": {
        "id_zone": "uuid-zona",
        "id_line": "uuid-linea",
        "id_position": "uuid-posicion",
        "height": "0"
      },
      "created_at": "2024-05-01T12:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total": 137,
    "has_next": true
  }
}
```


## 3. `GET /products/{id}` — Detalle

Pantalla más cargada del diseño. Múltiples fotos, specs, docs, shipping context.

### Request

```http
GET /products/p1
Authorization: Bearer <token>
```

### Response — 200 OK

```json
{
  "product": {
    "sku": "SKU-001",
    "name": "Auriculares Inalámbricos",
    "description": "Auriculares Bluetooth con cancelación activa de ruido y 30h de batería.",
    "category": { "id": "electronics", "name": "Electrónica" },
    "images": [
      { "url": "https://cdn.sw.io/products/p1/1.webp", "alt": "Vista frontal", "is_primary": true },
      { "url": "https://cdn.sw.io/products/p1/2.webp", "alt": "Vista lateral" },
      { "url": "https://cdn.sw.io/products/p1/3.webp", "alt": "Detalle controles" },
      { "url": "https://cdn.sw.io/products/p1/4.webp", "alt": "Estuche" }
    ],
    "order_constrains": {
      "max_quantity_per_order": 5
    },
    "price": { "amount_cents": 4999900, "currency": "ARS", "tax_included": false },
    "stock": {
      "available": 12,
      "low_stock_threshold": 5,
      
    },
    "shipping": {
      "ships_today": true,
      "cutoff_time": "16:00",
      "pickup_location": "miami"
    },
    "specs": [
      { "label": "Marca", "value": "Acme Audio" },
      { "label": "Modelo", "value": "AC-700" },
      { "label": "Peso", "value": "250 g" },
      { "label": "Batería", "value": "30 h" }
    ]
  }
}
```


## 4. `GET /categories` 🆕

**Endpoint nuevo.** Hoy el cliente arma la lista de categorías derivándola de `/products`, lo cual obliga a traer todos los productos solo para sacar los uniques. Esto es caro y rompe la paginación que proponemos arriba.

### Request

```http
GET /categories
Authorization: Bearer <token>
```

### Response — 200 OK

```json
{
  "categories": [
    {
      "id": "electronics",
      "name": "Electrónica",
      "product_count": 42
    },
    {
      "id": "home",
      "name": "Hogar",
      "product_count": 28
    },
    {
      "id": "sports",
      "name": "Deportes",
      "product_count": 19
    },
    {
      "id": "books",
      "name": "Libros",
      "product_count": 11
    }
  ]
}
```

## 5. `POST /orders`

Crea una orden a partir del cart.

### Request

```http
POST /orders
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
  "items": [
    { "product_id": "p1", "quantity": 2 },
    { "product_id": "p3", "quantity": 1 }
  ],
  "destination": {
    "area": "Bay 14",
    "address_line": "Industrial Park Rd 22, Building C"
  }
}


```
## 6. `POST /orders/:id/cancel`

Cancelar una orden.

### Request

```http
POST /orders/:id/cancel
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
  "reason": "Stock incorrecto en la solicitud"
}


```
