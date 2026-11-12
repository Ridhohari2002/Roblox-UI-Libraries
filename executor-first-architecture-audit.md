# Executor-First Architecture Audit — BOYFINITY Hub

**Date:** 2026-11-12
**Mode:** Audit and planning only. No implementation, migration, configuration, dependency, or commit was performed.
**Baseline:** `871bf63 feat(auth): add primary Discord owner identity` (tag `phase-3c1-accepted-baseline` at `3494e7e`)
**Authoritative sources read:** `AGENTS.md`, `IMPLEMENTATION_PLAN.md`, `DESIGN.md`, `BACKEND.md`, `supabase/migrations/0001_init.sql`, all Phase 3C.1 / owner-identity / Phase 4 reports, and the actual Phase 4 source, validators, middleware, service, crypto, idempotency, rate-limit, audit, and environment files.

**Evidence labels used in this report**

- **[VERIFIED]** — confirmed by reading the repository file named in the finding.
- **[ASSUMPTION]** — a working assumption that is not proven by the repository.
- **[RECOMMENDATION]** — a proposed change; not approved, not implemented.
- **[OWNER DECISION]** — a policy or product choice that still requires explicit owner approval.
- **[NOT VERIFIED]** — information that could not be established from the repository.

---

## 1. Executive Summary

### 1.1 Overall verdict

The current Phase 4 implementation is a **web-session-first key lifecycle**, not an executor-first license system. It is internally consistent and well guarded for its intended model, but it cannot satisfy D1 as written without schema and service changes.

The most important verified findings are:

1. **Activation and validation require a verified Discord account session.** `POST /api/keys/activate` and `POST /api/keys/validate` are declared with `access: "user"`, and `requireActor()` rejects any session without `session.user.discordId` (`src/modules/keys/service.ts:219-224`, `src/routes/keys.ts:60-104`). D1 says the key is the license identity and no Discord login is required. This is a direct conflict. **[VERIFIED]**

2. **`key_sessions.user_id` is `uuid not null references users(id)`.** A key session cannot exist without a `users` row (`0001_init.sql:361-379`). Therefore, "key without a Discord user" is possible for the `keys` row but **not** for an active key session. **[VERIFIED]**

3. **There is no product/package/entitlement model.** The only related tables are `plans` (subscription duration/price), `subscriptions` (owned by a `users` row), `keys.plan_id`, `scripts`, and `games`. There is no plan-to-script, product-to-script, key-to-product, or license-entitlement relation. **[VERIFIED]**

4. **`resolveScriptAccess()` grants every active key access to every published, enabled, non-deleted script.** It reads only `scripts.public_id`, `status`, `enabled`, and `deleted_at`; it does not receive or inspect the key, plan, product, or subscription (`src/modules/access/script-access.ts:19-33`). This violates D3. **[VERIFIED]**

5. **The admin-only HWID reset policy is structurally supported but the self-service reset still exists and is reachable.** `key_hwid_resets.performed_by` allows `self` and `admin`; `key_device_history` allows `reset_self` and `reset_admin`; the admin service writes `key.hwid_reset_admin` audit rows. The self-service route and service remain active (`src/routes/keys.ts:106-128`, `src/modules/keys/service.ts:908-1042`). D2 requires the self-service path to be retired or disabled, not merely supplemented. **[VERIFIED]**

6. **No nonce or replay store exists.** A repository-wide search of `0001_init.sql` for `nonce` returns no matches. The `replay_detected` error code exists in `src/core/errors.ts:34`, but no code path produces it. `validateSchema` is `.strict()` and accepts only `key`, `scriptId`, and optional `hwid`; it would reject `timestamp`, `nonce`, and `clientVersion` (`src/validators/keys.ts:18-24`). **[VERIFIED]**

7. **Key hashing and key-session hashing reuse `SESSION_HMAC_SECRET`.** `hashKeyValue()` and `hashKeySessionToken()` receive `getSessionSecret()` through `PostgresKeyService` (`src/modules/keys/service.ts:257-271`, `src/modules/keys/crypto.ts:21-27`). There is no `KEY_HMAC_SECRET`. Domain prefixes (`key:v1:`, `key_session:v1:`) separate the inputs, but they do not separate the root secret. Rotating `SESSION_HMAC_SECRET` invalidates account sessions, key hashes, and key sessions at once. **[VERIFIED]**

8. **Idempotent activation replay deliberately does not return the one-time session token.** `withIdempotency()` stores only `response_body` and a boolean `one_time_secret_issued`; the secret itself is never stored (`src/db/idempotency.ts:88-102`). The Phase 4 test asserts that a replay has no `keySessionToken` (`test/keys-service.test.ts:111-128`). For an executor, a lost activation response therefore cannot be recovered by replaying the same `Idempotency-Key`. **[VERIFIED]**

9. **The key session lifetime and idle window are both 30 minutes, and the absolute expiry never moves.** `KEY_SESSION_TTL_MS` and `KEY_SESSION_IDLE_MS` are both 30 minutes; validation extends `last_seen_at` but not `expires_at` (`src/modules/keys/service.ts:30-31, 858-862`). A long-running executor session cannot survive on this policy without re-activation. **[VERIFIED]**

10. **The schema does not bind a key session to an HWID hash.** `key_sessions` stores only `hwid_fingerprint` (a 12-character prefix), and validation does not compare the session's fingerprint with the presented HWID. It compares the presented HWID only against `keys.bound_hwid_hash` (`0001_init.sql:361-373`, `src/modules/keys/service.ts:725-762`). A stolen session token can therefore be used from another device until the key-level HWID check is triggered. **[VERIFIED]**

### 1.2 What can be reused

- Key generation, hashing, key prefix, and one-time plaintext behavior.
- The transactional activation skeleton: row lock, terminal status gate, expiry gate, session supersession, session insertion, audit.
- Idempotency and rate-limit stores.
- HWID normalization, HMAC, and fingerprinting (D5 v1).
- Admin revoke, admin reset, device history, and audit actions.
- The stable denial-code concept, with a redesigned executor error surface.

### 1.3 What cannot be reused unchanged

- Account-session requirement on activation and validation.
- `key_sessions.user_id NOT NULL`.
- `validateSchema` and the current validation flow (no timestamp, nonce, client version, entitlement, or session/HWID binding).
- `resolveScriptAccess()` (all-scripts access).
- The current one-time-token replay behavior.
- The 30-minute absolute executor session.
- `SESSION_HMAC_SECRET` as the key hash root secret.

### 1.4 Scope boundary

This audit does **not** authorize implementation. It does not begin Phase 5, does not remove Discord OAuth, does not weaken admin authorization, does not change any role policy, and does not modify `.env.local`, `.env.example`, migrations, dependencies, or source code. The only file added is this report.

---

## 2. Confirmed Decisions D1, D2, D3

### 2.1 D1 — Bearer License

**Owner decision, confirmed.**

- The license key is the license identity.
- The user does not need a Discord login.
- The key does not have to be linked to `users.discord_id`.
- The first successful activation claims the license under a policy still to be chosen.
- The key is a secret credential and must be treated as such.

**Verified repository conflict**

| Requirement | Actual state | Conflict |
|---|---|---|
| No Discord login for activation | Route `access: "user"`; pipeline requires a session cookie; `requireActor` requires `session.user.discordId` | **Hard conflict** |
| Key session without `users` row | `key_sessions.user_id uuid not null references users(id)` | **Hard schema conflict** |
| Key identity independent of Discord | `keys.owner_discord_id` and `keys.user_id` are nullable, so the `keys` row itself can be unowned. But activation writes both and validation compares `owner_discord_id`. | **Service conflict** |
| First successful activation claims the license | Current logic allows an unowned key only if the caller is a Discord user; it writes `owner_discord_id` and `user_id`. There is no executor claim record. | **No claim model** |
| Key treated as a secret credential | Plaintext is returned once and stored as HMAC; but it is sent in the request body on every activation/validation. No dedicated key secret. | **Partial; needs dedicated secret and log discipline** |

**Important correction:** there is no `keys.owner_user_id` column in the repository. The actual columns are `owner_discord_id text` (nullable) and `user_id uuid references users(id)` (nullable). Any plan that says "remove `owner_user_id`" is based on a name that does not exist. **[VERIFIED]**

### 2.2 D2 — Admin-only HWID Reset

**Owner decision, confirmed.**

- Users cannot reset their own HWID.
- Only an authenticated admin/owner through the dashboard/admin API may reset.
- Every reset must have an audit log.
- Existing tables/services must be checked before removal.
- Do not delete the old implementation before impact analysis.

**Verified support**

| Capability | Actual state | Assessment |
|---|---|---|
| Admin reset service | `adminResetHwid()` exists and locks the key, clears binding, increments counter, revokes sessions, writes `key_hwid_resets` with `performed_by='admin'`, `key_device_history('reset_admin')`, and `audit_logs('key.hwid_reset_admin')` | **Supported** |
| Admin actor identity | `key_hwid_resets.admin_id` references `users(id)`; route uses `access:"admin"` and `hasAdminAccess()` accepts `admin` or `owner` | **Supported** |
| Audit trail | `audit_logs` row with `actor_user_id` = admin user id, `target_type='key'`, `target_id` = key UUID | **Supported** |
| Self-service path | `POST /api/keys/reset-hwid` and `resetHwid()` remain active | **Must be disabled or retired under D2** |
| Admin reset idempotency | No `Idempotency-Key` requirement and no idempotency wrapper on the admin route | **Gap** |
| Admin reset rate limiting | No `rateLimit` on the admin reset route | **Gap** |
| Dedicated permission | No `key.hwid_reset_admin` entry in `PERMISSION_ROLES`; only `hasAdminAccess()` gate | **Policy gap** |

**Impact of removal**

- Existing users may have used self-service reset; their `key_hwid_resets` rows have `performed_by='self'` and `user_id` set.
- The self-service path is referenced by tests (`test/keys-http.test.ts`, `test/keys-service.test.ts`).
- Removing it immediately would break those tests and any dashboard UI that calls it.
- Recommended transition is: disable by default, keep the service and history for reads, add explicit admin-only path, then remove the public route after the owner approves a deprecation window.

### 2.3 D3 — License-to-Script Mapping

**Owner decision, confirmed.**

- Script access must be determined by the license package/product.
- An active key must not automatically access every published/enabled script.
- Existing product/plan/license/script relations must be inspected.
- If absent, identify required tables and constraints.
- The recommendation must be consistent with the catalog and product architecture.

**Verified repository reality**

- `plans` exists, but it models subscription duration and price: `code`, `name`, `duration_days`, `price_minor`, `currency`, `active`.
- `keys.plan_id` references `plans(id)`.
- `subscriptions` references `plans(id)` and `users(id)`.
- `scripts` has `public_id`, `game_id`, `status`, `enabled`, `deleted_at`, and a current version, but no product or package relation.
- There is no `products`, `packages`, `bundles`, `entitlements`, `plan_scripts`, `product_scripts`, or `key_entitlements` table.
- `resolveScriptAccess()` does not take a key or plan and does not join any entitlement.

**Conclusion:** D3 requires new schema and a new authorization query. It cannot be implemented by changing a condition in the current query alone.

---

## 3. Actual Implementation Map

### 3.1 Request pipeline

