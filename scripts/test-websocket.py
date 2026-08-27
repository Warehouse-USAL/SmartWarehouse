#!/usr/bin/env python3
"""
Test del WebSocket de órdenes.

El único endpoint del back que cambia el status de una orden (y por lo tanto
dispara un evento `order.updated` por WS) es `POST /orders/{id}/cancel`.
Este script:

    1. Loginea como admin.
    2. Lista las órdenes existentes (vía /orders).
    3. Toma una en estado PENDING (o la que le pases por --order-id).
    4. Llama POST /orders/{id}/cancel.
    5. El back emite `order.updated` por WS → tu app debería:
          - Mostrar la notificación (cuando la SnackBar vuelva).
          - El badge de la campana sube en 1.
          - La notificación queda en /notifications.
          - Si tenés el detail de esa orden abierto, el timeline pasa a
            "Cancelado" en tiempo real.

Uso:
    python3 scripts/test-websocket.py                       # cancela la 1ra pending
    python3 scripts/test-websocket.py --order-id <id>       # cancela esa
    python3 scripts/test-websocket.py --list                # solo lista, no cancela
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request


def login(base_url: str, email: str, password: str) -> str:
    body = json.dumps({"email": email, "password": password}).encode()
    req = urllib.request.Request(
        f"{base_url}/auth/login",
        data=body,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())["token"]


def list_orders(base_url: str, token: str) -> list[dict]:
    req = urllib.request.Request(
        f"{base_url}/orders?size=50",
        headers={"Authorization": f"Bearer {token}"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read()).get("orders", [])


def cancel_order(base_url: str, token: str, order_id: str, reason: str) -> dict:
    body = json.dumps({"reason": reason}).encode()
    req = urllib.request.Request(
        f"{base_url}/orders/{order_id}/cancel",
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read()).get("order", {})


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-url",
        default=os.environ.get("BACKEND_URL", "http://localhost:8080"),
    )
    parser.add_argument(
        "--email", default=os.environ.get("ADMIN_EMAIL", "admin@smartwarehouse.local")
    )
    parser.add_argument(
        "--password", default=os.environ.get("ADMIN_PASSWORD", "changeme")
    )
    parser.add_argument("--order-id", help="ID puntual a cancelar")
    parser.add_argument(
        "--reason", default="Test WS desde script", help="Reason para el cancel"
    )
    parser.add_argument(
        "--list", action="store_true", help="Solo listar, no cancelar"
    )
    args = parser.parse_args()

    print(f"→ Login {args.email} en {args.base_url}…")
    try:
        token = login(args.base_url, args.email, args.password)
    except Exception as e:
        print(f"  FAIL login: {e}", file=sys.stderr)
        return 1

    orders = list_orders(args.base_url, token)
    print(f"→ {len(orders)} órdenes en el sistema:")
    for o in orders:
        ts = o.get("timestamps", {}) or {}
        print(
            f"  · {o['id']}  status={o['status']:10}  created={ts.get('created_at', '?')}"
        )

    if args.list:
        return 0

    if args.order_id:
        target = next((o for o in orders if o["id"] == args.order_id), None)
        if not target:
            print(f"FAIL: no encontré orden con id {args.order_id}", file=sys.stderr)
            return 1
    else:
        pending = [o for o in orders if o.get("status") == "pending"]
        if not pending:
            print(
                "FAIL: no hay órdenes PENDING para cancelar. Pasá --order-id <id>.",
                file=sys.stderr,
            )
            return 1
        target = pending[0]

    print(
        f"\n→ Cancelando {target['id']} (status actual: {target.get('status')})…"
    )
    try:
        updated = cancel_order(args.base_url, token, target["id"], args.reason)
        print(f"  ✓ Status nuevo: {updated.get('status')}")
        print(f"  ✓ Reason: {updated.get('cancel_reason')}")
        print("\n→ Si tu app está corriendo, revisá:")
        print("  - La campana suma 1 al badge.")
        print("  - /notifications muestra la entrada nueva.")
        print(
            "  - Si tenías abierto el detail de esa orden, el timeline pasó a 'Cancelado'."
        )
        return 0
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"  FAIL HTTP {e.code}: {body[:200]}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
