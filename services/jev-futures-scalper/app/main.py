"""Read-only public market-data service; deliberately no order execution."""

from __future__ import annotations

import asyncio
import json
import logging
import os
import sqlite3
import time
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any

import websockets
from fastapi import FastAPI, Response

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger("jev-futures-scalper")

PAPER_MODE = os.getenv("PAPER_MODE", "true").strip().lower()
SYMBOL = os.getenv("SYMBOL", "btcusdt").strip().lower()
MAX_LEVERAGE = float(os.getenv("MAX_LEVERAGE", "3"))
DATA_DIR = Path(os.getenv("DATA_DIR", "/tmp/jev-scalper-data"))
DB_PATH = DATA_DIR / "events.sqlite3"
STREAM_URL = f"wss://stream.binance.com:9443/ws/{SYMBOL}@bookTicker"

state: dict[str, Any] = {
    "started_at": None,
    "feed_connected": False,
    "last_message_at": None,
    "last_ticker": None,
    "last_error": None,
    "database_ready": False,
}


def initialize_database() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(DB_PATH) as connection:
        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS service_events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                created_at REAL NOT NULL,
                event_type TEXT NOT NULL,
                details TEXT NOT NULL
            )
            """
        )
        connection.commit()
    state["database_ready"] = True


def record_event(event_type: str, details: dict[str, Any]) -> None:
    try:
        with sqlite3.connect(DB_PATH, timeout=3) as connection:
            connection.execute(
                "INSERT INTO service_events (created_at, event_type, details) VALUES (?, ?, ?)",
                (time.time(), event_type, json.dumps(details, separators=(",", ":"))),
            )
            connection.commit()
    except sqlite3.Error:
        logger.exception("Could not persist service event")


async def public_market_feed() -> None:
    delay = 1.0
    while True:
        try:
            logger.info("Connecting to public Spot book-ticker stream for %s", SYMBOL)
            async with websockets.connect(
                STREAM_URL, ping_interval=20, ping_timeout=20, close_timeout=5
            ) as socket:
                state["feed_connected"] = True
                state["last_error"] = None
                record_event("feed_connected", {"symbol": SYMBOL, "stream": "spot"})
                delay = 1.0
                async for raw_message in socket:
                    message = json.loads(raw_message)
                    state["last_ticker"] = {
                        "symbol": SYMBOL.upper(),
                        "bid": float(message["b"]),
                        "bid_quantity": float(message["B"]),
                        "ask": float(message["a"]),
                        "ask_quantity": float(message["A"]),
                        "source": "Binance public Spot bookTicker",
                    }
                    state["last_message_at"] = time.time()
        except asyncio.CancelledError:
            raise
        except Exception as exc:
            state["feed_connected"] = False
            state["last_error"] = type(exc).__name__
            record_event("feed_error", {"error_type": type(exc).__name__})
            logger.warning("Market feed unavailable (%s); retrying in %.1fs", type(exc).__name__, delay)
            await asyncio.sleep(delay)
            delay = min(delay * 2, 30.0)
        finally:
            state["feed_connected"] = False


@asynccontextmanager
async def lifespan(_: FastAPI):
    if PAPER_MODE != "true":
        raise RuntimeError("Safety lock: PAPER_MODE must be exactly true")
    if MAX_LEVERAGE > 3 or MAX_LEVERAGE <= 0:
        raise RuntimeError("Safety lock: MAX_LEVERAGE must be in (0, 3]")
    if not SYMBOL.isalnum():
        raise RuntimeError("SYMBOL must contain only letters and digits")

    initialize_database()
    state["started_at"] = time.time()
    feed_task = asyncio.create_task(public_market_feed())
    try:
        yield
    finally:
        feed_task.cancel()
        try:
            await feed_task
        except asyncio.CancelledError:
            pass


app = FastAPI(
    title="JEV Futures Scalper — Read-only Scaffold",
    version="0.1.0",
    lifespan=lifespan,
)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/ready")
async def ready(response: Response) -> dict[str, Any]:
    is_ready = state["database_ready"] and PAPER_MODE == "true"
    if not is_ready:
        response.status_code = 503
    return {"ready": is_ready, "paper_mode": PAPER_MODE == "true"}


@app.get("/status")
async def status() -> dict[str, Any]:
    now = time.time()
    last_message_at = state["last_message_at"]
    return {
        "mode": "read_only_paper",
        "paper_mode": PAPER_MODE == "true",
        "orders_enabled": False,
        "exchange_credentials_loaded": False,
        "max_leverage_design_ceiling": MAX_LEVERAGE,
        "symbol": SYMBOL.upper(),
        "feed_connected": state["feed_connected"],
        "last_message_age_seconds": round(now - last_message_at, 3)
        if last_message_at is not None
        else None,
        "last_ticker": state["last_ticker"],
        "last_error": state["last_error"],
        "database_ready": state["database_ready"],
    }