| Layer | File | Actual behavior |
|---|---|---|
| Route definition | `src/http/router.ts` | Matches method and path; route declares `access`, optional `csrf`, optional `rateLimit` |
| API pipeline | `src/http/app.ts` | Resolves request ID, matches route, resolves session, enforces `user`/`admin` access, CSRF for unsafe session routes, rate limit, handler, unified error surface, access log |
| Session resolver | `src/modules/auth/service.ts:388-452` | Reads `bf_session` cookie, hashes token, loads `sessions` row, checks `revoked_at`, `status`, idle and absolute expiry, rotates token, derives roles from `user_roles` plus configured owner |
| Session context | `src/middleware/session.ts` | `userId`, `roles`, `csrfToken`, `user { id, discordId, username, avatarUrl }` |
| Admin gate | `src/modules/auth/permissions.ts:27-29` | `hasAdminAccess()` accepts `admin` or `owner` |
| Owner derivation | `src/modules/auth/owner.ts:24-33` | Configured `DISCORD_OWNER_ID` adds `owner` to the verified user's roles |
| Validation | `src/middleware/validation.ts` | Zod safeParse; returns only issue paths/messages, never values |
| Body limit | `src/middleware/body-limit.ts` | 1 MiB default, JSON content type, Content-Length and decoded-byte checks |

### 3.2 Key routes

All routes are registered by `src/routes/index.ts` through `keyRoutes(service)`.

| Method | Path | Access | Rate limit | Handler behavior |
|---|---|---|---|---|
| POST | `/api/keys/activate` | user | per user 10/min, per IP 30/min | Requires `Idempotency-Key`, calls `activate()` |
| POST | `/api/keys/validate` | user | per user 120/min, per IP 240/min | Requires Bearer token, calls `validate()` |
| POST | `/api/keys/reset-hwid` | user | per user 5/min, per IP 15/min | Requires `Idempotency-Key`, calls `resetHwid()` |
| GET | `/api/keys/me` | user | none | Lists keys by `owner_discord_id` |
| GET | `/api/keys/:id/usage` | user | none | Owner check, aggregate `script_access_logs` |
| GET | `/api/keys/:id/devices` | user | none | Owner check, device history |
| POST | `/api/admin/keys` | admin | none | Bulk generate keys |
| GET | `/api/admin/keys` | admin | none | Filter by status, type, owner Discord ID |
| POST | `/api/admin/keys/:id/revoke` | admin | none | Revoke key and sessions |
| POST | `/api/admin/keys/:id/reset-hwid` | admin | none | Admin HWID reset |
| GET | `/api/admin/keys/:id/devices` | admin | none | Device history |

### 3.3 Key service

`src/modules/keys/service.ts`

| Method | Purpose | Critical behavior |
|---|---|---|
| `generateKeys()` | Bulk key creation | 256-bit plaintext `bf_` + 64 hex; stores HMAC and 11-char prefix; plaintext returned once |
| `activate()` | Claim key, bind HWID, issue session | Row lock; terminal gate; ownership gate; expiry gate; activation cap; reactivation consumption; supersede old session; insert session; update key; device history; audit |
| `validate()` | Authoritative access decision | Key hash lookup; terminal gate; active gate; owner gate; expiry and subscription gate; HWID gate; session existence/status/expiry/idle gate; script lookup; grant log; `last_seen_at`; audit |
| `resetHwid()` | Self-service reset | Row lock; owner gate; terminal gate; active gate; cooldown and cap; clear binding; revoke sessions; history and audit |
| `listOwnKeys()` | Owner key list | `where owner_discord_id = session.user.discordId` |
| `keyUsage()` | Owner usage | Owner gate, count grants and distinct scripts |
| `keyDevices()` | Owner device history | Owner gate |
| `adminListKeys()` | Admin list | Filters without a role re-check inside the service; route gate is authoritative |
| `adminRevoke()` | Admin revoke | Row lock; banned deny; idempotent already-revoked response; revoke sessions; history and audit |
| `adminResetHwid()` | Admin reset | Row lock; banned deny; active gate; clear binding; revoke sessions; history and audit |
| `adminDevices()` | Admin device history | No owner check; route gate is authoritative |

### 3.4 Access, crypto, and stores

| Module | File | Actual behavior |
|---|---|---|
| Script access | `src/modules/access/script-access.ts` | Selects `scripts` by `public_id`, requires `status='published'`, `enabled=true`, `deleted_at is null` |
| Key crypto | `src/modules/keys/crypto.ts` | `createPlaintextKey()`, `keyDisplayPrefix()`, `hashKeyValue()` with `key:v1:` domain, `hashKeySessionToken()` with `key_session:v1:` domain |
| HWID crypto | `src/core/crypto/hwid.ts` | NFKC, trim, lowercase, remove separators, require 8-128 alphanumeric, HMAC `hwid:v1:`, 12-char fingerprint |
| Idempotency | `src/db/idempotency.ts` | Claim row in same transaction as mutation; unique `(scope, key_hash)`; request hash; replay safe body; one-time secret never stored |
| Rate limit | `src/db/rate-limit-store.ts` | Fixed window, transaction per multi-dimension check, HMAC bucket identifiers, fail-closed default |
| Audit | `src/modules/keys/audit.ts` | Inserts `audit_logs` with `target_type='key'`; actions enumerated below |
| Key errors | `src/modules/keys/errors.ts` | Stable code, generic message; session codes map to 401, other key denials to 403 |

### 3.5 Key audit actions actually defined

`key.generate`, `key.activate`, `key.activate_failed`, `key.validate`, `key.validate_failed`, `key.hwid_reset`, `key.hwid_reset_failed`, `key.hwid_reset_admin`, `key.hwid_reset_admin_failed`, `key.revoke`, `key.revoke_failed`, `key.ban_reactivation_consumed`.

There is no executor-specific action such as session revocation or nonce replay.

---

## 4. Old API Contract Audit

### 4.1 Contract summary

| Endpoint | Auth actually required | CSRF | Idempotency | Rate limit | Contract issue for executor-first |
|---|---|---|---|---|---|
| `POST /api/keys/activate` | Account session cookie with verified Discord user | Required for unsafe session route | Required `Idempotency-Key` | 10/user/min, 30/IP/min | Cannot be called without Discord; body is strict and rejects `scriptId`, `clientVersion` |
| `POST /api/keys/validate` | Account session **and** Bearer key-session token | Required for unsafe session route | None | 120/user/min, 240/IP/min | Requires Discord user; no nonce, timestamp, client version, or entitlement |
| `POST /api/keys/reset-hwid` | Account session and key owner | Required | Required `Idempotency-Key` | 5/user/min, 15/IP/min | Violates D2 because user can self-reset |
| `GET /api/keys/me` | Account session | Not applicable | None | None | Dashboard-only; acceptable to keep |
| `GET /api/keys/{id}/usage` | Account session and key owner | Not applicable | None | None | Dashboard-only; acceptable to keep |
| `GET /api/keys/{id}/devices` | Account session and key owner | Not applicable | None | None | Dashboard-only; acceptable to keep |
| `POST /api/admin/keys` | Admin/owner session | Required for unsafe session route | None | None | No idempotency; bulk generation can duplicate on retry |
| `GET /api/admin/keys` | Admin/owner session | Not applicable | None | None | Fine as an admin read |
| `POST /api/admin/keys/{id}/revoke` | Admin/owner session | Required | None | None | No idempotency; already-revoked is idempotent in service |
| `POST /api/admin/keys/{id}/reset-hwid` | Admin/owner session | Required | None | None | No idempotency or rate limit; D2 implementation path |
| `GET /api/admin/keys/{id}/devices` | Admin/owner session | Not applicable | None | None | Fine as an admin read |

### 4.2 Detailed findings

#### `POST /api/keys/activate`

- **Verified request schema:** `{ key: string(1..256), hwid?: string(1..512), deviceLabel?: string(trim, max 120) }`, `.strict()`.
- **Verified response:** `201` (or `200` on idempotent replay): `{ keyId, status:"active", boundAt, deviceBound, sessionExpiresAt, reactivationConsumed, keySessionToken? }`.
- **Verified service sequence:** `for update` on key; banned/revoked deny; different `owner_discord_id` deny; active deny; unused/suspended only; expiry; activation cap; optional reactivation consumption; HWID hash; supersede active sessions; insert new session with `user_id=actor.userId`; update key owner and binding; device history; audit.
- **Issues:**
  - Account session is mandatory.
  - `session.user.discordId` is mandatory.
  - `key_sessions.user_id` is mandatory.
  - `already_owned` is returned for any active key, including the same owner, so an executor cannot re-activate after losing its token.
  - `activation_count` increments on every activation and defaults to `max_activations=1`; a re-activation policy must not accidentally exhaust the cap.
  - `scriptId` is not accepted at activation, so activation cannot answer "does this license cover this script?"
  - `clientVersion` is not accepted.
  - `Idempotency-Key` replay returns the safe body without the token.
  - The request hash includes the plaintext key and raw HWID (`request: { key, hwid, deviceLabel }`). It is hashed with SHA-256, not HMAC, inside `idempotency_keys.request_hash`; the plaintext itself is not stored. This is acceptable but should be reviewed for executor logging.
  - Body size limit is 1 MiB, not a tight executor-specific cap.

#### `POST /api/keys/validate`

- **Verified request schema:** `{ key: string, scriptId: string, hwid?: string }`, `.strict()`.
- **Verified response:** `{ valid:true, scriptId, keyExpiresAt, sessionExpiresAt, grantId }`.
- **Verified validation order:** key hash lookup; terminal status; active; `owner_discord_id === session.user.discordId`; key expiry; subscription active/expiry; HWID comparison if both presented; session row by token hash; session key/user/revocation; session status; session absolute expiry; idle window; script eligibility; grant dedupe/insert; `last_seen_at`; audit.
- **Issues:**
  - Account session is mandatory.
  - Bearer token is mandatory, but a missing header returns `400 bad_request`, not `401 unauthorized` (`bearerToken()`).
  - `scriptId` means `scripts.public_id`, not a UUID.
  - No timestamp, nonce, client version, or replay detection.
  - No entitlement/product check.
  - Session is not bound to HWID, even though `key_sessions.hwid_fingerprint` exists.
  - The current `key` body is redundant with the bearer session, but it is used for the key-level checks.
  - `grantId` is a `script_access_logs.id`; it is not a signed grant and has no explicit short TTL. The response calls it a grant, but nothing expires it independently of the session.
  - A 60-second dedupe reuses an existing grant ID, which is application-level and race-prone because `script_access_logs` has no unique constraint for it.
  - Validation mutates state (`last_seen_at`, `script_access_logs`, `audit_logs`) but is not idempotent in the D10 sense. That is acceptable only if retries are safe via nonce/dedupe.

#### `POST /api/keys/reset-hwid`

- **Verified request schema:** `{ keyId: uuid, reason?: string(trim, max 500) }`, `.strict()`.
- **Verified behavior:** owner check via `owner_discord_id`; terminal gate; active gate; cooldown and cap from `system_settings`; clear binding; revoke sessions; `key_hwid_resets` with `performed_by='self'`; `key_device_history('reset_self')`; audit `key.hwid_reset`.
- **Issues:**
  - Directly violates D2.
  - Cooldown and cap are global settings, not per plan.
  - No executor/device context.
  - The route remains advertised in the Phase 4 report and is covered by tests.

#### Admin endpoints

- **Verified:** route access `admin`, which accepts `admin` or `owner`, and CSRF is required because these are unsafe session routes.
- **Issues:**
  - `POST /api/admin/keys` has no idempotency; a retry can generate a second batch.
  - `POST /api/admin/keys/{id}/revoke` has no idempotency header; the service returns `alreadyRevoked` for already-revoked keys, which is safe but not recorded as a replay.
  - `POST /api/admin/keys/{id}/reset-hwid` has no idempotency and no rate limit; repeated admin calls can repeatedly reset and revoke sessions. The service does not enforce cooldown/cap for admin, by design, but repeated calls are still possible.
  - No dedicated `key.hwid_reset_admin` permission exists; `hasAdminAccess()` is broader than a capability check.
  - Admin device history does not re-check actor in the service; it relies entirely on the route gate. That is consistent with the current pipeline but should be documented.

