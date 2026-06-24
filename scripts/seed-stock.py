#!/usr/bin/env python3
"""
Seed de stock para demo.

Para que el back devuelva `available > 0` en `GET /products/{id}` el producto
tiene que estar asignado a una `Position` con `currentStock > 0` (calcula
`computeAvailableStock` sumando posiciones).

Este script:
  1. Loguea como admin.
  2. Lista todos los productos.
  3. Toma la zona "A" (creada en bootstrap) y la línea 1.
  4. Por cada producto, crea una posición y la patchea con currentStock=50.

No es idempotente — corré antes el reset del warehouse si querés re-seedear.
"""
from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

BASE_URL = os.environ.get("BACKEND_BASE_URL", "http://localhost:8080")
EMAIL = os.environ.get("ADMIN_EMAIL", "admin@smartwarehouse.local")
PASSWORD = os.environ.get("ADMIN_PASSWORD", "changeme")
ZONE_CODE = os.environ.get("ZONE_CODE", "A")
LINE_NUMBER = int(os.environ.get("LINE_NUMBER", "1"))
STOCK_PER_PRODUCT = int(os.environ.get("STOCK_PER_PRODUCT", "40"))


def _req(method: str, path: str, token: str, body: dict | None = None) -> dict:
    headers = {"Authorization": f"Bearer {token}"}
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(
        f"{BASE_URL}{path}", data=data, method=method, headers=headers
    )
    try:
        with urllib.request.urlopen(req) as resp:
            text = resp.read().decode()
            return json.loads(text) if text else {}
    except urllib.error.HTTPError as e:
        raise SystemExit(f"{method} {path} → {e.code}: {e.read().decode()}")


def login() -> str:
    body = json.dumps({"email": EMAIL, "password": PASSWORD}).encode()
    req = urllib.request.Request(
        f"{BASE_URL}/auth/login",
        data=body,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())["token"]


def main() -> int:
    print(f"→ Login en {BASE_URL}…", file=sys.stderr)
    token = login()

    zones = _req("GET", "/warehouse/zones", token)["zones"]
    zone = next((z for z in zones if z["zone_code"] == ZONE_CODE), None)
    if zone is None:
        print(f"✗ No existe la zona '{ZONE_CODE}'", file=sys.stderr)
        return 1
    zone_id = zone["id_zone"]

    lines = _req("GET", f"/warehouse/zones/{zone_id}/lines", token)["lines"]
    line = next((l for l in lines if l["number_line"] == LINE_NUMBER), None)
    if line is None:
        print(f"✗ No existe la línea {LINE_NUMBER} en zona {ZONE_CODE}", file=sys.stderr)
        return 1
    line_id = line["id_line"]
    print(f"→ Zona {ZONE_CODE} ({zone_id}), Línea {LINE_NUMBER} ({line_id})", file=sys.stderr)

    products = _req("GET", "/products?size=100", token)["products"]
    print(f"→ {len(products)} productos a stockear (currentStock={STOCK_PER_PRODUCT})", file=sys.stderr)

    ok = fail = 0
    for i, p in enumerate(products):
        # Crear posición en la línea
        pos_name = f"P-{p['sku']}"
        try:
            pos = _req(
                "POST",
                f"/warehouse/lines/{line_id}/positions",
                token,
                {
                    "position_name": pos_name,
                    "maximum_capacity": 1000,
                    "size_stock_to_save": "CAJA",
                },
            )
            position_id = pos["id_position"]
            # Asignarle el producto + stock
            _req(
                "PATCH",
                f"/warehouse/positions/{position_id}",
                token,
                {
                    "product_id": p["id"],
                    "current_stock": STOCK_PER_PRODUCT,
                    "size_stock_to_save": "CAJA",
                    # computeAvailableStock filtra is_active=true; sin esto
                    # el stock no cuenta y POST /orders falla con
                    # INSUFFICIENT_STOCK.
                    "is_active": True,
                },
            )
            ok += 1
            print(f"  ✓ {p['sku']:8} stock={STOCK_PER_PRODUCT}", file=sys.stderr)
        except SystemExit as e:
            fail += 1
            print(f"  ✗ {p['sku']:8} {e}", file=sys.stderr)

    print(f"\nTotal: {ok} stockeados, {fail} fallaron.", file=sys.stderr)
    return 0 if fail == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
