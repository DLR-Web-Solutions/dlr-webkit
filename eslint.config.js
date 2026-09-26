import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
    js.configs.recommended,
    ...tseslint.configs.recommended,
    {
        files: ['**/*.{js,mjs,cjs,ts,tsx}'],
        rules: {
            // Import & Module Standards
            '@typescript-eslint/no-require-imports': 'error',
            'no-var': 'error',
            'prefer-const': 'error',
            'no-duplicate-imports': 'error',

            // Formatting Rules
            indent: ['error', 4, { SwitchCase: 1 }],
            quotes: ['error', 'single', { avoidEscape: true }],
            semi: ['error', 'always'],
            'comma-dangle': ['error', 'always-multiline'],
        },
    },
    {
        ignores: ['dist/', 'node_modules/', 'vendor/', 'public/build/'],
    },
);