### 4.3 Old-to-new endpoint mapping

| Old endpoint | Executor-first treatment | Notes |
|---|---|---|
| `POST /api/keys/activate` | Keep for web/dashboard users; add `POST /api/executor/v1/activate` | Do not overload the old route with executor semantics; strict body differs |
| `POST /api/keys/validate` | Keep for web/dashboard flows; add `POST /api/executor/v1/validate` | Old route remains account-session-bound |
| `POST /api/keys/reset-hwid` | Disable under D2 after transition; retain history | Do not delete before impact analysis |
| `GET /api/keys/me` | Keep | Owner dashboard, Discord-based |
| `GET /api/keys/{id}/usage` | Keep | Owner dashboard |
| `GET /api/keys/{id}/devices` | Keep | Owner dashboard |
| `POST /api/admin/keys` | Keep; add idempotency later | Admin dashboard |
| `GET /api/admin/keys` | Keep | Admin dashboard |
| `POST /api/admin/keys/{id}/revoke` | Keep; add idempotency later | Admin action |
| `POST /api/admin/keys/{id}/reset-hwid` | Keep; make it the only reset path | D2 target |
| `GET /api/admin/keys/{id}/devices` | Keep | Admin read |
| n/a | Add `POST /api/executor/v1/session/revoke` | New |

---

## 5. Executor-First API Design

### 5.1 Design constraints

1. The executor is an **untrusted client environment**. The server can authenticate the key and the session; it cannot prove that the caller is a genuine Roblox executor.
2. The key is a bearer secret. It must never be logged, returned after creation, or placed in URLs.
3. All authorization is server-side. The client never sends a verdict, role, owner ID, plan, or entitlement claim.
4. The API must remain compatible with the existing web endpoints.
5. The design must not pretend that a secret embedded in a Roblox script proves authenticity. [VERIFIED in `BACKEND.md` §9.13 and Phase 4 report]
6. D3 must be enforced before a script grant is issued. Without it, executor-first would simply expose the existing all-scripts flaw to an untrusted client.

### 5.2 Common conventions

- Base path: `/api/executor/v1`.
- Content type: `application/json`.
- Authentication for activation: the license key in the body plus an `Idempotency-Key` header.
- Authentication for validation and revocation: `Authorization: Bearer <executorSessionToken>`.
- Request ID: reused from `x-request-id` or generated server-side; returned in every response.
- Response envelope: `{ "requestId": "...", "data": { ... } }` on success and `{ "error": { code, message, requestId } }` on failure. The current API returns bare bodies; a new versioned namespace is a good place to introduce a stable envelope. [RECOMMENDATION]
- Never echo the key, raw HWID, or session token except in the single activation success response.
- Use `Cache-Control: no-store` on all executor responses.
- Reject unknown fields with a strict schema.

### 5.3 `POST /api/executor/v1/activate`

**Purpose:** verify the key, check status/expiry/claim policy, bind or verify HWID, check script entitlement if requested, create an executor session, and return the session token exactly once.

**Recommended request**

```json
{
  "key": "bf_...",
  "hwid": "optional-device-identity",
  "scriptId": "public-script-id",
  "clientVersion": "1.4.0",
  "deviceLabel": "optional human label"
}
```

**Recommended headers**

- `Idempotency-Key: <8..200 printable ASCII>` — required.
- `Content-Type: application/json`.
- `X-Request-Id` — optional, server may replace.

**Field evaluation**

| Field | Required | Reason |
|---|---|---|
| `key` | Yes | The license credential |
| `hwid` | Owner decision; recommended required for executor | The current API makes it optional. For executor-first, requiring it is the only way to bind the session to a device. If the platform cannot supply a trustworthy value, the session is weaker and must be documented. |
| `scriptId` | Recommended required | Activation should answer "does this license cover the script being loaded?" If omitted, the API can issue a session but must not issue a script grant. |
| `clientVersion` | Recommended required | Lets the server reject obsolete or blocked clients and record the version. It is not a security proof. |
| `deviceLabel` | Optional | Display only; never trust it for authorization |

**Recommended server sequence**

1. Validate body and headers.
2. Rate limit by IP, key hash, and (if present) claimed device fingerprint.
3. If `clientVersion` is required, check the configured allowlist.
4. Hash the key, load the key row `FOR UPDATE`.
5. Apply terminal status precedence: `banned` → `revoked` → `suspended` → not `active`/`unused`.
6. Apply expiry and subscription checks.
7. Apply the claim policy (see §5.7).
8. If `hwid` is present, normalize and HMAC it; compare with `bound_hwid_hash`; if unbound, bind it. If the key is bound to a different hash, deny.
9. If `scriptId` is present, resolve entitlement (D3). Deny if not entitled.
10. Supersede any active session for the key; insert the new session; persist the session token HMAC.
11. Write `key_device_history` (`bound` if newly bound), `script_access_logs` if a grant is issued, and `audit_logs`.
12. Return the token once.

**Recommended response `201`**

```json
{
  "requestId": "req_...",
  "data": {
    "keyId": "uuid",
    "status": "active",
    "deviceBound": true,
    "sessionToken": "opaque-base64url",
    "sessionExpiresAt": "2026-11-12T12:00:00.000Z",
    "licenseExpiresAt": "2027-01-01T00:00:00.000Z",
    "script": {
      "scriptId": "public-id",
      "versionId": "uuid-or-null",
      "entitled": true
    }
  }
}
```

**Replay behavior**

- **Current verified behavior:** the same `Idempotency-Key` returns the original body without `keySessionToken`.
- **Required owner decision:** whether an executor may recover a lost activation response.
- **Recommended option:** allow a new activation with the same key and HWID to supersede the old session and issue a new token, with a strict rate limit and an audit event. Do not reuse the same `Idempotency-Key` to recover the secret.
- **Why not store the token for replay:** it would turn the idempotency table into a credential store. If the database is read, the token would be usable. The current design correctly avoids this.
- **Why not silently return the old token:** the token hash is one-way; the server cannot reconstruct it.

**Idempotency scope**

- Keep `Idempotency-Key` required for activation.
- Scope should include the executor namespace and the key hash, not just the client-supplied key. A client could otherwise collide across keys.
- The request hash must include `key`, `hwid`, `scriptId`, `clientVersion`, and `deviceLabel` exactly as canonical JSON.
- Do not persist the plaintext key or raw HWID in `idempotency_keys.response_body`; the current code does not.

### 5.4 `POST /api/executor/v1/validate`

**Purpose:** validate an executor session, check license status/expiry, check HWID, check script entitlement, consume a nonce, and return a short-lived authorization grant.

**Recommended request**

```json
{
  "scriptId": "public-script-id",
  "hwid": "device-identity",
  "timestamp": 1763000000000,
  "nonce": "opaque-random-value",
  "clientVersion": "1.4.0"
}
```

**Recommended headers**

- `Authorization: Bearer <executorSessionToken>` — required.
- `Content-Type: application/json`.

**Field evaluation**

| Field | Required | Reason |
|---|---|---|
| `scriptId` | Yes | The script being authorized |
| `hwid` | Yes for executor | Required to compare against the session and key binding |
| `timestamp` | Yes | Replay window; accept a configurable tolerance, e.g. ±120 seconds. [OWNER DECISION] |
| `nonce` | Yes | Unique per request within the tolerance window; store a hash, not the raw value |
| `clientVersion` | Yes if the server enforces versions | Version gate and telemetry |

**Recommended server sequence**

1. Parse Bearer token; if missing or malformed, return `401 session_required`.
2. Validate body.
3. Rate limit by IP, token hash, key hash, and script.
4. Reject timestamp outside tolerance with `timestamp_invalid`.
5. Reject nonce replay with `replay_detected`.
6. Load the session by token hash; require `status='active'`, `revoked_at IS NULL`, `expires_at > now`, idle window valid.
7. Load the key; require active, not terminal, not expired, subscription valid.
8. Compare presented HWID against the key binding **and** the session binding.
9. Resolve script entitlement (D3).
10. Insert/consume nonce atomically before issuing the grant.
11. Insert `script_access_logs` with the session ID (new column recommended), key ID, actor (nullable), result, and denial code.
12. Touch `last_seen_at`.
13. Return a short-lived grant.

**Recommended response `200`**

```json
{
  "requestId": "req_...",
  "data": {
    "valid": true,
    "scriptId": "public-id",
    "versionId": "uuid-or-null",
    "grantId": "uuid",
    "grantExpiresAt": "2026-11-12T12:01:00.000Z",
    "keyExpiresAt": "2027-01-01T00:00:00.000Z",
    "sessionExpiresAt": "2026-11-12T12:30:00.000Z"
  }
}
```

**Grant design**

- The current `grantId` is a database row ID, not a signed grant. It is an opaque correlation ID.
- For executor-first, a short TTL (e.g. 60 seconds) should be explicit in the response and enforced by the consumer.
- A signed grant is only useful if the verifier is the server or a trusted game server. A client-held signature cannot prove authenticity to an untrusted executor. Do not overstate it.
- If the grant is only used to release content from the same API, a database-backed grant row is sufficient.

**Nonce limitations**

- A nonce prevents the same request body from being accepted twice within the retention window.
- It does not prevent a stolen session token from making a new request with a new nonce.
- It does not prove that the caller is a genuine executor.
- It does not prevent a man-in-the-middle from reading the response unless TLS is enforced.
- Retention must be at least the timestamp tolerance plus clock skew. If the nonce row is deleted too early, replay becomes possible again.
- Nonce storage must be atomic: `INSERT ... ON CONFLICT DO NOTHING` and treat zero rows as replay.

**Idempotency for validate**

- Do not require `Idempotency-Key` for validation. Validation is a read-like authorization check with nonce-based replay protection.
- If a transport retry occurs, the client should generate a new nonce and timestamp; the server will issue a new grant.
- The 60-second grant dedupe should be replaced by an explicit idempotency or grant cache keyed by `(session_id, script_id, nonce)` if exact replay response is needed.

### 5.5 `POST /api/executor/v1/session/revoke`

**Purpose:** revoke the active executor session for the presented token.

**Recommended request**

```json
{ "reason": "optional-client-reason" }
```

**Headers**

- `Authorization: Bearer <executorSessionToken>` — required.
- Optional `Idempotency-Key`; revocation is naturally idempotent, so it is not required.

**Recommended behavior**

| Case | Response |
|---|---|
| Valid active token | `200 { revoked: true, alreadyRevoked: false, revokedAt }`; set `status='revoked'`, `revoked_at=now`; audit `key.session_revoke` |
| Valid token already revoked | `200 { revoked: true, alreadyRevoked: true }`; no state change; optional audit with replay flag |
| Malformed/missing token | `401 session_required` |
| Unknown token | `401 session_required` (do not reveal whether it ever existed) |
| Token belongs to a different key than the body claims | `401 session_required` or `403 not_owner`; body should not carry a key ID at all |
| Database failure | `503 unavailable` |

**Semantics**

- Revoking one session must not revoke other keys.
- Because `key_sessions_one_active_per_key` allows only one active session per key, revoking the active session effectively revokes the key's executor session. A future multi-session policy would need a different rule.
- Admin/global revocation remains on `POST /api/admin/keys/{id}/revoke`; it revokes all active sessions and the key.
- Rate limit by IP and token hash. An attacker with a stolen token could otherwise spam revoke, but revoke is not a confidentiality risk; it is a denial-of-service risk.
- Audit every successful revocation. Do not log the token.

