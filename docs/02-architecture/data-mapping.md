# Frontend Data Mapping & Adapter Guidelines

## Core Rule

UI components MUST NEVER consume raw backend API payloads directly. All incoming API responses must pass through an Adapter Layer (mapper function or entity) before reaching frontend state or presentation components.

**HTTP Client:** Frontend services must call the API via a shared **Axios** instance (e.g. `api`). Do not use raw `fetch` for application API traffic.

## Objectives

1. **Shield UI from API Drifts:** Prevents backend schema modifications or key renames from breaking frontend components.
2. **Safe Defaults:** Enforce safe fallback values for missing, null, or optional API fields (`??` / optional chaining—not `||` for possibly-valid falsy values).
3. **Encapsulate Computed Logic:** Keep UI getters (e.g., `fullName`, `isExpired`) inside domain models/mappers rather than repeating logic across views.

---

## 1. Single Entity Pattern

### Raw Backend Payload Example

```json
{
    "id": 1,
    "first_name": "Josh",
    "last_name": "Dolor",
    "birth_date": "1990-01-01"
}
```

### Frontend Entity / Adapter Definition

```typescript
type UserPayload = {
    id?: number | null;
    first_name?: string | null;
    last_name?: string | null;
    birth_date?: string | null;
};

export class User {
    readonly id: number | null;
    readonly firstName: string;
    readonly lastName: string;
    readonly birthDate: Date | null;

    constructor(data: UserPayload = {}) {
        this.id = data.id ?? null;
        this.firstName = data.first_name ?? '<not given>';
        this.lastName = data.last_name ?? '';
        this.birthDate = data.birth_date ? new Date(data.birth_date) : null;
    }

    get fullName(): string {
        return `${this.firstName} ${this.lastName}`.trim();
    }
}
```

### Usage in Service Layer & Components

```typescript
// Service
export async function getUser(id: number): Promise<User> {
    const response = await api.get<UserPayload>(`/users/${id}`);
    return new User(response.data);
}

// UI Component
const user = await getUser(1);
console.log(user.fullName); // "Josh Dolor"
```

---

## 2. Collection / Many Items Pattern

### Raw Backend Payload Example

```json
{
    "data": [
        {
            "id": 1,
            "first_name": "Josh",
            "last_name": "Dolor",
            "birth_date": "1990-01-01"
        },
        {
            "id": 2,
            "first_name": "Jane",
            "last_name": "Doe",
            "birth_date": null
        }
    ],
    "pagination": {
        "total_records": 2,
        "current_page": 1,
        "per_page": 15
    }
}
```

### Collection Adapter Definition

```typescript
import { User, type UserPayload } from './User';

type UsersListPayload = {
    data?: UserPayload[];
    pagination?: {
        total_records?: number;
        current_page?: number;
        per_page?: number;
    };
};

export class UserCollection {
    readonly items: User[];
    readonly total: number;
    readonly page: number;
    readonly perPage: number;

    constructor(payload: UsersListPayload = {}) {
        const rawItems = Array.isArray(payload.data) ? payload.data : [];
        this.items = rawItems.map((item) => new User(item));

        const meta = payload.pagination ?? {};
        this.total = meta.total_records ?? 0;
        this.page = meta.current_page ?? 1;
        this.perPage = meta.per_page ?? 10;
    }

    get isEmpty(): boolean {
        return this.items.length === 0;
    }

    get hasMorePages(): boolean {
        return this.page * this.perPage < this.total;
    }
}
```

### Usage in Service Layer & Components

```typescript
// Service
export async function fetchUsers(page = 1): Promise<UserCollection> {
    const response = await api.get<UsersListPayload>(`/users?page=${page}`);
    return new UserCollection(response.data);
}

// UI Component
const collection = await fetchUsers(1);

if (collection.isEmpty) {
    showEmptyState();
} else {
    for (const user of collection.items) {
        console.log(user.fullName);
    }
}
```

---

## AI Agent Instruction Requirements

- When generating API integration logic or data hooks, always construct an explicit Adapter / Entity mapping function or class in TypeScript.
- Prefer `??` and optional chaining for missing values.
- Do not access snake_case backend keys directly inside frontend UI components.
