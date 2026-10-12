"""Placeholder for a future JEV/MCP research adapter.

Keep research asynchronous and separate from market-data ingestion and risk
controls. This stub deliberately has no network calls and cannot authorize trades.
"""

from typing import Any


def research_snapshot(snapshot: dict[str, Any]) -> dict[str, Any]:
    """Return an explicit not-connected result instead of inventing analysis."""
    return {
        "status": "not_configured",
        "summary": "JEV/MCP research adapter is not connected.",
        "input_received": bool(snapshot),
        "trade_authorized": False,
    }