### 5.6 Executor error contract

**Design principle:** the key is a credential. A caller who possesses a valid key may be told its state; an anonymous caller should not be able to enumerate keys. The table below distinguishes the stable external code from the internal reason. The internal reason goes to `audit_logs` and structured logs, never to the response. [RECOMMENDATION]

| Condition | External code | HTTP | External message | Internal audit reason |
|---|---|---|---|---|
| Key missing, malformed, or unknown | `invalid_key` | 403 | Key request denied | `unknown_key` / `malformed_key` |
| Key expired | `expired_key` | 403 | Key request denied | `key_expired` |
| Key suspended | `suspended_key` | 403 | Key request denied | `status=suspended` |
| Key banned | `banned_key` | 403 | Key request denied | `status=banned` |
| Key revoked | `revoked_key` | 403 | Key request denied | `status=revoked` |
| Key not active | `key_not_active` | 403 | Key request denied | `status=unused|expired` |
| Key owned/claimed by another principal | `already_owned` | 403 | Key request denied | `claim_conflict` |
| HWID missing when required | `hwid_missing` | 400 | Invalid request | `hwid_required` |
| HWID mismatch | `hwid_mismatch` | 403 | Key request denied | `hwid_mismatch` |
| Script not in license package | `not_authorized` | 403 | Key request denied | `script_not_entitled` |
| Session missing | `session_required` | 401 | Authentication required | `session_missing` |
| Session expired | `session_expired` | 401 | Authentication required | `session_idle_or_absolute_expiry` |
| Session revoked | `session_revoked` | 401 | Authentication required | `session_revoked` |
| Timestamp outside tolerance | `timestamp_invalid` (new code) | 400 | Invalid request | `timestamp_out_of_window` |
| Nonce replay | `replay_detected` | 409 | Request denied | `nonce_reuse` |
| Idempotency key reused with a different body | `idempotency_conflict` | 409 | Request denied | `idempotency_request_hash_mismatch` |
| Rate limited | `rate_limited` | 429 | Too many requests | bucket details in logs only |
| Database/internal failure | `unavailable` / `internal_error` | 503/500 | Service unavailable | real error in logs only |

**Important implementation notes**

- `timestamp_invalid` does not currently exist in `ErrorCode` (`src/core/errors.ts:6-35`). Adding it is a source change that requires approval.
- `replay_detected` exists but is unused. Reusing it is appropriate.
- The current `keyDenied()` maps only session codes to 401 and all other key denials to 403 (`src/modules/keys/errors.ts:29-37`). The new contract should be explicit rather than inherited.
- `bearerToken()` currently throws `400 bad_request` for a missing header. The executor route should return `401 session_required` instead.
- Avoid a distinct `key_not_found`. Distinguishing unknown from malformed invites enumeration. Use `invalid_key` for both.
- Do not return the failing internal step, SQL state, key prefix, or fingerprint in the error body.
- Keep response timing uninformative: perform the same hash and constant-time comparison path for unknown and known keys where practical. Perfect timing equalization is not proven; rate limiting is the primary enumeration defense.

### 5.7 Claim policy options

D1 leaves the first-activation claim policy open. The repository has no claim record. The options are:

| Option | Model | Advantage | Risk | Recommendation |
|---|---|---|---|---|
| A. Key-only claim | First successful activation marks the key claimed by an executor principal (opaque ID); no `users` row | Matches D1; no fake Discord identity | Needs new principal columns; ownership recovery is harder | **Recommended for executor-first** |
| B. Pre-assigned owner required | Key must already have `owner_discord_id` or an admin-assigned principal before activation | Strong ownership | Contradicts "no Discord login"; requires a separate assignment flow | Not recommended for D1 |
| C. Hybrid | Executor claim allowed only if unowned; web user can also claim with Discord | Flexible | Two identity systems and reconciliation complexity | Acceptable later |
| D. Anonymous key use, no claim | Any holder of the key can activate | Simplest | No ownership, no theft response, no device accountability | Rejected |

**If Option A is approved:** introduce a neutral principal identity (for example `keys.claimed_at`, `keys.claim_kind`, and a new `license_claims` table), and make `key_sessions.user_id` nullable with a `principal_type` discriminator. Do not create synthetic `users` rows merely to satisfy the foreign key.

**If Option B is approved:** keep `owner_discord_id` and `user_id`, and require an admin pre-assignment step. This does not satisfy D1 as written.

---

## 6. Schema Inventory (Verified from `0001_init.sql`)

Only one migration file exists: `supabase/migrations/0001_init.sql`. There are no product, package, entitlement, or nonce tables. All statements below are from that file.

### 6.1 `users`

- **Columns:** `id uuid pk default gen_random_uuid()`, `discord_id text not null`, `username text`, `avatar_url text`, `email text`, `status text not null default 'active'`, `created_at timestamptz not null default now()`, `updated_at timestamptz not null default now()`.
- **Constraints:** unique `discord_id`; check `status in ('active','suspended','deleted')`.
- **Indexes:** `users_status_idx(status)`.
- **Relevance:** `discord_id` is `not null`, so there is no anonymous user identity. Any executor session that references `users` requires a user row, which contradicts D1.

### 6.2 `user_roles`

- **Columns:** `id uuid pk`, `user_id uuid not null references users(id) on delete cascade`, `role text not null`, `granted_by uuid references users(id)`, `created_at`.
- **Constraints:** unique `(user_id, role)`; check `role in ('user','moderator','admin')`.
- **Indexes:** `user_roles_user_id_idx(user_id)`.
- **Note:** `owner` is not a database role; it is derived from `DISCORD_OWNER_ID` at session resolution.

### 6.3 `games`

- **Columns:** `id uuid pk`, `name text not null`, `slug text`, `description text`, `image_url text`, `created_at`, `updated_at`.
- **Constraints:** unique `slug`.
- **Relevance:** catalog only; no product relation.

### 6.4 `scripts`

- **Columns:** `id uuid pk`, `public_id text not null`, `name text not null`, `description text`, `game_id uuid references games(id)`, `current_version_id uuid` (FK added later to `script_versions(id)`), `content_ref text`, `status text not null default 'draft'`, `enabled boolean not null default true`, `created_by uuid references users(id)`, `deleted_at timestamptz`, `created_at`, `updated_at`.
- **Constraints:** unique `public_id`; check `status in ('draft','published','archived')`; FK `scripts_current_version_fk(current_version_id) references script_versions(id)`.
- **Indexes:** `scripts_game_id_idx`, `scripts_status_idx`, `scripts_enabled_idx`.
- **Relevance:** `public_id` is the current `scriptId` used by validation. There is no product, package, or plan column.

### 6.5 `script_versions`

- **Columns:** `id uuid pk`, `script_id uuid not null references scripts(id) on delete cascade`, `version_number integer not null`, `content_ref text not null`, `changelog text`, `created_by uuid references users(id)`, `created_at`.
- **Constraints:** unique `(script_id, version_number)`; check `version_number > 0`.

### 6.6 `plans`

- **Columns:** `id uuid pk`, `code text not null`, `name text not null`, `duration_days integer not null`, `price_minor integer not null`, `currency text not null default 'IDR'`, `active boolean not null default true`, `created_at`, `updated_at`.
- **Constraints:** unique `code`; check `duration_days > 0`; check `price_minor >= 0`.
- **Relevance:** this is a subscription plan, not a product bundle. It has no script relation.

### 6.7 `subscriptions`

- **Columns:** `id uuid pk`, `user_id uuid not null references users(id)`, `plan_id uuid not null references plans(id)`, `transaction_id uuid references transactions(id)`, `status text not null default 'pending'`, `started_at timestamptz`, `expires_at timestamptz`, `created_at`, `updated_at`.
- **Constraints:** check `status in ('pending','active','expired','cancelled')`.
- **Indexes:** `subscriptions_user_id_idx`, `subscriptions_status_idx`, `subscriptions_expires_at_idx`.
- **Relevance:** subscription ownership is a `users` row. An executor-only key with a subscription would need a user or a different subscription model.

### 6.8 `keys`

- **Columns:** `id uuid pk`, `key_hash text not null`, `key_prefix text`, `type text not null default 'paid'`, `status text not null default 'unused'`, `owner_discord_id text`, `user_id uuid references users(id)`, `bound_hwid_hash text`, `hwid_bound_at timestamptz`, `last_hwid_reset_at timestamptz`, `hwid_reset_count integer not null default 0`, `banned_at timestamptz`, `ban_detected_at timestamptz`, `ban_reason text`, `ban_evidence_refs jsonb`, `subscription_id uuid references subscriptions(id)`, `plan_id uuid references plans(id)`, `max_activations integer not null default 1`, `activation_count integer not null default 0`, `expires_at timestamptz`, `created_at`, `updated_at`.
- **Primary key:** `id`.
- **Foreign keys:** `user_id → users(id)`, `subscription_id → subscriptions(id)`, `plan_id → plans(id)`.
- **Unique:** `key_hash`.
- **Checks:** `type in ('free','paid')`; `status in ('unused','active','expired','revoked','suspended','banned')`; `status <> 'banned' or banned_at is not null`; `max_activations >= 1`; `activation_count >= 0`.
- **Indexes:** `keys_user_id_idx`, `keys_owner_discord_id_idx`, `keys_status_idx`, `keys_bound_hwid_hash_idx`, partial `keys_banned_partial_idx(banned_at) where status='banned'`.
- **Critical facts:** `owner_discord_id` and `user_id` are nullable. There is no `owner_user_id`. There is no product/entitlement column. `plan_id` is the only package-like link, and it points to a subscription plan with no script relation.

### 6.9 `script_access_logs`

- **Columns:** `id uuid pk`, `script_id uuid not null references scripts(id)`, `version_id uuid references script_versions(id)`, `actor_user_id uuid references users(id)`, `key_id uuid references keys(id)`, `ip text`, `user_agent text`, `result text not null`, `created_at`.
- **Checks:** `result in ('granted','denied','not_found')`.
- **Indexes:** `script_access_logs_script_id_idx`, `script_access_logs_created_at_idx`.
- **Critical facts:** `actor_user_id` and `key_id` are nullable, so an executor log can be written without a user. There is no `key_session_id`, `entitlement_id`, or `denial_code` column. There is no unique dedupe constraint.

### 6.10 `key_bans`

- **Columns:** `id uuid pk`, `key_id uuid not null references keys(id) on delete restrict`, `reason text not null`, `detected_at timestamptz not null`, `banned_at timestamptz`, `detection_category text not null`, `confidence text not null`, `reviewed_by uuid references users(id)`, `review_status text not null default 'pending_review'`, `reversed_at timestamptz`, `reversed_by uuid references users(id)`, `reversal_reason text`, `created_at`, `updated_at`.
- **Checks:** enumerated `detection_category`, `confidence in ('high','confirmed')`, `review_status in ('pending_review','confirmed','rejected','reversed')`, reversal field consistency, applied ban requires `banned_at`.
- **Indexes:** unique live ban/proposal `key_bans_live_unique(key_id) where review_status in ('pending_review','confirmed')`; plus key, banned_at, review_status, confidence.
- **Relevance:** Phase 5 owned. Executor validation must honor `banned` status but does not need to implement these workflows.

### 6.11 `key_ban_evidence`

