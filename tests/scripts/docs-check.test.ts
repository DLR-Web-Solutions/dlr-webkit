import { describe, expect, test } from 'bun:test';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';

const root = join(import.meta.dir, '..', '..');
const script = join(root, 'bin', 'docs-check');

function git(cwd: string, args: string[]): string {
    const result = Bun.spawnSync(['git', ...args], {
        cwd,
        env: {
            ...process.env,
            GIT_AUTHOR_NAME: 'Test',
            GIT_AUTHOR_EMAIL: 'test@example.com',
            GIT_COMMITTER_NAME: 'Test',
            GIT_COMMITTER_EMAIL: 'test@example.com',
        },
        stdout: 'pipe',
        stderr: 'pipe',
    });
    if (result.exitCode !== 0) {
        throw new Error(
            `git ${args.join(' ')} failed: ${result.stderr.toString()}`,
        );
    }
    return result.stdout.toString().trim();
}

function makeRepo(): string {
    const dir = mkdtempSync(join(tmpdir(), 'dlr-docs-check-'));
    git(dir, ['init', '-q']);
    git(dir, ['config', 'user.name', 'Test']);
    git(dir, ['config', 'user.email', 'test@example.com']);
    return dir;
}

function writeRepoFile(dir: string, rel: string, content = 'x\n'): void {
    const path = join(dir, rel);
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, content);
}

function stage(dir: string, rel: string): void {
    writeRepoFile(dir, rel);
    git(dir, ['add', rel]);
}

function runCheck(dir: string, args: string[]) {
    return Bun.spawnSync([script, ...args], {
        cwd: dir,
        env: process.env,
        stdout: 'pipe',
        stderr: 'pipe',
    });
}

function output(result: ReturnType<typeof runCheck>): string {
    return `${result.stdout.toString()}${result.stderr.toString()}`;
}

function withRepo(run: (dir: string) => void): void {
    const dir = makeRepo();
    try {
        run(dir);
    } finally {
        rmSync(dir, { recursive: true, force: true });
    }
}

describe('bin/docs-check', () => {
    test('blocks a business-code change without docs', () => {
        withRepo((dir) => {
            stage(dir, 'src/feature.ts');
            const result = runCheck(dir, ['--staged']);
            const text = output(result);
            expect(result.exitCode).toBe(1);
            expect(text).toContain('docs/');
            expect(text).toContain('[no-docs]');
            expect(text).toContain('src/feature.ts');
        });
    });

    test('allows a business-code change that includes docs', () => {
        withRepo((dir) => {
            stage(dir, 'src/feature.ts');
            stage(dir, 'docs/feature.md');
            const result = runCheck(dir, ['--staged']);
            expect(result.exitCode).toBe(0);
        });
    });

    test('allows the [no-docs] escape in the commit message', () => {
        withRepo((dir) => {
            stage(dir, 'src/feature.ts');
            const message = join(dir, 'message.txt');
            writeFileSync(
                message,
                'feat: refactor internals [no-docs]\n\nNo behavior change.\n',
            );
            const result = runCheck(dir, [
                '--staged',
                '--message-file',
                message,
            ]);
            expect(result.exitCode).toBe(0);
            expect(output(result)).toContain('skipped');
        });
    });

    test('allows a test-only change', () => {
        withRepo((dir) => {
            stage(dir, 'tests/feature.test.ts');
            const result = runCheck(dir, ['--staged']);
            expect(result.exitCode).toBe(0);
        });
    });

    test('blocks deploy and src changes without docs', () => {
        withRepo((dir) => {
            stage(dir, 'deploy/config.yml');
            stage(dir, 'src/feature.ts');
            const result = runCheck(dir, ['--staged']);
            expect(result.exitCode).toBe(1);
            expect(output(result)).toContain('deploy/config.yml');
        });
    });

    test('exits silently when nothing is staged', () => {
        withRepo((dir) => {
            const result = runCheck(dir, ['--staged']);
            expect(result.exitCode).toBe(0);
            expect(output(result)).toBe('');
        });
    });
});
