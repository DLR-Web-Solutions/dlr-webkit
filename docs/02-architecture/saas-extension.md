# SaaS Extension Notes

The kit stays **single-tenant friendly by default**. Multi-tenancy is an extension—not a forced base layer.

## Build now (typical)

- Users, sessions/auth, roles/permissions
- Clear ownership columns (`user_id`) where resources are private
- Soft deletes on core domain models when audit/recovery matters

## Add when product requires

| Concern               | Guidance                                                                                     |
| :-------------------- | :------------------------------------------------------------------------------------------- |
| Organizations / teams | `organizations` + membership table; scope queries by org                                     |
| Tenants               | Explicit `tenant_id` on tenant-owned rows; enforce in repositories/services—never only in UI |
| Subscriptions         | Billing domain module (`repositories/billing/…`); keep payment provider behind an interface  |
| Entitlements          | Feature flags / plan limits checked server-side                                              |

## Rules

- Do not invent tenant tables during `/init` unless the user asked for multi-tenancy.
- When tenancy exists, repositories must filter by tenant on every query; add automated tests for isolation.
- Prefer modular domain folders over a premature “platform” microservice.