- **Columns:** `id uuid pk`, `ban_id uuid not null references key_bans(id) on delete restrict`, `evidence_type text not null`, `source_table text`, `source_id uuid`, `hwid_fingerprint text`, `summary text`, `metadata jsonb`, `created_by uuid references users(id)`, `created_at`.
- **Checks:** enumerated evidence type; `(source_table is null) = (source_id is null)`.
- **Indexes:** ban, type, source.

### 6.12 `key_ban_reversals`

- **Columns:** `id uuid pk`, `ban_id uuid not null references key_bans(id) on delete restrict`, `key_id uuid not null references keys(id) on delete restrict`, `requested_by uuid not null references users(id)`, `justification text not null`, `status text not null default 'pending_approval'`, `decided_by uuid references users(id)`, `decided_at`, `decision_reason`, `cancelled_at`, `created_at`, `updated_at`.
- **Checks:** status enum; lifecycle field consistency; no self-approval.
- **Indexes:** unique open request per ban; ban, key, requester, created_at, pending.
- **Relevance:** Phase 5. Owner reversal requires a `users` row, which complicates an executor-only license if D1 removes Discord ownership.

### 6.13 `key_reactivations`

- **Columns:** `id uuid pk`, `key_id uuid not null references keys(id) on delete restrict`, `ban_id uuid not null references key_bans(id) on delete restrict`, `authorized_by uuid not null references users(id)`, `reason text not null`, `authorized_at timestamptz not null default now()`, `consumed_at timestamptz`, `created_at`.
- **Checks:** consumed_at null or >= authorized_at.
- **Indexes:** partial unique `key_reactivations_unused_unique(key_id) where consumed_at is null`; key, ban, authorized_by, authorized_at.
- **Relevance:** activation may consume one unused authorization. Phase 5 creates it. Executor activation must preserve this branch.

### 6.14 `key_device_history`

- **Columns:** `id uuid pk`, `key_id uuid not null references keys(id) on delete cascade`, `event text not null`, `hwid_fingerprint text`, `actor_user_id uuid references users(id)`, `actor_admin_id uuid references users(id)`, `ip text`, `metadata jsonb`, `created_at`.
- **Checks:** `event in ('bound','validation_failed','reset_self','reset_admin','revoked','banned','ban_reversed')`.
- **Indexes:** key, created_at.
- **Relevance:** supports executor events only if new event values are added (migration) or if existing `bound`/`validation_failed`/`revoked` are reused. Both actor columns are nullable, so executor writes are possible.

### 6.15 `key_hwid_resets`

- **Columns:** `id uuid pk`, `key_id uuid not null references keys(id) on delete cascade`, `user_id uuid references users(id)`, `performed_by text not null`, `admin_id uuid references users(id)`, `previous_hwid_fingerprint text`, `new_hwid_fingerprint text`, `reason text`, `created_at`.
- **Checks:** `performed_by in ('self','admin')`.
- **Indexes:** key, user, created_at.
- **Relevance:** supports D2 directly. For a pure executor key, `user_id` may be null; `admin_id` is the acting admin.

### 6.16 `key_sessions`

- **Columns:** `id uuid pk`, `key_id uuid not null references keys(id) on delete cascade`, `user_id uuid not null references users(id)`, `session_token_hash text not null`, `hwid_fingerprint text`, `status text not null default 'active'`, `expires_at timestamptz not null`, `last_seen_at timestamptz`, `revoked_at timestamptz`, `created_at`.
- **Constraints:** unique `session_token_hash`; check `status in ('active','superseded','expired','revoked')`.
- **Indexes:** partial unique `key_sessions_one_active_per_key(key_id) where status='active'`; key, user, expires_at.
- **Critical facts:** `user_id` is **not nullable**. Only a 12-char fingerprint is stored, not a hash. There is no `principal_type`, `client_version`, `hwid_hash`, `ip`, or `last_nonce_at`.

### 6.17 `system_settings`

- **Columns:** `id uuid pk`, `key text not null`, `value jsonb not null`, `updated_by uuid references users(id)`, `created_at`, `updated_at`.
- **Constraints:** unique `key`.
- **Existing key values used by the service:** `hwid.reset_cooldown_hours` (default 24), `hwid.max_resets` (default 3). No executor settings exist.

### 6.18 `audit_logs`

- **Columns:** `id uuid pk`, `actor_user_id uuid references users(id)`, `action text not null`, `target_type text`, `target_id text`, `metadata jsonb`, `ip text`, `created_at`.
- **Indexes:** actor, action, created_at.
- **Critical facts:** `actor_user_id` is nullable, so executor actions can be written with `null`; there is no `actor_type` or `actor_ref` column to identify an executor principal. `target_id` is text, so it can hold a key UUID or a script public ID.

### 6.19 `sessions`

- **Columns:** `id uuid pk`, `user_id uuid not null references users(id) on delete cascade`, `token_hash text not null`, `user_agent text`, `ip text`, `expires_at timestamptz not null`, `revoked_at timestamptz`, `last_seen_at timestamptz not null default now()`, `rotated_at timestamptz`, `absolute_expires_at timestamptz`, `created_at`.
- **Constraints:** unique `token_hash`.
- **Indexes:** user, expires_at.
- **Relevance:** account web sessions, distinct from `key_sessions`. Do not reuse for executor.

### 6.20 `idempotency_keys`

- **Columns:** `id uuid pk`, `scope text not null`, `key_hash text not null`, `request_hash text not null`, `actor_id text`, `status text not null default 'processing'`, `response_status integer`, `response_body jsonb`, `one_time_secret_issued boolean not null default false`, `expires_at timestamptz not null`, `created_at`, `updated_at`.
- **Constraints:** unique `(scope, key_hash)`; check `status in ('processing','completed')`.
- **Indexes:** `expires_at`.
- **Critical facts:** no plaintext one-time secret is stored. `actor_id` is `text`, so it can hold a user UUID or an executor principal. Replays return `response_body` only.

### 6.21 `rate_limit_counters`

- **Columns:** `bucket_key text not null`, `window_start timestamptz not null`, `counter integer not null default 0`, `expires_at timestamptz not null`.
- **Primary key:** `(bucket_key, window_start)`.
- **Checks:** `counter >= 0`.
- **Indexes:** `expires_at`.
- **Critical facts:** fixed window, not sliding. No cleanup job was found in the repository. [NOT VERIFIED whether an external job deletes expired rows]

### 6.22 `transactions` (supporting context)

- **Columns:** `id uuid pk`, `user_id uuid not null references users(id)`, `plan_id uuid references plans(id)`, `provider text not null`, `provider_txn_id text`, `amount_minor integer not null`, `currency text not null default 'IDR'`, `status text not null default 'pending'`, `created_at`.
- **Constraints:** unique `(provider, provider_txn_id)`; status enum; amount >= 0.
- **Relevance:** all payments are user-bound; no executor-only purchase path exists.

---

## 7. Schema Gap Analysis

### 7.1 Direct answers to the ten required questions

1. **Is `keys.owner_user_id` required?**
   - There is no `owner_user_id` column. `owner_discord_id` and `user_id` are nullable. The `keys` row can be unowned. **[VERIFIED]**
   - The service treats `owner_discord_id` as the effective owner and rejects a different Discord ID. **[VERIFIED]**
   - A change is needed only to the ownership/claim policy, not to a nonexistent `owner_user_id`.

2. **Can a key live without a Discord user?**
   - The `keys` row: yes, `user_id` and `owner_discord_id` are nullable. **[VERIFIED]**
   - A key session: no, `key_sessions.user_id` is `not null`. **[VERIFIED]**
   - Therefore, "license without Discord" is partially possible at rest but impossible for an active session today.

3. **Can first activation be atomic?**
   - Yes for the current model: one transaction locks the key, checks status/expiry/owner, supersedes sessions, inserts the session, updates the key, and writes history/audit. **[VERIFIED]**
   - For executor-first, the claim itself must also be atomic. A `for update` on the key plus a claim row or claim columns can provide that. The existing transaction skeleton can be extended.
   - Concurrency caveat: PGlite serializes transactions behind a mutex, so the test suite does not prove real PostgreSQL row-lock contention. **[VERIFIED in Phase 4 report and test harness]**

4. **Can one key have multiple sessions?**
   - No active sessions: the partial unique index `key_sessions_one_active_per_key` allows exactly one `active` row per key. Historical rows may be many. **[VERIFIED]**
   - If executor-first needs concurrent sessions, this constraint must be changed. That is an owner decision.

5. **How is a session token stored and verified?**
   - Stored as HMAC-SHA-256 in `key_sessions.session_token_hash`, unique. **[VERIFIED]**
   - Verified by hashing the Bearer token and querying the row. No plaintext token is stored. **[VERIFIED]**
   - The token is 256-bit CSPRNG, base64url. **[VERIFIED]**

6. **Can HWID binding work without a user account?**
   - At the key level: yes. `keys.bound_hwid_hash` and `key_device_history.hwid_fingerprint` do not require a user; actor columns are nullable. **[VERIFIED]**
   - At the session level: currently only a fingerprint is stored and it is not checked. A proper session-level HWID binding would need a schema change or use of the existing fingerprint with a documented loss of precision. **[VERIFIED]**
   - The `key_sessions.user_id` blocker remains.

7. **Can admin-only HWID reset be done safely?**
   - Yes, the schema and service already support `performed_by='admin'`, `admin_id`, `reset_admin`, and audit. **[VERIFIED]**
   - Gaps: no idempotency, no dedicated rate limit, no dedicated permission capability, and the self-service route still exists. **[VERIFIED]**

8. **Does the database support license-to-product/script mapping?**
   - No. There is no product, package, entitlement, plan-script, or key-script table. **[VERIFIED]**
   - `plans` cannot express a bundle of scripts. **[VERIFIED]**

9. **Can nonce replay be stored, consumed atomically, and cleaned after TTL?**
   - There is no nonce table. The database can support it, but it must be added. **[VERIFIED]**
   - An atomic design is possible with a unique nonce hash and `INSERT ... ON CONFLICT DO NOTHING`; TTL cleanup needs a job or opportunistic deletion. **[RECOMMENDATION]**

10. **Can idempotency handle a lost activation response without creating a new session or leaking a token?**
    - Current behavior: no. A replay returns the safe body without the token; a new idempotency key would hit the existing `active` denial unless the policy changes. **[VERIFIED]**
    - Creating a new session on a new key is possible after a policy change, but that supersedes the old session and must be rate-limited and audited. **[RECOMMENDATION]**
    - The current store correctly avoids storing the one-time secret. Do not change that lightly.

### 7.2 Gap summary

| Area | Current condition | Gap | Needs migration | Priority |
|---|---|---|---|---|
| Executor identity | `key_sessions.user_id NOT NULL`; `users.discord_id NOT NULL` | No key-only session principal | Yes | P0 |
| Activation auth | Account session + Discord required | Cannot satisfy D1 | No for code, yes for schema/claim | P0 |
| Claim model | No claim record; `owner_discord_id`/`user_id` written on activation | First-activation policy undefined | Yes (claim columns/table) | P0 |
| Session lifetime | 30-minute absolute expiry | Executor sessions expire too quickly | No (config/service), maybe no schema | P0 |
| Session HWID binding | Only fingerprint stored, never checked | Stolen token usable from another device | Yes (hash column) or service-only fingerprint | P1 |
| Nonce/replay | No table, no code path | Replay possible | Yes | P0 |
| Timestamp/client version | Not accepted by schema | No request freshness or version gate | No schema; validator/service change | P1 |
| Entitlement | No product/script relation | D3 violated | Yes | P0 |
| One-time token replay | Not stored; replay lacks token | Lost response unrecoverable | No schema; policy/service change | P1 |
| Key secret separation | `SESSION_HMAC_SECRET` reused | Rotation invalidates keys and sessions | Yes (`key_hash_version`, new secret) | P1 |
| Admin reset | Exists; no idempotency/rate limit | D2 partially satisfied | No schema; service/route change | P1 |
| Self-service reset | Still active | Violates D2 | No schema; route/service change | P0 |
| Executor error codes | `timestamp_invalid` missing; `replay_detected` unused | Inconsistent contract | No schema; code change | P1 |
| Audit actor | `actor_user_id` only, nullable | Cannot identify executor principal | Yes (actor type/ref) | P2 |
| Script log | No `key_session_id`/denial code | Weak traceability | Yes | P2 |
| Rate limit admin | No admin rate limits | Admin retry abuse | No schema | P2 |
| Cleanup jobs | No executor nonce cleanup; no visible rate-limit cleanup | Table growth | Maybe no schema; job needed | P2 |

