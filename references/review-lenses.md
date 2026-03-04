# Review Lenses

Load only the sections that match the change.

## Always

Check these on every non-trivial diff:

- requirements drift
- broken error handling
- unsafe assumptions about null, empty, or race-prone states
- missing regression coverage
- accidental dead code or debug output

## Security

- input validation and output encoding
- secret handling and config boundaries
- injection risks
- permission checks
- unsafe logging of sensitive values

## Authentication And Authorization

- weak password or token handling
- missing expiry, rotation, or revocation behavior
- broken access control or IDOR paths
- insecure cookie or session settings
- privileged actions without auditability

## API And Integrations

- missing timeout, retry, or backoff behavior
- hard-coded endpoints
- incomplete handling of 4xx and 5xx responses
- leaking provider-specific failures through user-facing messages
- resource cleanup for long-lived connections

## Database

- N+1 or unbounded query patterns
- migration compatibility
- transaction boundaries
- locking or consistency risks
- missing indexes for new access patterns

## Concurrency

- races around shared mutable state
- incorrect async ordering
- deadlock or starvation paths
- retry logic that amplifies load

## Caching

- stale reads after writes
- missing invalidation
- cache key collisions
- tenant or user data leakage across keys

## Messaging

- idempotency gaps
- ordering assumptions
- poison message handling
- retry loops without back-pressure

## Infrastructure

- environment-specific assumptions
- CI or deployment breakage
- missing observability for new background work
- resource limits and startup sequencing

## UX And Product

- surprising behavior changes
- broken happy-path flow
- inconsistent error copy
- accessibility or localization regressions in user-facing surfaces

## Finding Format

Use this shape when reporting issues:

```text
SEVERITY: CRITICAL | HIGH | MEDIUM | LOW
FILE: path/to/file:line
ISSUE: concise description
RECOMMENDATION: concrete fix
```
