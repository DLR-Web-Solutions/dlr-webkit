# JEV Futures Scalper — read-only foundation

This is an isolated Python service within DLR WebKit. It is intentionally a **market-data and risk-calculation scaffold**, not a trading bot ready for live funds.

## Safety boundary

- Startup requires `PAPER_MODE=true`; any other value causes startup to fail.
- No exchange credentials are read and no private exchange endpoints are called.
- There is no order placement, modification, or cancellation code.
- The sample adapter reads **public Binance Spot BTC/USDT book-ticker data only**. It is not a futures feed and does not prove that Binance Futures is available to your account in Spain.
- `MAX_LEVERAGE=3` is a future design ceiling for risk calculations only. The service does not apply leverage or submit orders.
- The default Compose port is bound to `127.0.0.1`, not exposed to the LAN. For remote access, use your existing Tailscale access controls or a private reverse proxy; do not expose this service publicly.

## Run on the server

From the repository root:

```bash
cp services/jev-futures-scalper/.env.example services/jev-futures-scalper/.env
docker compose -f services/jev-futures-scalper/compose.yml up --build -d
curl http://127.0.0.1:8088/health
curl http://127.0.0.1:8088/status
```

Logs and shutdown:

```bash
docker compose -f services/jev-futures-scalper/compose.yml logs -f
docker compose -f services/jev-futures-scalper/compose.yml down
```

The local `.env` file is ignored by Git. Do not put API keys in it; this first milestone does not need any.

## Endpoints

- `GET /health` — process liveness.
- `GET /ready` — configuration and local database initialization.
- `GET /status` — paper mode, market-feed state, last public ticker, and data age.

## Development and tests

Use Python 3.12+ and install the pinned dependencies:

```bash
python -m venv .venv
. .venv/bin/activate
pip install -r services/jev-futures-scalper/requirements.txt
pytest -q services/jev-futures-scalper/tests
```

## Architecture boundary

JEV/MCP research is deliberately a stub in this milestone. Keep LLM research outside the market-data loop and outside any future execution path. Validate structured research output in deterministic application code; never let model text directly authorize an order.

## Next milestones

1. Confirm the exact derivatives venue/product, Spain/EEA eligibility, API access, fees, funding, minimum order size, and demo environment directly with the venue.
2. Add the chosen venue's **public demo/testnet** market-data adapter, after confirming the product and endpoint.
3. Add historical replay and backtests that include fees, spread, slippage, funding, and minimum-notional constraints.
4. Add a paper broker and tests for stale data, duplicate signals, reconnects, partial fills, and restarts.
5. Review risk controls and operational monitoring before considering a separately permissioned execution component.

With account capital below €250, fees, spread, slippage, and venue minimums can overwhelm a small scalping edge. This scaffold makes no profitability claim and must not be treated as financial advice.