---

## 8. Security Audit

### 8.1 Secret inventory

| Secret | File / accessor | Used for | Production behavior |
|---|---|---|---|
| `SESSION_HMAC_SECRET` | `src/core/env.ts:123-130` | Account session token, OAuth state, CSRF derivation, **key hash**, **key session token hash** | Required in production; dev fallback |
| `HWID_HASH_SECRET` | `src/core/env.ts:137-144` | HWID HMAC | Required in production; dev fallback |
| `RATE_LIMIT_HMAC_SECRET` | `src/core/env.ts:100-104` | Rate-limit bucket identifiers | Required in production |

**Verified domain separation**

- Account session: `session:v1:{token}`
- OAuth state: `oauth_state:v1:{state}`
- CSRF: `csrf:v1:{tokenHash}`
- Key: `key:v1:{plaintext}`
- Key session: `key_session:v1:{token}`
- HWID: `hwid:v1:{normalized}`

Domain prefixes prevent cross-protocol hash reuse, but not root-secret reuse.

### 8.2 Findings

#### S1 — Key and account secrets share a root key (High)

- **Evidence:** `PostgresKeyService.hashKey()` and `hashSessionToken()` use `this.sessionSecret`, which falls back to `getSessionSecret()` (`src/modules/keys/service.ts:257-271`).
- **Risk:** rotating `SESSION_HMAC_SECRET` invalidates all account sessions, all key hashes, and all key sessions. A leak of that one secret compromises both account and license verification.
- **Recommendation:** introduce `KEY_HMAC_SECRET` and `KEY_HMAC_KEY_VERSION`; add `key_hash_version` to `keys` and `session_token_hash_version` to `key_sessions`; dual-read during rotation. Keep the old secret available for verification until all rows are rehashed **or** accept a one-time forced reissue. Never delete the old secret before the migration completes.
- **Migration required:** yes, for version columns and new secret configuration. No plaintext key can be rehashed without the plaintext, so automatic rehash is impossible for keys. The practical migration is: keep old hash version, verify with old secret, and issue new keys under the new version; old keys rotate on reissue or remain dual-version indefinitely. This must be an owner decision.

#### S2 — One-time activation token cannot be recovered (Medium)

- **Evidence:** `withIdempotency()` persists `response_body` and `one_time_secret_issued` only; the test asserts replay has no token.
- **Risk:** a lost response forces a new activation. Current logic denies an active key as `already_owned`, and `activation_count` may already be at `max_activations`.
- **Recommendation:** define an explicit re-activation/reissue policy for executor keys; do not store the token. Add an audit event and rate limit. Decide whether reissue consumes an activation.

#### S3 — Executor session is not bound to HWID (High)

- **Evidence:** `key_sessions.hwid_fingerprint` is stored on activation but never compared during validation; validation checks only `keys.bound_hwid_hash`.
- **Risk:** a stolen session token works from another device until the key's HWID is also mismatched. If the key has no binding, it works anywhere.
- **Recommendation:** store `hwid_hash` on `key_sessions` (or compare the fingerprint consistently) and require the presented HWID to match both the key and the session. Keep `hwid_fingerprint` for display.

#### S4 — 30-minute absolute session is unsuitable for long-running executors (High usability/security trade-off)

- **Evidence:** `KEY_SESSION_TTL_MS = 30 * 60 * 1000`; `last_seen_at` updates but `expires_at` is fixed.
- **Risk:** frequent re-activation increases credential exposure and user friction; a longer fixed TTL increases the theft window.
- **Recommendation:** owner decision on executor TTL. A sliding idle window with a longer absolute cap (e.g. 24 hours) is common, but it must be paired with device binding and revocation. Do not change the web key-session policy blindly.

#### S5 — No nonce/timestamp replay protection (High for executor-first)

- **Evidence:** no nonce table; validator rejects extra fields; `replay_detected` unused.
- **Risk:** a captured validation request can be replayed while the session is live. Idempotency does not cover validation.
- **Recommendation:** add nonce storage and timestamp tolerance before exposing the executor endpoint. Retain nonce records for at least the tolerance window. Use atomic insert. Do not treat nonce as proof of executor authenticity.

#### S6 — Executor environment cannot prove authenticity (Residual, not fully mitigable)

- **Evidence:** `BACKEND.md` §9.13 explicitly says a LocalScript request alone is denied and recommends a server-side signed request; D18 is deferred in the Phase 4 report.
- **Risk:** any secret embedded in an executor script can be extracted. HMAC signing by the client does not prove a genuine executor.
- **Recommendation:** do not claim otherwise. Use the key and session as the security boundary. If stronger assurance is required, use a trusted game server integration (D18) rather than a client-side signature. Document the residual risk.

#### S7 — Error responses can leak key state (Medium)

- **Evidence:** `keyDenied()` maps session codes to 401 and other key denials to 403; unknown key and expired key are distinguishable by code.
- **Risk:** an attacker with a candidate key can learn its state. Because the key is high-entropy, the practical risk is limited, but the response contract should be intentional.
- **Recommendation:** use `invalid_key` for unknown/malformed; allow status-specific codes only when the caller has proven possession of the key and rate limits are active. Keep messages generic. Do not include the key prefix.

#### S8 — Logging and body handling

- **Verified:** `app.ts` logs method, path, status, duration, and request ID; it does not log headers or bodies. `validation.ts` returns only issue paths/messages. `body-limit.ts` does not log the body.
- **Residual:** the `Request` object and error causes could be logged by future code; `internalError` logs the error message. Ensure no route interpolates the key or HWID into an error message. Current code does not. [VERIFIED]
- **Recommendation:** add a lint/review rule that key/HWID/token names never appear in log calls; redact `authorization` and `idempotency-key` at the edge if a request logger is added later.

#### S9 — Rate limiting gaps

- **Verified:** activation and validation are limited per user/IP; executor has no user, so the current helper would only apply IP unless extended.
- **Verified:** admin routes have no rate limits.
- **Recommendation:** add per-key (HMAC bucket), per-IP, and per-session limits for executor; add admin-scoped limits. `RateLimitKind` already includes `"key"`, so no schema change is needed for the bucket kind, but the API must pass the key hash, never the plaintext key.

#### S10 — Admin authorization is not weakened by this design

- **Verified:** `access: "admin"` requires a session and `hasAdminAccess(roles)`, which accepts `admin` or `owner`. CSRF is required for unsafe session routes.
- **Recommendation:** keep it. If a dedicated `key.hwid_reset_admin` permission is added, map it to `ADMIN_ROLES` and keep `hasAdminAccess()` as the outer gate. Do not allow executor tokens to call admin routes.

#### S11 — Audit actor limitations

- **Verified:** `audit_logs.actor_user_id` references `users`, nullable. Executor actions have no user ID.
- **Recommendation:** add `actor_type`/`actor_ref` or write `actor_user_id = null` with `metadata.principal` and a stable `target_type='key'`. Prefer an explicit actor type for queryability.

#### S12 — Secret rotation strategy

- **Verified:** key hashes cannot be recomputed without plaintext keys.
- **Recommendation:** use versioned hashes and dual verification. Keep `SESSION_HMAC_SECRET` for account sessions; introduce `KEY_HMAC_SECRET` for new keys and sessions. Do not rotate the old secret until all active keys have been reissued or the owner accepts forced reissue. Document that a key hash rotation requires a user-facing reissue event.

---

## 9. License-to-Script Mapping Design (D3)

### 9.1 Design goals

- One license package can include many scripts.
- One script can appear in many packages.
- Access is evaluated server-side on every validation.
- The model fits `scripts`, `games`, `plans`, and `keys` without inventing a parallel catalog.
- Existing keys can be migrated without an outage.

### 9.2 Recommended model

The existing `plans` table is a **subscription term/price** record, not a product bundle. Reusing it as a product would conflate duration/pricing with content entitlement. Two coherent options:

**Option A — Plan-based bundles (smallest change)**

- Add `plan_scripts(plan_id uuid not null references plans(id) on delete cascade, script_id uuid not null references scripts(id) on delete cascade, created_at, primary key (plan_id, script_id))`.
- A key's entitlement is derived from `keys.plan_id` and, when present, `keys.subscription_id` (active, not expired).
- Pros: uses existing `plans` and `keys.plan_id`; fewer tables.
- Cons: a "plan" is still a duration/price SKU; if the same content is sold under multiple durations, the script list is duplicated per plan. It cannot model a product that is not a subscription.

**Option B — Product + plan mapping (recommended for the long term)**

- Add `products(id, code unique, name, active, created_at, updated_at)`.
- Add `product_scripts(product_id, script_id, created_at, primary key (product_id, script_id))`.
- Add `product_plans(product_id, plan_id)` or add `products.plan_id` only if one product maps to one plan.
- Add `key_entitlements(id, key_id, product_id, source, starts_at, expires_at, status, created_at, unique (key_id, product_id, starts_at))` for explicit per-key grants, overrides, and legacy grandfathering.
- `keys.plan_id` remains for billing; entitlement resolution uses `key_entitlements` first, then `product_plans`/`plans`.
- Pros: separates catalog product from billing term; supports non-subscription products, bundles, and overrides.
- Cons: more tables and a backfill decision.

**Recommendation:** adopt Option B if BOYFINITY products are not identical to subscription durations. If the owner confirms every license is a plan, Option A is sufficient and smaller. This is an **[OWNER DECISION]**.

### 9.3 Proposed access query

Replace the current `resolveScriptAccess(db, { publicId })` with a function that requires the key:

```ts
resolveScriptAccess(db, {
  keyId: string,
  publicId: string,
  now: Date,
}): Promise<EligibleScript | null>
```

Conceptual query (names are recommendations, not existing schema):

```sql
select s.id as "scriptId", s.public_id as "publicId", s.current_version_id as "versionId"
from scripts s
join product_scripts ps on ps.script_id = s.id
join key_entitlements ke on ke.product_id = ps.product_id
where ke.key_id = $1
  and ke.status = 'active'
  and (ke.starts_at is null or ke.starts_at <= $3)
  and (ke.expires_at is null or ke.expires_at > $3)
  and s.public_id = $2
  and s.status = 'published'
  and s.enabled = true
  and s.deleted_at is null
```

If Option A is chosen, replace `product_scripts`/`key_entitlements` with `plan_scripts` and derive `plan_id` from the key and active subscription.

### 9.4 Authorization behavior

