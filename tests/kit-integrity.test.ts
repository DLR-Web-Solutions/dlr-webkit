import { describe, expect, test } from 'bun:test';
import { existsSync } from 'node:fs';
import { join } from 'node:path';

const root = join(import.meta.dir, '..');

describe('kit integrity', () => {
    test('required agent and context files exist', () => {
        for (const rel of [
            '.cursorrules',
            'CLAUDE.md',
            'docs/00-context/project.md',
            'bin/doctor.sh',
            'bin/verify.sh',
            'Dockerfile',
            'docker-compose.yml',
            '.env.example',
        ]) {
            expect(existsSync(join(root, rel))).toBe(true);
        }
    });

    test('package scripts expose doctor and verify', async () => {
        const pkg = await Bun.file(join(root, 'package.json')).json();
        expect(pkg.scripts.doctor).toContain('doctor');
        expect(pkg.scripts.verify).toContain('verify');
        expect(pkg.packageManager).toMatch(/^bun@/);
    });

    test('compose does not default DB password to secret or use version-flag healthcheck', async () => {
        const compose = await Bun.file(join(root, 'docker-compose.yml')).text();
        const withoutComments = compose
            .split('\n')
            .filter((line) => !/^\s*#/.test(line))
            .join('\n');
        expect(withoutComments).not.toMatch(
            /DB_PASSWORD:-\s*secret|POSTGRES_PASSWORD:-\s*secret/,
        );
        expect(withoutComments).not.toMatch(/--version/);
        expect(compose).toContain('/health');
        expect(compose).toMatch(/DB_PASSWORD:\?/);
    });

    test('health template responds on /health', async () => {
        const port = 18765;
        const proc = Bun.spawn(['bun', 'src/server/health.ts'], {
            cwd: root,
            env: { ...process.env, PORT: String(port) },
            stdout: 'ignore',
            stderr: 'ignore',
        });
        try {
            let ok = false;
            for (let i = 0; i < 20; i++) {
                await Bun.sleep(50);
                try {
                    const res = await fetch(`http://127.0.0.1:${port}/health`);
                    if (res.ok) {
                        ok = true;
                        break;
                    }
                } catch {
                    // not ready yet
                }
            }
            expect(ok).toBe(true);
        } finally {
            proc.kill();
            await proc.exited;
        }
    });
});
