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

```python
from dataclasses import dataclass
from typing import Optional
from datetime import date


@dataclass
class UserPayload:
    id: Optional[int] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    birth_date: Optional[str] = None


@dataclass
class User:
    id: Optional[int]
    first_name: str
    last_name: str
    birth_date: Optional[date]

    def __init__(self, data: UserPayload = None):
        if data is None:
            data = UserPayload()

        self.id = data.id
        self.first_name = data.first_name or "<not given>"
        self.last_name = data.last_name or ""
        self.birth_date = date.fromisoformat(data.birth_date) if data.birth_date else None

    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()
```

### Usage in Service Layer & Components

```python
# Service
from typing import Dict, Any


def get_user(id: int) -> User:
    response_data: Dict[str, Any] = api.get(f"/users/{id}")
    payload = UserPayload(**response_data)
    return User(payload)


# UI Component
user = get_user(1)
print(user.full_name)  # "Josh Dolor"
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

```python
from dataclasses import dataclass, field
from typing import List, Optional
from datetime import date


@dataclass
class UserPayload:
    id: Optional[int] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    birth_date: Optional[str] = None


@dataclass
class User:
    id: Optional[int]
    first_name: str
    last_name: str
    birth_date: Optional[date]

    def __init__(self, data: UserPayload = None):
        if data is None:
            data = UserPayload()

        self.id = data.id
        self.first_name = data.first_name or "<not given>"
        self.last_name = data.last_name or ""
        self.birth_date = date.fromisoformat(data.birth_date) if data.birth_date else None

    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()


@dataclass
class UsersListPayload:
    data: Optional[List[UserPayload]] = None
    pagination: Optional[dict] = None


@dataclass
class UserCollection:
    items: List[User]
    total: int
    page: int
    per_page: int

    def __init__(self, payload: UsersListPayload = None):
        if payload is None:
            payload = UsersListPayload()

        raw_items = payload.data or []
        self.items = [User(item) for item in raw_items]

        meta = payload.pagination or {}
        self.total = meta.get("total_records", 0)
        self.page = meta.get("current_page", 1)
        self.per_page = meta.get("per_page", 10)

    @property
    def is_empty(self) -> bool:
        return len(self.items) == 0

    @property
    def has_more_pages(self) -> bool:
        return self.page * self.per_page < self.total
```

### Usage in Service Layer & Components

```python
# Service
def fetch_users(page: int = 1) -> UserCollection:
    response_data = api.get(f"/users?page={page}")
    payload = UsersListPayload(**response_data)
    return UserCollection(payload)


# UI Component
collection = fetch_users(1)

if collection.is_empty:
    show_empty_state()
else:
    for user in collection.items:
        print(user.full_name)
```

---

## AI Agent Instruction Requirements

- When generating API integration logic or data hooks, always construct an explicit Adapter / Entity mapping function or class in Python.
- Prefer `??` and optional chaining for missing values.
- Do not access snake_case backend keys directly inside frontend UI components.