- Missing entitlement: `not_authorized` (403), internal reason `script_not_entitled`.
- Script not found / not published / disabled / deleted: `not_authorized` externally; log `not_found` or `not_published` internally. Do not reveal whether a script exists to an unauthenticated caller.
- Entitlement expired: `not_authorized`; internal `entitlement_expired`.
- Entitlement suspended: `not_authorized`; internal `entitlement_suspended`.
- The entitlement check must run **before** the grant insert and before `last_seen_at` is extended. A denial must not refresh the session.
- The check must be inside the same transaction as the session/key reads to avoid a time-of-check/time-of-use gap.

### 9.5 Backfill strategy

- **Do not** backfill all existing keys to all published scripts silently, because that preserves the D3 violation and makes it invisible.
- Recommended: create a `legacy` product containing the scripts that existing keys are expected to access, and assign existing active keys an explicit `key_entitlements` row to that product during migration. This makes the grandfathered access auditable and lets it be narrowed later.
- Alternative: create no entitlements and let existing validation fail until keys are assigned. This is stricter but breaks current users. Owner decision.
- New keys must be generated with an explicit product/plan. `POST /api/admin/keys` should require a product/plan when D3 is enforced. That is a validator/API change, not just a schema change.

### 9.6 Scope placement

D3 schema and resolution are a **prerequisite** for a correct executor-first validate endpoint. They are not part of the Phase 5 ban/reversal workflow. Recommended as a separate "Phase 4.5 — Entitlements" or early Phase 5A, with the owner's approval. Implementing executor-first without D3 would expose the current all-scripts behavior to a broader client base.

---

## 10. Phased Migration Plan (Not Executed)

**General rules:** expand-and-contract; no destructive change in the same step as a backfill; keep old code compatible until the new path is observed in production; take a backup before each data migration; test against PostgreSQL, not only PGlite.

### M0 — Baseline and safety

- **Purpose:** confirm the production schema matches `0001_init.sql`, take a backup, and record row counts for `keys`, `key_sessions`, `key_device_history`, `key_hwid_resets`, `script_access_logs`, `idempotency_keys`, `audit_logs`.
- **Changes:** none.
- **Backfill:** none.
- **Rollback:** restore backup if a later step fails.
- **Downtime:** none.
- **Compatibility:** all existing code.
- **Order:** first.

### M1 — Executor session identity (expand)

- **Purpose:** allow a key session without a Discord `users` row while preserving existing account sessions.
- **Changes:**
  - `alter table key_sessions alter column user_id drop not null`.
  - Add `principal_type text not null default 'account'` with check `in ('account','executor')`.
  - Add `principal_ref text` (opaque executor principal / claim ID).
  - Add `client_version text`.
  - Add `hwid_hash text` (full keyed hash) if S3 is approved; keep `hwid_fingerprint` for display.
  - Add index on `(key_id, status)` if not already covered; the existing partial unique index remains.
- **Data affected:** all existing `key_sessions` rows. Backfill `principal_type='account'`; `principal_ref` remains null.
- **Backfill:** `update key_sessions set principal_type='account' where principal_type is null or principal_type=''` (the default already covers new rows).
- **Rollback:** drop new columns; before restoring `not null`, verify no executor rows exist. If executor rows exist, rollback requires deleting or converting them.
- **Downtime:** none for the `drop not null` and additive columns.
- **Compatibility:** old code continues to insert `user_id`; new code may insert null with `principal_type='executor'`.
- **Risk:** a null `user_id` breaks any query that assumes it; search the codebase before applying.
- **Order:** after M0.

**Alternative:** create a separate `executor_sessions` table instead of altering `key_sessions`. This avoids nullability risk but duplicates token, expiry, revocation, and single-session logic. The existing schema is closer to reuse; M1 is recommended unless the owner prefers strict separation.

### M2 — Nonce and replay store

- **Purpose:** support timestamp/nonce validation with atomic consumption and TTL cleanup.
- **Changes:**
  - `create table executor_nonces (id uuid pk, nonce_hash text not null, session_id uuid references key_sessions(id) on delete cascade, key_id uuid references keys(id) on delete cascade, used_at timestamptz not null default now(), expires_at timestamptz not null, constraint executor_nonces_hash_key unique (nonce_hash));`
  - Index `executor_nonces_expires_at_idx(expires_at)`.
  - Optional index `(session_id, used_at)`.
- **Data affected:** none initially.
- **Backfill:** none.
- **Rollback:** drop table.
- **Downtime:** none.
- **Compatibility:** no effect on old endpoints.
- **Cleanup:** add a scheduled job or opportunistic delete `where expires_at < now()`; the repository has a `jobs` table but no executor job. [RECOMMENDATION]
- **Order:** after M1 or in parallel.

### M3 — Entitlements (D3)

- **Purpose:** replace all-scripts access with product/plan entitlement.
- **Changes (Option B recommended):**
  - `products(id, code unique, name, active, created_at, updated_at)`.
  - `product_scripts(product_id, script_id, created_at, primary key (product_id, script_id))`.
  - `key_entitlements(id, key_id, product_id, source, starts_at, expires_at, status, created_at, unique (key_id, product_id, starts_at))`.
  - Optional `product_plans(product_id, plan_id)` if plans and products are separate.
- **Data affected:** existing keys have no entitlements. Existing published scripts have no product mapping.
- **Backfill:** create a `legacy` product, map the intended scripts, and insert `key_entitlements` for active keys. If the owner prefers a clean cut, skip the backfill and require manual assignment.
- **Rollback:** drop the new tables. Old validation still uses the old query until the service is switched.
- **Downtime:** none for table creation; the service switch is the cutover.
- **Compatibility:** keep `resolveScriptAccess` old behavior behind a feature flag until the new query is verified. Then switch.
- **Order:** before executor-first validation is enabled.

### M4 — Script access traceability

- **Purpose:** correlate grants with executor sessions and record denial reasons.
- **Changes:**
  - Add `script_access_logs.key_session_id uuid references key_sessions(id)`.
  - Add `script_access_logs.entitlement_id uuid references key_entitlements(id)` if M3 uses that table.
  - Add `script_access_logs.denial_code text`.
  - Index `(key_session_id, created_at)`.
- **Data affected:** old rows have nulls.
- **Backfill:** none required; old rows remain null. Optionally backfill `key_session_id` only where an exact mapping exists; do not guess.
- **Rollback:** drop columns.
- **Downtime:** none.
- **Compatibility:** old inserts omit the columns.
- **Order:** after M3.

### M5 — Admin-only HWID reset transition (D2)

- **Purpose:** make admin reset the only reset path without deleting history.
- **Changes:** no required schema change. Add a `system_settings` row `hwid.self_reset_enabled = false` (data change, not migration), and route/service gating.
- **Data affected:** existing `key_hwid_resets` rows keep `performed_by='self'`; do not rewrite history.
- **Backfill:** none.
- **Rollback:** set the setting back to `true` and restore the route.
- **Downtime:** none.
- **Compatibility:** old clients receive a clear denial; admin path remains.
- **Order:** after the owner approves the deprecation window.

**Migration note:** if a schema-level enforcement is required, add a check or trigger that only allows `performed_by='admin'` for new rows, but that would break historical self rows unless scoped by `created_at`. A service-level gate is simpler and reversible.

### M6 — Key secret separation and rotation

- **Purpose:** stop using `SESSION_HMAC_SECRET` for key material.
- **Changes:**
  - Add `KEY_HMAC_SECRET` and `KEY_HMAC_KEY_VERSION` to environment configuration.
  - Add `keys.key_hash_version text not null default 'v1'`.
  - Add `key_sessions.session_token_hash_version text not null default 'v1'`.
  - Add `rate_limit`/idempotency version awareness if the secret is used there (it is not for key hashing; idempotency uses `RATE_LIMIT_HMAC_SECRET`, so keep that).
- **Data affected:** all key hashes and key session hashes.
- **Backfill:** cannot recompute key hashes without plaintext. Use dual verification:
  - New keys are hashed with `KEY_HMAC_SECRET` and version `v2`.
  - Old rows keep `v1` and are verified with `SESSION_HMAC_SECRET`.
  - On successful activation/validation, optionally upgrade the row to `v2` if the plaintext is available (activation/validation both receive the key), and update the version.
  - Key session tokens are only available at activation; new sessions use `v2`; old sessions expire or are revoked.
- **Rollback:** keep both secrets configured; revert code to v1 verification. Do not remove `SESSION_HMAC_SECRET` for key verification until no v1 rows remain.
- **Downtime:** none.
- **Compatibility:** old rows remain verifiable.
- **Risk:** if `KEY_HMAC_SECRET` is lost, all v2 keys/sessions are invalid. Back it up in the secret manager. This is a high-severity operational risk.
- **Order:** before production scale, ideally before M1 code is deployed if the owner wants a clean secret boundary.

### M7 — Optional claim record

- **Purpose:** make the first-activation claim explicit and auditable.
- **Changes:** `license_claims(id, key_id unique, principal_type, principal_ref, claimed_at, claimed_ip, client_version)`; or columns on `keys` (`claimed_at`, `claim_kind`, `claim_ref`).
- **Data affected:** existing keys with `owner_discord_id` are backfilled as `claim_kind='discord'`; unowned keys remain null.
- **Rollback:** drop the table/columns; ownership falls back to `owner_discord_id`.
- **Downtime:** none.
- **Compatibility:** old activation still writes `owner_discord_id`; new code writes both during the transition.
- **Order:** with M1.

### 10.1 Migration order and dependencies

```text
M0 baseline
  -> M1 executor session identity
  -> M2 nonce store
  -> M3 entitlements
  -> M4 script log traceability
  -> M5 D2 admin-only reset transition
  -> M6 key secret separation
  -> M7 optional claim record
```

M2 and M3 are independent of M1 at the schema level but are needed by the executor service. M6 can start before M1 if the owner wants secret separation first, but it touches the same service and should be coordinated.

---

## 11. Compatibility with Phase 4 and Phase 5

### 11.1 Phase 4 compatibility

| Phase 4 behavior | Compatibility rule |
|---|---|
| Web activation/validation | Keep working; do not route executor traffic through these handlers |
| Owner dashboard reads | Keep `owner_discord_id` reads for Discord-owned keys |
| Admin routes | Keep `access:"admin"` and CSRF; do not weaken |
| Self-service reset | Disable by policy/feature flag; do not delete history |
| Key audit actions | Keep existing actions; add executor actions |
| HWID normalization v1 | Keep; do not silently change the version |
| Key session one-active-per-key | Keep unless the owner approves multi-session |
| Idempotency | Keep; extend scope for executor, do not store tokens |
| Rate limit | Keep; add executor dimensions |
| Error codes | Keep existing codes; add `timestamp_invalid` only with approval |

### 11.2 Phase 5 compatibility

Phase 5 owns bans, proposals, reversal requests, and reactivation authorizations. Executor-first must not start or duplicate Phase 5.

- Executor activation must still honor `banned`, `revoked`, and `suspended`.
- A suspended key still requires an unused `key_reactivations` row, created by Phase 5.
- An executor-only key has no Discord owner, so Phase 5 owner reversal routes (`requested_by` references `users`) would not be usable by that principal. This is a **Phase 5 design impact**, not a Phase 4 regression. It must be addressed when Phase 5 is designed, not hidden in the executor implementation.
- `key_bans.reviewed_by`, `key_ban_reversals.requested_by`, and `key_reactivations.authorized_by` all reference `users`. If D1 removes Discord ownership, those FKs need an actor model that supports both users and executor principals, or the owner must accept that executor-only licenses are ineligible for owner-initiated reversal requests.
- Do not modify the Phase 5 state machine during executor-first work.

### 11.3 What must not change

