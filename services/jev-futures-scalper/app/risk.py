"""Pure risk calculations. This module never communicates with an exchange."""

from dataclasses import dataclass


@dataclass(frozen=True)
class PositionEstimate:
    risk_budget: float
    stop_distance_pct: float
    notional: float
    estimated_margin_at_max_leverage: float


def estimate_position(
    *,
    equity: float,
    stop_distance_pct: float,
    risk_per_trade_pct: float = 0.25,
    max_leverage: float = 3.0,
) -> PositionEstimate:
    """Estimate position size from equity and stop distance; no order is created.

    Percentages are supplied as percentage points: e.g. 0.2 means 0.2%.
    The notional is capped at equity * max_leverage. Fees and slippage are not
    included, so this is only an upper-bound illustration, not a trade signal.
    """
    if equity <= 0:
        raise ValueError("equity must be positive")
    if stop_distance_pct <= 0:
        raise ValueError("stop_distance_pct must be positive")
    if not 0 < risk_per_trade_pct <= 0.25:
        raise ValueError("risk_per_trade_pct must be in (0, 0.25]")
    if not 0 < max_leverage <= 3:
        raise ValueError("max_leverage must be in (0, 3]")

    risk_budget = equity * risk_per_trade_pct / 100
    raw_notional = risk_budget / (stop_distance_pct / 100)
    notional = min(raw_notional, equity * max_leverage)

    return PositionEstimate(
        risk_budget=risk_budget,
        stop_distance_pct=stop_distance_pct,
        notional=notional,
        estimated_margin_at_max_leverage=notional / max_leverage,
    )
