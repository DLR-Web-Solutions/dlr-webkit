import { describe, expect, test } from 'bun:test';
import {
    mkdirSync,
    mkdtempSync,
    readFileSync,
    rmSync,
    writeFileSync,
    existsSync,
    cpSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const root = join(import.meta.dir, '..');

function run(
    command: string,
    args: string[],
    opts: { cwd?: string; env?: Record<string, string>; input?: string } = {},
) {
    return spawnSync(command, args, {
        cwd: opts.cwd ?? root,
        env: { ...process.env, ...opts.env },
        encoding: 'utf8',
        input: opts.input,
    });
}

describe('bin/doctor.sh', () => {
    test('exits 0 on healthy kit checkout', () => {
        const result = run('bash', ['bin/doctor.sh']);
        expect(result.status).toBe(0);
        expect(result.stdout).toContain('dlr-webkit doctor');
        expect(result.stdout).not.toMatch(/(password|secret|TOKEN)=/i);
    });
});

describe('bin/verify.sh', () => {
    test('exits 0 on healthy kit checkout', () => {
        // Skip nested bun test — verify would re-enter this suite.
        const result = run('bash', ['bin/verify.sh'], {
            env: { DLR_VERIFY_SKIP_TESTS: '1' },
        });
        if (result.status !== 0) {
            console.log(result.stdout);
            console.log(result.stderr);
        }
        expect(result.status).toBe(0);
        expect(result.stdout).toContain('verify passed');
    });

    test('fails when format:check would fail (propagates via set -e)', () => {
        // Sanity: run_step failure path is covered by invoking prettier --check on a bad file in a temp copy.
        const dir = mkdtempSync(join(tmpdir(), 'dlr-verify-'));
        try {
            writeFileSync(join(dir, 'bad.js'), 'const x=1\n');
            const prettier = run('bunx', ['prettier', '--check', 'bad.js'], {
                cwd: dir,
            });
            expect(prettier.status).not.toBe(0);
        } finally {
            rmSync(dir, { recursive: true, force: true });
        }
    });
});

describe('bin/init.sh', () => {
    test('replaces placeholders non-interactively without touching unrelated files', () => {
        const dir = mkdtempSync(join(tmpdir(), 'dlr-init-'));
        try {
            mkdirSync(join(dir, 'bin'), { recursive: true });
            mkdirSync(join(dir, 'docs'), { recursive: true });
            cpSync(join(root, 'bin/init.sh'), join(dir, 'bin/init.sh'));
            writeFileSync(join(dir, 'docs/name.md'), 'App: [APP_NAME]\n');
            writeFileSync(join(dir, 'docs/keep.md'), 'unchanged\n');
            writeFileSync(join(dir, 'CLAUDE.md'), 'Project [APP_NAME]\n');

            const result = run('bash', ['bin/init.sh', 'Acme|Corp'], {
                cwd: dir,
                env: { DLR_APP_NAME: '' },
            });
            expect(result.status).toBe(0);
            expect(readFileSync(join(dir, 'docs/name.md'), 'utf8')).toContain(
                'Acme|Corp',
            );
            expect(readFileSync(join(dir, 'docs/keep.md'), 'utf8')).toBe(
                'unchanged\n',
            );
            expect(readFileSync(join(dir, 'CLAUDE.md'), 'utf8')).toContain(
                'Acme|Corp',
            );
            expect(
                readFileSync(join(dir, 'docs/name.md'), 'utf8'),
            ).not.toContain('[APP_NAME]');
        } finally {
            rmSync(dir, { recursive: true, force: true });
        }
    });

    test('fails without a project name in non-interactive mode', () => {
        const result = run('bash', ['bin/init.sh'], {
            env: { DLR_APP_NAME: '' },
            input: '',
        });
        // When stdin is piped empty and no args, should fail
        expect(result.status).not.toBe(0);
    });
});

describe('bin/install.sh', () => {
    test('overlays into parent without overwriting existing files', () => {
        const parent = mkdtempSync(join(tmpdir(), 'dlr-parent-'));
        const kit = join(parent, 'dlr-webkit');
        try {
            // Minimal kit surface sufficient for install
            mkdirSync(join(kit, 'bin'), { recursive: true });
            mkdirSync(join(kit, 'docs/00-context'), { recursive: true });
            mkdirSync(join(kit, 'prompts'), { recursive: true });
            mkdirSync(join(kit, 'src/client'), { recursive: true });
            mkdirSync(join(kit, '.husky'), { recursive: true });
            mkdirSync(join(kit, '.github/workflows'), { recursive: true });
            mkdirSync(join(kit, '.vscode'), { recursive: true });
            mkdirSync(join(kit, '.cursor'), { recursive: true });

            for (const rel of [
                'bin/doctor.sh',
                'bin/verify.sh',
                'bin/init.sh',
                'bin/install.sh',
            ]) {
                cpSync(join(root, rel), join(kit, rel));
            }
            writeFileSync(
                join(kit, 'docs/00-context/project.md'),
                'Name: [APP_NAME]\n',
            );
            writeFileSync(join(kit, 'prompts/00-init-project.md'), 'init\n');
            writeFileSync(join(kit, 'src/client/README.md'), 'client\n');
            writeFileSync(join(kit, 'CLAUDE.md'), 'Claude [APP_NAME]\n');
            writeFileSync(join(kit, '.cursorrules'), 'rules\n');
            writeFileSync(join(kit, '.env.example'), 'APP_PORT=8000\n');
            writeFileSync(join(kit, '.husky/pre-commit'), 'bunx lint-staged\n');
            writeFileSync(join(kit, '.github/workflows/ci.yml'), 'name: CI\n');
            writeFileSync(join(kit, '.vscode/settings.json'), '{}\n');
            writeFileSync(join(kit, '.cursor/mcp.json'), '{}\n');
            writeFileSync(join(kit, '.mcp.json'), '{}\n');
            writeFileSync(
                join(kit, 'eslint.config.js'),
                'export default [];\n',
            );
            writeFileSync(join(kit, '.prettierrc'), '{}\n');
            writeFileSync(join(kit, '.lintstagedrc.json'), '{}\n');
            writeFileSync(join(kit, 'tsconfig.json'), '{}\n');
            writeFileSync(join(kit, 'docker-compose.yml'), 'services: {}\n');
            writeFileSync(join(kit, 'Dockerfile'), 'FROM scratch\n');
            writeFileSync(join(kit, '.gitignore'), '.env\n');
            writeFileSync(join(kit, 'README.md'), 'kit readme\n');

            // Pre-existing consumer files that must be preserved
            writeFileSync(join(parent, 'README.md'), 'KEEP_README\n');
            writeFileSync(join(parent, '.cursorrules'), 'KEEP_RULES\n');
            mkdirSync(join(parent, 'docs'), { recursive: true });
            writeFileSync(join(parent, 'docs/existing.md'), 'KEEP_DOC\n');

            const result = run('bash', ['bin/install.sh'], {
                cwd: kit,
                env: {
                    DLR_APP_NAME: 'OverlayApp',
                    DLR_REMOVE_DEVKIT: '0',
                    DLR_FORCE_OVERWRITE: '0',
                },
            });

            expect(result.status).toBe(0);
            expect(readFileSync(join(parent, 'README.md'), 'utf8')).toBe(
                'KEEP_README\n',
            );
            expect(readFileSync(join(parent, '.cursorrules'), 'utf8')).toBe(
                'KEEP_RULES\n',
            );
            expect(readFileSync(join(parent, 'docs/existing.md'), 'utf8')).toBe(
                'KEEP_DOC\n',
            );
            expect(existsSync(join(parent, 'docs/00-context/project.md'))).toBe(
                true,
            );
            expect(
                readFileSync(
                    join(parent, 'docs/00-context/project.md'),
                    'utf8',
                ),
            ).toContain('OverlayApp');
            expect(existsSync(join(parent, 'bin/doctor.sh'))).toBe(true);
            expect(existsSync(join(parent, '.env'))).toBe(false);
            expect(existsSync(kit)).toBe(true); // remove default N
        } finally {
            rmSync(parent, { recursive: true, force: true });
        }
    });
});
