import pytest

from app.risk import estimate_position


def test_position_estimate_uses_quarter_percent_risk_budget() -> None:
    estimate = estimate_position(equity=200, stop_distance_pct=0.2)
    assert estimate.risk_budget == pytest.approx(0.5)
    assert estimate.notional == pytest.approx(250)
    assert estimate.estimated_margin_at_max_leverage == pytest.approx(250 / 3)


def test_position_notional_is_capped_by_leverage_ceiling() -> None:
    estimate = estimate_position(
        equity=200,
        stop_distance_pct=0.01,
        max_leverage=3,
    )
    assert estimate.notional == pytest.approx(600)


@pytest.mark.parametrize(
    "kwargs",
    [
        {"equity": 0, "stop_distance_pct": 0.2},
        {"equity": 200, "stop_distance_pct": 0},
        {"equity": 200, "stop_distance_pct": 0.2, "risk_per_trade_pct": 0.3},
        {"equity": 200, "stop_distance_pct": 0.2, "max_leverage": 3.1},
    ],
)
def test_invalid_risk_inputs_are_rejected(kwargs: dict[str, float]) -> None:
    with pytest.raises(ValueError):
        estimate_position(**kwargs)
