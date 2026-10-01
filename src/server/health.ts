/**
 * Minimal liveness endpoint for container healthchecks and local smoke runs.
 * Consumer apps should replace or extend this with real readiness (DB, etc.).
 *
 * Run: bun src/server/health.ts
 * Probe: GET /health  → 200 ok
 *         GET /ready  → 200 ok (template; wire dependency checks in real apps)
 */
const port = Number(process.env.PORT ?? process.env.CONTAINER_PORT ?? 8000);

const server = Bun.serve({
    port,
    fetch(request) {
        const { pathname } = new URL(request.url);

        if (pathname === '/health') {
            return new Response('ok', {
                status: 200,
                headers: { 'content-type': 'text/plain; charset=utf-8' },
            });
        }

        if (pathname === '/ready') {
            // Template readiness: always ok. Real apps should verify DB/deps here.
            return new Response('ok', {
                status: 200,
                headers: { 'content-type': 'text/plain; charset=utf-8' },
            });
        }

        return new Response('not found', { status: 404 });
    },
});

console.log(`health listening on http://127.0.0.1:${server.port}`);