- Discord OAuth and account sessions.
- `DISCORD_OWNER_ID` owner derivation.
- `hasAdminAccess()` and the admin role policy.
- Existing admin route protection.
- Existing migration history.
- `DESIGN.md` tokens and visual rules (no frontend work in this audit).
- `.env.local` and `.env.example` (no configuration change in this audit).

---

## 12. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Executor-first without D3 repeats all-scripts access | High if implemented now | High (license bypass) | Make D3 schema a prerequisite; feature-flag the new validate endpoint |
| `key_sessions.user_id` change breaks existing queries | Medium | High | Search all queries; expand-and-contract; keep web inserts; test PostgreSQL |
| 30-minute session causes constant re-activation | High | Medium | Owner decision on executor TTL; device binding; revocation |
| Lost activation response locks out executor | Medium | Medium | Explicit re-activation/reissue policy; rate limit; audit |
| Nonce table grows unbounded | Medium | Medium | TTL cleanup job; index; monitoring |
| Nonce gives false sense of security | High | Medium | Document limits; do not replace key/session checks |
| Session token theft | Medium | High | TLS, no-store, HWID/session binding, short TTL, revoke, anomaly logging |
| Secret reuse/rotation invalidates keys | High | High | Dedicated `KEY_HMAC_SECRET`, versioned hashes, dual verification, backup |
| Admin reset abuse or retry | Medium | Medium | Idempotency, rate limit, dedicated permission, audit, reason required |
| Self-reset removed too early | Medium | Medium | Feature flag, deprecation window, keep history, impact analysis |
| Enumeration via error codes | Medium | Low/Medium | Generic `invalid_key`, rate limits, uniform timing |
| Executor spoofing | High | Medium | Accept residual risk; do not claim authenticity; consider D18 server-side integration |
| Phase 5 reversal unusable for executor keys | Medium | Medium | Design actor model in Phase 5; do not hack it into executor endpoints |
| PGlite hides real lock contention | Medium | Medium | Run a real PostgreSQL concurrency suite before release |
| Clock skew causes timestamp failures | Medium | Medium | Configurable tolerance; return server time; document |
| Client version gate locks out users | Medium | Medium | Allowlist with graceful deprecation; telemetry |
| Admin rate limits disrupt operations | Low | Low | Separate admin policy; monitor |

---

## 13. Additional Owner Decisions Still Needed

Each item is a decision, not a recommendation already approved.

1. **Claim policy (D1):** Option A (key-only claim), B (pre-assigned owner), C (hybrid), or D (anonymous). Recommended: A, with a neutral principal record.
2. **Executor session TTL:** keep 30 minutes, use a sliding idle window with a longer absolute cap, or another policy. Recommended: owner-defined absolute cap (e.g. 12-24 hours) plus idle timeout and device binding.
3. **Multi-session policy:** keep one active session per key, or allow multiple executor sessions. The partial unique index currently enforces one.
4. **HWID requirement:** require `hwid` for executor activation/validation, or allow a reduced-assurance session when the platform cannot supply one.
5. **Session-level HWID binding:** add `hwid_hash` to `key_sessions` (recommended) or compare the existing fingerprint.
6. **Timestamp tolerance:** e.g. ±60 s, ±120 s, ±300 s. Recommended: ±120 s with a documented clock-skew allowance.
7. **Nonce TTL and scope:** per session, per key, or global; retention at least the tolerance window. Recommended: global unique hash with session/key references and TTL.
8. **Error disclosure:** allow status-specific codes for a proven key holder, or use one generic denial. Recommended: generic `invalid_key` for unknown/malformed; status-specific only for a valid key.
9. **Lost-response policy:** allow re-activation with a new idempotency key and a new session, require a dashboard/admin reissue, or force a new license. Recommended: allow re-activation with rate limit and audit; do not consume an activation for a session reissue.
10. **Entitlement model:** Option A (`plan_scripts`) or Option B (`products` + `product_scripts` + `key_entitlements`). Recommended: B if products and billing terms differ.
11. **Legacy key backfill:** grandfather existing keys into a `legacy` product, or require manual assignment before enforcement. Recommended: explicit `legacy` product, no silent all-scripts grant.
12. **New key generation:** require a product/plan ID for every new key after D3. This changes the admin API contract.
13. **`KEY_HMAC_SECRET` rollout:** introduce before production, with versioned hashes and dual verification. Decide whether old keys are reissued or kept on v1 indefinitely.
14. **Admin reset enforcement:** service-level feature flag or database-level restriction; whether a dedicated `key.hwid_reset_admin` permission is added.
15. **Self-reset deprecation:** immediate disable, short window, or long window; how users are notified.
16. **Executor session revocation semantics:** whether revoke is per-token only (recommended) or revokes the key's active session(s).
17. **Client version enforcement:** required, warn-only, or disabled; what the supported range is.
18. **Executor API versioning:** is `/api/executor/v1` frozen once shipped, or can it change under the same version?
19. **Audit actor model:** add `actor_type`/`actor_ref` or use nullable `actor_user_id` plus metadata.
20. **Phase 5 actor model:** how reversal/reactivation references work for executor-only licenses.
21. **Rate limit policy:** per-key, per-IP, per-session values for activation, validation, and revoke.
22. **Response envelope:** introduce `{ data }`/`{ error }` for `/api/executor/v1` or keep bare bodies for consistency with the old API.

---

## 14. Recommended Implementation Order

**No step below is authorized by this audit.**

1. **Owner review of this report.** Resolve the decisions in §13, especially claim policy, TTL, entitlement model, and error disclosure.
2. **Design approval for D3.** Choose Option A or B; define the product/plan/script catalog semantics with `DESIGN.md` and the future catalog API.
3. **Migration design review.** Expand-and-contract plan for `key_sessions`, nonce storage, entitlements, and key hash versions. No destructive step in the first migration.
4. **Implement D3 schema and backfill.** Create products/scripts mapping and explicit key entitlements. Keep the old query behind a flag.
5. **Implement executor session identity.** Nullable `user_id`, `principal_type`, `principal_ref`, `client_version`, `hwid_hash`. Add the claim record.
6. **Implement nonce/replay storage and cleanup.** Atomic insert, TTL, monitoring.
7. **Implement executor service and routes.** Activation, validation, revocation, error contract. Reuse the Phase 4 transaction skeleton and audit.
8. **Implement D2 transition.** Disable self-reset, keep history, add admin idempotency/rate limit/permission.
9. **Separate key secrets.** `KEY_HMAC_SECRET`, version columns, dual verification, rotation runbook.
10. **Test on real PostgreSQL.** Row-lock contention, nonce race, duplicate activation, idempotency replay, revocation, entitlement denial, admin reset.
11. **Update documentation.** `BACKEND.md` key rules, `IMPLEMENTATION_PLAN.md` phase scope, and the Phase 4 report's stated limitations.
12. **Only then** consider Phase 5 integration work for bans/reversals with executor principals.

---

## 15. Summary Table

| Area | Kondisi aktual | Gap | Perlu migration | Prioritas |
|---|---|---|---|---|
| Activation auth | Account session + Discord required | D1 cannot be met | Yes (session identity) | P0 |
| Key session user | `key_sessions.user_id NOT NULL` | No key-only session | Yes | P0 |
| Claim policy | No claim record; writes `owner_discord_id`/`user_id` | First-activation policy undefined | Yes | P0 |
| Validation freshness | No timestamp/nonce/client version | Replay and version gaps | No for validator; yes for nonce store | P0 |
| Nonce replay | No table; `replay_detected` unused | No replay defense | Yes | P0 |
| Script entitlement | `resolveScriptAccess` ignores key/plan | D3 violated | Yes | P0 |
| Self-service reset | Active | D2 violated | No (service/route) | P0 |
| Session lifetime | 30-minute absolute | Unsuitable for executor | No (config/service); optional schema | P1 |
| Session HWID binding | Fingerprint stored, never checked | Token usable on another device | Yes (hash) or service-only | P1 |
| Lost activation response | Replay omits token; active key denied | No recovery path | No (policy/service) | P1 |
| Key secret reuse | `SESSION_HMAC_SECRET` for keys | Rotation blast radius | Yes (version columns) | P1 |
| Admin reset | Exists and audited | No idempotency/rate limit/permission | No (service/route) | P1 |
| Executor error contract | `timestamp_invalid` missing; missing bearer returns 400 | Inconsistent executor errors | No (code) | P1 |
| Audit actor | `actor_user_id` only | No executor principal | Yes | P2 |
| Script log traceability | No `key_session_id`/denial code | Weak correlation | Yes | P2 |
| Admin route limits | No rate limits | Retry/abuse risk | No | P2 |
| Cleanup jobs | No visible nonce/rate-limit cleanup | Table growth | Maybe (job only) | P2 |
| Phase 5 actor model | Reversal/reactivation FKs require `users` | Executor-only licenses cannot use owner reversal | Yes (Phase 5 design) | P2 |
| Roblox authenticity | D18 deferred | Client cannot be proven genuine | No (design/acceptance) | P2 |

---

## 16. Final Verification

### 16.1 Git status before the audit

```text
 M .env.example
 M src/core/env.ts
 M src/core/errors.ts
 M src/db/idempotency.ts
 M src/routes/index.ts
 M test/env.test.ts
 M test/helpers/http.ts
?? docs/reports/phase-4-implementation-report.md
?? src/core/crypto/
?? src/modules/access/
?? src/modules/keys/
?? src/routes/keys.ts
?? src/validators/
?? test/helpers/keys.ts
?? test/hwid.test.ts
?? test/keys-http.test.ts
?? test/keys-service.test.ts
?? test/keys-unit.test.ts
```

`HEAD` was `871bf63 feat(auth): add primary Discord owner identity`; the baseline tag was `phase-3c1-accepted-baseline` at `3494e7e`.

### 16.2 Git status after the audit

```text
 M .env.example
 M src/core/env.ts
 M src/core/errors.ts
 M src/db/idempotency.ts
 M src/routes/index.ts
 M test/env.test.ts
 M test/helpers/http.ts
?? docs/reports/executor-first-architecture-audit.md
?? docs/reports/phase-4-implementation-report.md
?? src/core/crypto/
?? src/modules/access/
?? src/modules/keys/
?? src/routes/keys.ts
?? src/validators/
?? test/helpers/keys.ts
?? test/hwid.test.ts
?? test/keys-http.test.ts
?? test/keys-service.test.ts
?? test/keys-unit.test.ts
```

The only difference from §16.1 is the addition of `?? docs/reports/executor-first-architecture-audit.md`. `git diff --stat` after the audit still reports only the seven pre-existing modified files:

```text
 .env.example          |  5 +++++
 src/core/env.ts       | 17 +++++++++++++++++
 src/core/errors.ts    | 18 ++++++++++++++++++
 src/db/idempotency.ts | 22 +++++++++++++++++++---
 src/routes/index.ts   |  6 +++++-
 test/env.test.ts      | 16 ++++++++++++++++
 test/helpers/http.ts  | 12 ++++++++++--
 7 files changed, 90 insertions(+), 6 deletions(-)
```

`HEAD` remained `871bf63 feat(auth): add primary Discord owner identity`. No new commit was created.

### 16.3 Changed-file statement

- No source code, migration, configuration, or dependency was changed by this audit.
- The only file added by this audit is `docs/reports/executor-first-architecture-audit.md`.
- No commit was created.
- The pre-existing uncommitted Phase 4 files listed in §16.1 remain exactly as they were before the audit.

### 16.4 Verification method

The final status is re-run with `git status --short` and compared with §16.1. The only expected new entry is the audit report. Any other difference is a failure of the audit-only constraint and must be reverted before handoff.
