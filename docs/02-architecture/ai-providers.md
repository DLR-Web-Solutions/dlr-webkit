# AI Provider Architecture

Use this **only** when the product itself calls LLMs. Do not scaffold AI infrastructure into unrelated apps.

## Layering

```
Application / services
        ↓
AI service interface (port)
        ↓
Provider adapter (OpenAI | Anthropic | Gemini | Ollama | …)
        ↓
HTTP / SDK
```

Business logic must not import a single vendor SDK directly across the codebase. Keep one interface (e.g. `generateText`, `generateObject`) and swap adapters via config.

## Configuration

```env
AI_PROVIDER=ollama
AI_MODEL=llama3.2
AI_BASE_URL=http://localhost:11434
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=
# GOOGLE_API_KEY=
```

Validate env with Zod. Local/dev may use Ollama; production picks a hosted provider explicitly.

## Structured output (required pattern)

```
LLM → structured output → Zod schema parse → application logic
```

Treat model text as **untrusted input**. Prefer schema-constrained decoding / tool calls / JSON mode, then `schema.parse(...)`. On failure: retry once with repair instructions or fail safely—never silently trust partial JSON.

## Prompts

- Store system prompts and templates under a dedicated folder (e.g. `src/server/ai/prompts/`), not inline in random controllers.
- Keep prompts reviewable and versionable; avoid scattering 100-line strings through business logic.
- Model params (temperature, max tokens) live next to the prompt or in named configs.

## Evaluation (minimal)

For critical classifiers or extractors, keep a small fixture set (input → expected schema / label) runnable via `bun test`. Expand only when regressions appear—do not build an eval platform in the kit.
