"""
Minimal liveness endpoint for container healthchecks and local smoke runs.
Consumer apps should replace or extend this with real readiness (DB, etc.).

Run: python src/server/health.py
Probe: GET /health  → 200 ok
        GET /ready  → 200 ok (template; wire dependency checks in real apps)
"""

import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.environ.get("PORT", os.environ.get("CONTAINER_PORT", 8000)))


class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"ok")
        elif self.path == "/ready":
            # Template readiness: always ok. Real apps should verify DB/deps here.
            self.send_response(200)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(b"ok")
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"not found")

    def log_message(self, format: str, *args: object) -> None:
        # Silence default request logging
        pass


def main() -> None:
    server = HTTPServer(("0.0.0.0", PORT), HealthHandler)
    print(f"health listening on http://127.0.0.1:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down health server...")
        sys.exit(0)


if __name__ == "__main__":
    main()
