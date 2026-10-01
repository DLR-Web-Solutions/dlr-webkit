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
});
