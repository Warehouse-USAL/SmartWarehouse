#!/usr/bin/env python3
"""
Seed de productos para el backend SmartWarehouse.

Uso:
    python3 scripts/seed-products.py
    python3 scripts/seed-products.py --base-url http://localhost:8080
    python3 scripts/seed-products.py --clean   # borra todo antes de seedear

El script:
    1. Loginea como admin (usa ADMIN_EMAIL/ADMIN_PASSWORD env vars, o defaults
       admin@smartwarehouse.local / changeme).
    2. (Opcional con --clean) borra todos los productos existentes.
    3. POST de productos cubriendo las 4 categorías del enum del back
       (TECNOLOGIA / HERRAMIENTAS / ALIMENTOS / OTROS).

Si un SKU ya existe, el back devuelve 409 — el script lo loggea y sigue.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request

# Categorías válidas del enum ProductCategory (back: domain/ProductCategory.java)
TECNOLOGIA = "TECNOLOGIA"
HERRAMIENTAS = "HERRAMIENTAS"
ALIMENTOS = "ALIMENTOS"
OTROS = "OTROS"


def login(base_url: str, email: str, password: str) -> str:
    """Devuelve un JWT válido del admin."""
    body = json.dumps({"email": email, "password": password}).encode()
    req = urllib.request.Request(
        f"{base_url}/auth/login",
        data=body,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())["token"]


def list_products(base_url: str, token: str) -> list[dict]:
    """Trae todos los productos (asume <50 para el seed)."""
    req = urllib.request.Request(
        f"{base_url}/products?size=50",
        headers={"Authorization": f"Bearer {token}"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read()).get("products", [])


def delete_product(base_url: str, token: str, product_id: str) -> None:
    req = urllib.request.Request(
        f"{base_url}/products/{product_id}",
        method="DELETE",
        headers={"Authorization": f"Bearer {token}"},
    )
    urllib.request.urlopen(req).close()


def create_product(base_url: str, token: str, product: dict) -> tuple[bool, str]:
    body = json.dumps(product).encode()
    req = urllib.request.Request(
        f"{base_url}/products",
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return True, f"HTTP {resp.status}"
    except urllib.error.HTTPError as e:
        return False, f"HTTP {e.code}: {e.read().decode()[:120]}"


def make_product(
    sku: str,
    name: str,
    category: str,
    description: str,
    price_cents: int,
    image_seed: str,
    specs: list[tuple[str, str]] | None = None,
    min_stock: int = 5,
    max_qty: int = 10,
) -> dict:
    return {
        "sku": sku,
        "name": name,
        "description": description,
        "category": category,
        "images": [
            {
                "url": f"https://picsum.photos/seed/{image_seed}/600/600",
                "alt": name,
                "is_primary": True,
            }
        ],
        "price": {
            "amount_cents": price_cents,
            "currency": "ARS",
            "tax_included": True,
        },
        "specs": [{"label": k, "value": v} for k, v in (specs or [])],
        "minimum_stock": min_stock,
        "max_quantity_per_order": max_qty,
    }


# 16 productos cubriendo las 4 categorías (4 c/u).
PRODUCTS = [
    # TECNOLOGIA
    make_product("TEC-001", "Auriculares Bluetooth", TECNOLOGIA,
        "Auriculares con cancelación de ruido y 30h de batería.",
        4999900, "auriculares",
        specs=[("Batería", "30 h"), ("Conectividad", "Bluetooth 5.3")],
        min_stock=5, max_qty=10),
    make_product("TEC-002", "Mouse Inalámbrico", TECNOLOGIA,
        "Mouse ergonómico con sensor óptico de 16000 DPI.",
        2200000, "mouse",
        specs=[("DPI", "16000"), ("Botones", "7")],
        min_stock=10, max_qty=20),
    make_product("TEC-003", "Teclado Mecánico RGB", TECNOLOGIA,
        "Teclado mecánico TKL con switches red e iluminación RGB.",
        5600000, "teclado",
        specs=[("Switches", "Red"), ("Layout", "TKL")],
        min_stock=4, max_qty=5),
    make_product("TEC-004", "Webcam Full HD", TECNOLOGIA,
        "Webcam 1080p con micrófono integrado y enfoque automático.",
        3500000, "webcam",
        specs=[("Resolución", "1080p"), ("FOV", "78°")],
        min_stock=5, max_qty=10),

    # HERRAMIENTAS
    make_product("HRR-101", "Taladro Inalámbrico 20V", HERRAMIENTAS,
        "Taladro percutor con batería de litio y portabrocas autoajustable.",
        8900000, "taladro",
        specs=[("Voltaje", "20V"), ("RPM", "1800")],
        min_stock=3, max_qty=5),
    make_product("HRR-102", "Multímetro Digital", HERRAMIENTAS,
        "Multímetro automático con true RMS y CAT III 600V.",
        2800000, "multimetro",
        specs=[("Categoría", "CAT III 600V"), ("Display", "6000 counts")],
        min_stock=5, max_qty=10),
    make_product("HRR-103", "Linterna LED Industrial", HERRAMIENTAS,
        "Linterna recargable de 1000 lúmenes con grip antideslizante.",
        1900000, "linterna",
        specs=[("Lúmenes", "1000"), ("Autonomía", "8 h")],
        min_stock=8, max_qty=15),
    make_product("HRR-104", "Cinta Métrica 8m", HERRAMIENTAS,
        "Cinta métrica con freno y clip para cinturón.",
        450000, "cinta-metrica",
        specs=[("Longitud", "8 m"), ("Ancho", "25 mm")],
        min_stock=15, max_qty=30),

    # ALIMENTOS
    make_product("ALI-201", "Caja Energy Bars x12", ALIMENTOS,
        "Pack de 12 barras energéticas de avena y chocolate.",
        1200000, "energy-bars",
        specs=[("Unidades", "12"), ("Sabor", "Avena/Choco")],
        min_stock=20, max_qty=10),
    make_product("ALI-202", "Pack Hidratante 24x500ml", ALIMENTOS,
        "Pack de 24 botellas de agua mineralizada de 500ml.",
        2400000, "agua",
        specs=[("Unidades", "24"), ("Volumen", "500 ml c/u")],
        min_stock=10, max_qty=8),
    make_product("ALI-203", "Café en Grano 1kg", ALIMENTOS,
        "Café arábica tostado natural, origen Colombia.",
        1800000, "cafe",
        specs=[("Origen", "Colombia"), ("Peso", "1 kg")],
        min_stock=8, max_qty=12),
    make_product("ALI-204", "Galletitas Avena x500g", ALIMENTOS,
        "Galletas de avena y miel sin azúcar añadida.",
        780000, "galletitas",
        specs=[("Peso", "500 g"), ("Sin azúcar", "Sí")],
        min_stock=15, max_qty=20),

    # OTROS
    make_product("OTR-301", "Casco de Seguridad ANSI Z89.1", OTROS,
        "Casco industrial con certificación ANSI Z89.1.",
        1250000, "casco",
        specs=[("Material", "Polietileno HDPE"), ("Certificación", "ANSI Z89.1")],
        min_stock=5, max_qty=10),
    make_product("OTR-302", "Guantes de Trabajo", OTROS,
        "Guantes de cuero reforzado para manipulación pesada.",
        380000, "guantes",
        specs=[("Talla", "L"), ("Material", "Cuero vacuno")],
        min_stock=15, max_qty=20),
    make_product("OTR-303", "Carretilla Industrial 200kg", OTROS,
        "Carretilla de mano con capacidad de 200 kg y ruedas de goma.",
        3500000, "carretilla",
        specs=[("Carga máx", "200 kg"), ("Ruedas", "Goma maciza")],
        min_stock=2, max_qty=3),
    make_product("OTR-304", "Pallet de Madera EUR", OTROS,
        "Pallet europeo estándar 1200×800mm de madera tratada.",
        850000, "pallet",
        specs=[("Dimensión", "1200×800mm"), ("Tratamiento", "HT")],
        min_stock=10, max_qty=20),
]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-url",
        default=os.environ.get("BACKEND_URL", "http://localhost:8080"),
        help="URL base del backend (default: http://localhost:8080)",
    )
    parser.add_argument(
        "--email",
        default=os.environ.get("ADMIN_EMAIL", "admin@smartwarehouse.local"),
    )
    parser.add_argument(
        "--password",
        default=os.environ.get("ADMIN_PASSWORD", "changeme"),
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Borra todos los productos antes de seedear",
    )
    args = parser.parse_args()

    print(f"→ Logueando en {args.base_url} como {args.email}…")
    try:
        token = login(args.base_url, args.email, args.password)
    except Exception as e:
        print(f"  FAIL login: {e}", file=sys.stderr)
        return 1

    if args.clean:
        print("→ Borrando productos existentes (soft delete)…")
        existing = list_products(args.base_url, token)
        for p in existing:
            try:
                delete_product(args.base_url, token, p["id"])
                print(f"  - {p['sku']:8} {p['name']}")
            except Exception as e:
                print(f"  FAIL delete {p['sku']}: {e}", file=sys.stderr)

    print(f"→ Seedeando {len(PRODUCTS)} productos…")
    created = 0
    skipped = 0
    failed = 0
    for product in PRODUCTS:
        ok, msg = create_product(args.base_url, token, product)
        if ok:
            print(f"  ✓ {product['sku']:8} {product['name']:35} ({product['category']})")
            created += 1
        elif "SKU_ALREADY_EXISTS" in msg or "HTTP 409" in msg:
            print(f"  · {product['sku']:8} ya existe — skip")
            skipped += 1
        else:
            print(f"  ✗ {product['sku']:8} {msg}", file=sys.stderr)
            failed += 1

    print(f"\nTotal: {created} creados, {skipped} ya existían, {failed} fallaron.")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
