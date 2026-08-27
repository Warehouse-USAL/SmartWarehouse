#!/usr/bin/env python3
"""
Conecta manualmente al WebSocket de órdenes del back como admin y se queda
escuchando eventos. Útil para verificar si el back realmente está empujando
eventos sin depender de la app.

Mientras este script corre, en otra terminal:

    python3 scripts/test-websocket.py

Y deberías ver el evento `order.updated` aparecer acá.

Uso:
    python3 scripts/listen-websocket.py
    python3 scripts/listen-websocket.py --base-url http://localhost:8080

Requiere: websockets (pip install websockets) — viene con pip por default,
si no está se instala con: pip3 install websockets
"""
from __future__ import annotations

import argparse
import asyncio
import base64
import json
import os
import sys
import urllib.request

try:
    import websockets
except ImportError:
    print("Instalá websockets: pip3 install websockets", file=sys.stderr)
    sys.exit(1)


def login(base_url: str, email: str, password: str) -> tuple[str, str]:
    """Devuelve (token, userId)."""
    body = json.dumps({"email": email, "password": password}).encode()
    req = urllib.request.Request(
        f"{base_url}/auth/login",
        data=body,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())
    token = data["token"]
    user_id = data["user"]["id"]
    # Verificación: decodificar el JWT para confirmar que el sub matchea
    parts = token.split(".")
    payload_b64 = parts[1] + "=" * (-len(parts[1]) % 4)
    payload = json.loads(base64.urlsafe_b64decode(payload_b64).decode())
    print(f"  → token sub: {payload.get('sub')}")
    print(f"  → user.id:   {user_id}")
    return token, user_id


async def listen(base_url: str, email: str, password: str) -> None:
    print(f"→ Login en {base_url}…")
    token, user_id = login(base_url, email, password)

    ws_url = base_url.replace("http", "ws", 1)
    full_url = f"{ws_url}/ws/v1/orders/{user_id}?token={token}"
    print(f"→ Conectando WS a {full_url[:80]}…\n")

    try:
        async with websockets.connect(full_url) as ws:
            print("✓ WS conectado. Esperando eventos (Ctrl+C para salir)…\n")
            async for message in ws:
                try:
                    parsed = json.loads(message)
                    event = parsed.get("event")
                    payload = parsed.get("payload", {})
                    order_id = payload.get("id") or payload.get("order_id")
                    status = payload.get("status")
                    print(f"📨 {event}: order_id={order_id} status={status}")
                except Exception:
                    print(f"📨 (raw) {message[:200]}")
    except websockets.exceptions.ConnectionClosed as e:
        print(f"\n✗ Connection closed: code={e.code} reason={e.reason!r}")
        if e.code == 1008:
            print("  (1008 suele ser auth/handshake fail — token o userId no validan)")
    except Exception as e:
        print(f"\n✗ Error: {e}")


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
    args = parser.parse_args()

    try:
        asyncio.run(listen(args.base_url, args.email, args.password))
    except KeyboardInterrupt:
        print("\n→ Salir.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
