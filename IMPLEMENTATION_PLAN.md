# BOYFINITY Hub - Implementation Plan

**Version:** 1.0
**Status:** Planning only. No application code, migrations, dependency installation, Git initialization, or deployment has been performed.
**Date:** 2026-11-10 (D1a deferral reaffirmed and D2 reviewed on 2026-11-11)
**Primary specification:** `BACKEND.md` (149,871 bytes, SHA-256 `0FA9260A1D6930B9715E4B8456395C8872CCEE8A25CF448DB601AA71DAFAE7F3`)
**Reference snapshot:** `BACKEND.documentation-complete.checkpoint.md` (identical byte size and SHA-256 at planning time)
**Frontend specification:** `DESIGN.md` (Version 1.1)
**Agent process rules:** `AGENTS.md`

**Architecture decision status:** D1 is **FINAL — OWNER APPROVED** (Model A). D1a is **UNAPPROVED — DEFERRED** by the owner. D2 was reviewed on 2026-11-11 and remains **UNAPPROVED**; the review recommends Option A. Every other decision remains open. See Section 5.

This document is an implementation blueprint. It does not claim that any module exists, has been tested, or has been deployed. Every file, route, job, and migration named here is planned unless it is already listed in `BACKEND.md`.

Contents:

1. Executive summary
2. Documentation audit
3. Architecture overview
4. Recommended tech stack
5. Architecture decisions requiring approval
6. Module dependency map
7. Proposed project structure
8. Phased implementation roadmap
9. Security review
10. Testing strategy
11. Risk register
12. Production readiness checklist
13. Unresolved questions

---

## 1. Executive Summary

BOYFINITY Hub is a centralized script catalog and access-control platform. Discord OAuth establishes account identity. A key binds one account to one device at a time and authorizes script retrieval. Subscriptions and free-key offers grant access. A permanent ban workflow handles confirmed key sharing. A reversal workflow plus a separate reactivation authorization provides a controlled exception path.

The documentation set is internally reconciled for the ban, reversal, and reactivation model. `BACKEND.md` and its checkpoint have matching hashes. The technical work now is implementation planning, not another specification rewrite.

### Recommended direction

- **One project:** a single Next.js App Router application with TypeScript, serving the public site, user dashboard, admin dashboard, and API. This is Model A, approved as D1.
- **One API entry point:** the only API Route Handler is `app/api/[...path]/route.ts`, which dispatches to modules under `src/`. No root `api/` directory is mixed into a Next.js app, and no second `route.ts` exists under `app/api/`.
- **Runtime and hosting:** Node.js runtime, with PostgreSQL and object storage from Supabase. **Hosting is not selected.** D1a is **UNAPPROVED — DEFERRED**; Vercel Pro appears throughout this plan only as the historical research baseline, and Helipod VPS S Jakarta only as an unapproved candidate. Nothing in this document should be read as a chosen or approved host. See Section 5.2.8.
- **Data access:** direct parameterized SQL over the Supavisor pooled connection, wrapped by a small typed query layer. Transactions, row locks, and conditional updates are required by Sections 8 and 9 and are awkward through a REST client.
- **Authentication:** custom Discord OAuth with a server-side `sessions` table, because Section 9.11 requires opaque, hashed, revocable sessions and `logout-all`. Same-origin requests keep session cookies first-party.
- **Payments:** a provider-independent `PaymentVerifier` interface. No provider is selected in the documentation, so provider choice remains an owner decision. **Owner decision 2026-11-11 (Section 5.4.9): Midtrans and Duitku are both retained candidates with eligibility pending. The owner has not registered with either and will submit eligibility assessments to both in parallel; selection follows the first written, product-specific approval. The payment adapter is BLOCKED and D3 remains UNAPPROVED.** Stripe is not available to an Indonesian merchant; Xendit was dropped on its fee structure.
- **Testing:** Vitest for units and integration, Playwright for end-to-end, plus direct SQL tests for constraints and concurrency.
- **Monitoring:** structured JSON logs plus the `audit_logs` and `script_access_logs` tables as durable records. Platform runtime logs are short-lived on every candidate (one hour to one day depending on plan) and are not an audit store.

### Sequencing principle

No module starts before its dependencies exist. The critical path is:

`decisions -> foundation and schema -> auth and roles -> catalog -> keys -> bans, reversals, reactivation -> monetization -> offers -> admin completion -> hardening -> production`

Payments and offers can run in parallel after key issuance exists. Frontend shell work can run in parallel after the design system and auth contract are stable.

### Invariants this plan preserves

1. A banned key cannot activate, validate, reset HWID, or hold a live session.
2. An approved reversal moves the key to `suspended`, never to `active`, and never creates a reactivation authorization.
3. Reactivation requires a separate admin authorization with `key.reactivation` and a written reason.
4. Activation consumes an unused authorization exactly once, inside the same transaction that binds the device and issues the key session.
5. A requester cannot approve or reject their own reversal request.
6. Owner reversal routes authorize by authenticated ownership, never by an administrative permission.
7. Client-supplied Discord IDs, roles, permissions, confidence values, and HWID values are never authoritative.
8. Rejected and cancelled reversal requests leave the ban confirmed and the key banned.
9. Approval and rejection are separate permissions, and neither implies the other.
10. All sensitive actions write audit rows with server-derived actor identity.

### Not in this plan

No code, no migrations, no dependency installation, no `git init`, no deployment, and no modification of `BACKEND.md`, `BACKEND.documentation-complete.checkpoint.md`, `BACKEND.md.bak`, `DESIGN.md`, or `AGENTS.md`. No executor injection, anti-cheat bypass, or unauthorized game integration is designed.

---

## 2. Documentation Audit

### 2.1 Files inspected

| File | Role | Size | SHA-256 or state |
|---|---|---|---|
| `BACKEND.md` | Primary current backend specification | 149,871 bytes | `0FA9260A1D6930B9715E4B8456395C8872CCEE8A25CF448DB601AA71DAFAE7F3` |
| `BACKEND.documentation-complete.checkpoint.md` | Immutable reference snapshot | 149,871 bytes | Same hash as `BACKEND.md`, verified before planning |
| `BACKEND.md.bak` | Frozen pre-ban snapshot | 86,232 bytes | Not used as authority; older than the ban, reversal, and reactivation model |
| `DESIGN.md` | Official frontend design system, Version 1.1 | 13,274 bytes | Frontend authority only |
| `AGENTS.md` | Agent routing and quality rules | 1,843 bytes | Process authority only |
| `Boyfinity-ViolenceDistrict-Main.lua` | Existing Roblox client script | 396,959 bytes | Out of scope; not modified |

The hash match between `BACKEND.md` and the checkpoint confirms that planning started from the finalized document. `BACKEND.md.bak` predates the ban model and must not be used to resolve conflicts.

### 2.2 Structure of the primary specification

`BACKEND.md` contains 16 sections:

1. Scope and non-goals
2. Technology stack
3. Unified monolithic serverless engine
4. Discord authentication
5. Script management
6. Key management, including the FINAL ban rules
7. Monetization and offers
8. Database architecture, including ban, reversal, and reactivation tables
9. API specification, including owner reversal and admin review routes
10. Admin dashboard backend and permission catalogue
11. Security architecture
12. Vercel deployment architecture
13. Required diagrams
14. Implementation roadmap
15. Risks and unresolved decisions
16. Final notes

### 2.3 Consistency findings

| Finding | Location | Impact | Resolution |
|---|---|---|---|
| Documentation status is recorded as complete | Preamble | Confirms the spec is ready for planning | Accepted |
| Ban, reversal, and reactivation model is reconciled across Sections 8, 9, and 10 | Sections 8 to 10 | Primary dependency for Phases 5 and 8 | Accepted as authoritative |
| Deployment model is selected as Model A | Plan Section 5, D1 | Removes the largest Phase 1 ambiguity | FINAL - owner approved. `BACKEND.md` still needs to record the entry point when documentation edits are allowed. |
| Hosting tier and commercial terms are not selected | Plan Sections 4.15 and 5, D1a | A commercial platform is not eligible for Vercel Hobby | Research complete. Owner approval required before any deployment. |
| Stale reconciliation note | Section 8, `key_ban_reversals` bullet | Says Sections 9 and 10 still describe open and cancel as admin actions with `key.ban.reversal`. Sections 9 and 10 no longer do. | Documentation-only cleanup needed. Not edited in this task. Sections 9 and 10 remain the current API description. |
| Legacy snapshot still on disk | `BACKEND.md.bak` | Could confuse a future reader | Treat as historical only. Do not use for implementation. |
| Ambiguous phrase "revived state" | Section 6.11 | Could be read as `active` | Sections 8 and 9 define the revived state as `suspended`, followed by separate reactivation. Use that meaning. |
| Design system is separate from backend | `DESIGN.md` | No backend behavior impact | Frontend must use its tokens and AntiSlop gates. |

No undocumented endpoint was assumed. No missing behavior was invented. Items the specification leaves open are recorded in Section 13.

### 2.4 Documentation gaps that affect implementation

These gaps do not invalidate the specification. They require an owner decision or a small documentation amendment before or during the named phase.

1. **Idempotency storage is not specified.** Activation, ban apply, ban proposal, reversal creation, and reactivation authorization require `Idempotency-Key`, but Section 8 defines no idempotency table. A storage design is required in Phase 1.
2. **Rate-limit storage is not specified.** Section 11 requires a shared store, but no table or external service is named. A Postgres table is the lowest-dependency option; an external cache is an alternative.
3. **No TTL for `pending_approval`.** A reversal request can remain open indefinitely. The workflow is correct, but the review queue can accumulate stale requests.
4. **No cancellation reason column.** Cancellation records `cancelled_at` and an audit row, but `key_ban_reversals` has no cancellation reason field.
5. **Reactivation is scoped to reversed bans.** `key_reactivations.ban_id` is not null and references a reversed ban. A key suspended for another reason has no documented reactivation path.
6. **No expiry on reactivation authorizations.** An unused authorization remains valid until consumed. There is no `expires_at` column.
7. **Payment provider is unnamed.** The architecture is provider-independent, but checkout and webhook implementation cannot start without one.
8. **Offer signing schemes are not specified in detail.** work.ink and LootLabs callback formats must be verified against current provider documentation.
9. **Hosting tier and commercial terms are not selected (D1a).** Model A is approved, but the Vercel plan is not. Hobby is restricted to non-commercial personal use, so the platform requires Pro or Enterprise.
10. **Session ownership is not selected.** Custom OAuth and Supabase Auth are both documented.
11. **HWID derivation is not selected.** The normalization source and canonical string are implementation details for the key phase.
12. **Retention windows are not set.** Log and access-record retention affects partitioning and privacy.
13. **`key.ban_evidence_viewed` is required by Section 10 but is not in the Section 8 audit action examples.** The action column is explicitly illustrative, so this is a documentation polish item, not a behavioral conflict.
14. **The evidence-read audit requirement does not explicitly cover reversal request reads.** Section 10.5 states those reads carry no evidence rows, so the omission is consistent, but it should be stated as intentional.

### 2.5 Precedence rules used by this plan

1. A FINAL decision in `BACKEND.md` overrides earlier softer wording in the same document.
2. Sections 8, 9, and 10 are read together. Where an older note in Section 8 describes a superseded API shape, Sections 9 and 10 describe current behavior.
3. `BACKEND.md.bak` has no authority.
4. `DESIGN.md` governs visual decisions only.
5. Where the specification is silent, this plan proposes an option and marks it for owner approval. It does not silently implement a guess.

---

## 3. Architecture Overview

### 3.1 System shape

```text
Browser
  |
  v
Vercel edge and CDN
  |-- static assets and public pages
  |-- one API function under /api: app/api/[...path]/route.ts
        |
        v
  in-handler middleware chain
  (request id, body limits, session, rate limit, CSRF, validation)
        |
        v
  data-driven router
        |
        +--> auth, users, catalog, keys, trust and safety,
        |    subscriptions, transactions, offers, admin
        |
        +--> services and repositories
                |
                +--> Supabase PostgreSQL (pooled connection)
                +--> Supabase Storage (script blobs, images)
                +--> Discord OAuth
                +--> payment provider
                +--> work.ink / LootLabs
```

The phrase "one function" in this plan means one API function under `/api`. A Next.js deployment may also emit page-render functions and a middleware function; those are not additional API entry points. The API pipeline runs inside the Route Handler, not in Next.js middleware, and it is the only place that opens database connections.

The browser never talks to PostgreSQL directly. All application data access goes through the server function using the service role. RLS remains enabled with default deny as defense in depth, not as the primary authorization mechanism.

### 3.2 Frontend architecture

- Next.js App Router with TypeScript and Tailwind, using the tokens and rules in `DESIGN.md`.
- Public routes: landing, script catalog, game pages, documentation, changelog, announcements.
- Authenticated routes: dashboard overview, keys, key detail, reversal request form, subscriptions, transactions, offers, devices, profile, settings.
- Admin routes: overview, users, games, scripts, keys, bans, reversal review queue, reactivation authorizations, subscriptions, transactions, offers, announcements, changelogs, audit log, settings.
- Server Components for read-heavy pages. Client Components only where interaction requires them.
- All authenticated data is fetched same-origin from `/api/*` with cookies. No service role key and no Discord client secret in the browser.
- Authentication state comes from `GET /api/auth/session`. A client-side flag is a display hint, never an authorization decision.
- Every data view implements empty, loading, and error states as required by the frontend contract.
- A banned key shows the `BANNED` tag, ban date, and reason summary. Activate, validate, and reset controls are disabled. Evidence is never rendered for ordinary users.

### 3.3 Backend architecture

- The deployment model is FINAL: Model A, one Next.js App Router application. The only API Route Handler is `app/api/[...path]/route.ts`. It parses method and pathname, matches a route table, runs the in-handler middleware chain, calls a module handler, and returns a normalized response.
- No second `route.ts` exists under `app/api/`. No `vercel.json` rewrite routes API traffic, and there is no separate backend project or second deployment.
- The Route Handler declares the Node.js runtime. No database-dependent API operation runs on the Edge runtime. Next.js middleware does not open database connections; session, role, and ownership lookups happen inside the API function.
- Domain mutations are handled through the API router. Server Actions are not used as a second mutation path, so authorization, CSRF, idempotency, rate limiting, and audit behavior remain in one pipeline.
- Payment and offer webhooks verify signatures against the raw request body before any JSON parsing or schema validation.
- Route entries declare method, path pattern, access level (`public`, `user`, `admin`), required permission, schema, and handler.
- Middleware order: request ID, body size and content type, session resolution, rate limit, CSRF for cookie-authenticated state changes, authentication, authorization, validation.
- Modules own business rules. Services own reusable domain operations. Repositories own SQL. A module never builds ad hoc SQL in a route handler.
- All responses use one helper. Errors use `{ "error": { "code": "...", "message": "..." } }` with a stable code and a generic message.
- Every state-changing call accepts or requires `Idempotency-Key` where Section 9 requires it and stores the response for replay.
- The function is stateless. No in-memory session, rate counter, or workflow state is trusted across invocations.

### 3.4 Database architecture

- Supabase PostgreSQL, UUID primary keys, `timestamptz`, integer minor units for money, and `snake_case`.
- Migrations are versioned SQL files applied in order. Schema changes are reviewed, not generated blindly against production.
- Service role is server-only. RLS is enabled on every table with default deny.
- Partial unique indexes enforce one open reversal per ban and one unused reactivation per key.
- CHECK constraints enforce status enums, lifecycle field combinations, and `decided_by <> requested_by`.
- Key activation, ban apply, ban review, reversal approval, and reactivation authorization run in single transactions with the lock order `key_bans`, `key_ban_reversals`, `keys`, `key_sessions`.
- The key row is locked for activation and session creation. Reactivation consumption is a conditional update on `consumed_at IS NULL`.
- Direct database connections are reserved for migrations. Runtime queries use the Supavisor transaction-mode pooled connection.
- Long tables such as `audit_logs` and `script_access_logs` are retention and partitioning candidates after volume is known.

### 3.5 Authentication and Discord OAuth

1. `GET /api/auth/login` generates a high-entropy `state`, stores it in a short-lived HTTP-only cookie or an `oauth_states` row, and redirects to Discord with the `identify` scope. The `oauth_states` row is the Option A mechanism described in Section 5.3.5; it is conditional on D2 resolving to Option A.
2. Discord redirects to `GET /api/auth/callback?code=...&state=...`.
3. The server rejects a missing or mismatched state, exchanges the code server-side with the client secret, fetches `/users/@me`, and upserts the user by immutable `discord_id`.
4. The server creates a session row with a hashed opaque token, sets an HTTP-only, Secure, SameSite cookie, and redirects to the dashboard.
5. Session lifetime is seven days absolute, with rotation on privilege change and a bounded idle window. `POST /api/auth/logout` deletes one session. `POST /api/auth/logout-all` deletes all sessions for the user.
6. Roles are loaded from `user_roles` on every privileged request. A role in a token, header, or body is ignored.

### 3.6 User dashboard

- `GET /api/users/me` and `PATCH /api/users/me` for profile display fields only.
- `GET /api/keys/me` for owned keys with status, ban summary, and binding summary. No raw HWID.
- `POST /api/keys/activate`, `POST /api/keys/validate`, `POST /api/keys/reset-hwid`.
- `GET /api/keys/{id}/usage` and `GET /api/keys/{id}/devices` for the owner only.
- Reversal request create, list, and cancel under `/api/keys/{id}/bans/{banId}/reversal-requests`. These routes use session identity plus key ownership.
- Subscriptions, transactions, offer history, and public catalog views.
- A suspended key from an approved reversal explains that admin reactivation authorization is required. The owner cannot self-authorize.

### 3.7 Admin dashboard

- Permission matrix enforcement from the Section 10 catalogue. Only `admin` holds the six ban and reactivation permissions.
- Ban proposal creation, immediate ban apply, review, evidence viewing, reversal request queue, approve, reject, and reactivation authorization.
- User, game, script, key, subscription, offer, transaction, announcement, changelog, audit, and settings management.
- Evidence reads are field-projected, rate-limited, and audited as `key.ban_evidence_viewed`.
- Every mutating admin route writes an audit row with the server-derived actor.
- Unknown admin routes fail closed. There is no "admin by default" fallback.

### 3.8 Key lifecycle

- Statuses: `unused`, `active`, `expired`, `revoked`, `suspended`, `banned`.
- Generation returns the plaintext key once and stores only a hash plus a display prefix.
- Activation either claims an unused key or rebinds a suspended key that has a valid unused reactivation authorization.
- Validation runs the nine-step server-side flow: hygiene, key lookup, ownership, terminal status, expiry and subscription, device binding where available, session liveness, script authorization, then grant and logging.
- `banned` is evaluated before expiry and session checks, so a banned key never reads as merely expired.
- One active key session per key, enforced by a partial unique index. A new activation supersedes the old session.
- HWID is a keyed hash of a normalized value, never raw, never returned, and never treated as authentication.

### 3.9 Subscriptions and payments

- Plans are database rows for monthly, 3-month, and 6-month durations.
- Checkout creates a pending transaction. The server never trusts a client-supplied price or amount.
- A provider callback is verified against the raw body signature, recorded in `payment_events` with a unique `(provider, provider_event_id)`, and only then marks the transaction paid and grants the subscription or key.
- A periodic reconciliation job can query the provider for pending transactions as a backstop.
- Redirects and client-side status are never proof of payment.

### 3.10 Free-key offers

- `POST /api/offers/start` creates an intent bound to the authenticated user and returns the provider URL.
- The provider calls `POST /api/webhooks/offers/{provider}` server to server.
- The server verifies signature, timestamp tolerance, and event uniqueness, then confirms the intent belongs to the user before issuing a free key.
- A browser redirect is never proof of completion.
- One verified event issues at most one reward.

### 3.11 Ban, reversal, and reactivation

- A proposal is a `key_bans` row with `review_status = 'pending_review'`. It changes no key status and revokes no session.
- A confirmed ban sets `keys.status = 'banned'`, mirrors the ban fields, revokes sessions, writes device history and audit rows in one transaction.
- An owner opens a reversal request with `status = 'pending_approval'`, `requested_by` from the session, and a justification.
- An admin other than the requester approves or rejects. Approval sets the request to `approved`, the ban to `reversed`, the key to `suspended`, clears the binding, and revokes sessions. It never activates.
- Rejection leaves the ban confirmed and the key banned. Cancellation by the requester leaves both enforced.
- Reactivation authorization is a separate admin action under `key.reactivation`. It writes a `key_reactivations` row with a reason and an audit event but does not change key status.
- Owner activation of the suspended key consumes the authorization exactly once, binds the new device, issues a session, and writes `key.ban_reactivation_consumed`.

### 3.12 Security, audit, rate limiting, and errors

- Server-side authorization on every request, with roles and ownership reloaded from the database.
- CSRF protection on cookie-authenticated state changes. Webhooks are exempt because they are signature-verified and not cookie-authenticated.
- Rate limits in a shared store, keyed by IP, user, key, and route class.
- One external error shape. Internal reasons go to audit logs with a request ID, not to the client.
- Audit rows for authentication, key lifecycle, bans, reversal and reactivation transitions, evidence access, payment and offer events, and admin mutations.
- Structured JSON logs with request ID, route, status, and duration. No secrets, tokens, keys, or raw HWID.

### 3.13 Deployment, monitoring, and backups

- Hosting is **not selected**. D1a is **UNAPPROVED — DEFERRED** (Section 5.2.8). Vercel Pro is the historical research baseline only, retained for comparison; it is not a recommendation and not an approval. The platform is commercial, so Vercel Hobby would be ineligible if Vercel were ever selected.
- The Vercel limits below are retained as the planning baseline for cost and duration sensitivity. They describe platform ceilings, not an approved plan, and they do not bind the final host choice.
- Pro limits assumed for planning: 4.5 MB request and response body, 300 second default duration with up to 800 seconds configured, 4 GB and 2 vCPU per instance, 250 MB bundle, 1,024 file descriptors, multiple regions, one day runtime log retention, 6,000 deployments per day.
- Hobby comparison, retained for cost sensitivity: 300 second maximum duration, 2 GB and 1 vCPU, 4.5 MB body, 250 MB bundle, single region, one hour runtime logs, one concurrent deployment.
- One API function under `/api`, many modules. Next.js also emits page and middleware functions; verify the deployed API function list after every configuration change.
- `/api/health` is the liveness probe.
- Durable observability comes from the audit and access-log tables, not from Vercel logs.
- Supabase automated backups plus scheduled logical dumps to independent storage. Restores are tested, not assumed.
- Separate Supabase projects or schemas for preview and production.

### 3.14 Scope boundaries

The platform authorizes distribution of content the operator is permitted to distribute. It does not design executor injection, script injection into third-party games, anti-cheat bypass, or Roblox terms circumvention. Roblox integration is limited to owned or authorized experiences using a server-side, HMAC-signed request from the game server.

---

## 4. Recommended Tech Stack

### 4.0 Summary

| Layer | Recommendation | Owner approval |
|---|---|---|
| Frontend framework | Next.js App Router with React and TypeScript | No, already specified |
| Styling | Tailwind CSS using `DESIGN.md` tokens | No, already specified |
| Backend runtime | Next.js Route Handler on the Node.js runtime, one API function under `/api` | Resolved by D1 (Model A) |
| Language | TypeScript with strict compiler settings | No |
| Database | Supabase PostgreSQL | No, already specified |
| Data access | `pg` driver plus Kysely query builder, with explicit SQL for locks | Yes, alternative is the Supabase client |
| Validation | Zod schemas shared by handlers and OpenAPI | No, small justified dependency |
| Authentication | Custom Discord OAuth with a server-side `sessions` table | Yes, alternative is Supabase Auth |
| Payments | Provider-independent `PaymentVerifier`; **Midtrans and Duitku are both candidates with eligibility pending** (owner decision 2026-11-11, D3 unapproved). Stripe is not available to an Indonesian merchant; Xendit was dropped on its fee structure | Yes, no provider is named in the spec |
| Background jobs | Vercel Cron calling a protected route, backed by a `jobs` table | Yes, scheduler choice |
| Caching | None initially; optional external Redis only if measurements require it | Yes if added |
| API documentation | OpenAPI 3.1 generated from Zod schemas | No |
| Testing | Vitest, Playwright, and direct SQL constraint tests | No |
| Logging and monitoring | Structured JSON logs, Vercel Observability, optional Sentry | Yes for the paid vendor |
| Hosting | **Not selected.** D1a is UNAPPROVED — DEFERRED. Vercel Pro is the retained research baseline only; Helipod VPS S is an unapproved candidate | Yes, D1a hosting tier |
| Storage | Supabase Storage with short-lived signed URLs | No, already specified |

The stack deliberately stays small. The project already depends on Next.js, Vercel, Supabase, Discord, and two offer providers. Adding a second hosting platform, a separate backend framework, or a message broker would be unjustified at this scale.

### 4.1 Frontend framework: Next.js App Router

- **Why it fits:** `BACKEND.md` Section 2.1 already selects Next.js. It provides file routing, server components, Route Handlers, static generation for public pages, and first-class Vercel deployment.
- **Advantages:** One project for frontend and backend, server rendering for public pages, shared TypeScript types, strong ecosystem, preview deployments.
- **Disadvantages:** Opinionated routing, build output that creates functions per Route Handler, and a real conflict between a literal root `api/index.js` and Next.js routing.
- **Operational complexity:** Low to moderate. One build, one deployment, one framework to upgrade.
- **Alternatives:** Remix or React Router, Astro for content pages, a plain React SPA. None removes enough complexity to justify a second stack.
- **Dependency verdict:** Required by the specification, not an unnecessary addition.

### 4.2 Styling: Tailwind CSS with `DESIGN.md` tokens

- **Why it fits:** Section 2.7 selects Tailwind, and `DESIGN.md` defines the palette, spacing, radius, and typography.
- **Advantages:** Token mapping through configuration, fast iteration, no runtime CSS-in-JS cost, consistent utility vocabulary.
- **Disadvantages:** Class-heavy markup, easy to drift into arbitrary values, requires discipline to keep design tokens authoritative.
- **Operational complexity:** Low. Build-time only.
- **Alternatives:** CSS Modules, vanilla-extract. Both are viable but add a parallel styling model next to the documented Tailwind choice.
- **Dependency verdict:** Already specified. No new dependency beyond Tailwind itself.

### 4.3 Backend runtime and framework: Model A on the Node.js runtime

**Status:** FINAL — OWNER APPROVED on 2026-11-10 as decision D1.

- **Selected model:** Model A. One Next.js App Router application serves the frontend and backend. The API entry point is `app/api/[...path]/route.ts`. It parses method and pathname, matches a route table, runs the in-handler middleware chain, calls a module handler, and returns a normalized response.
- **Runtime:** Node.js. Database-dependent operations, cryptography, and the `pg` pool require Node.js APIs and must not run on the Edge runtime.
- **Same-origin:** Browser and API requests share one origin. Session cookies are first-party, so `SameSite` can stay strict without cross-site exceptions. CSRF protection is still required on cookie-authenticated state changes.
- **Function count:** One API function under `/api`. Next.js may also emit page-render and middleware functions; the constraint applies to the API surface, not to the entire deployment.
- **Deployment constraints:** No second `route.ts` under `app/api/`, no `vercel.json` rewrite for API routing, and no separate backend deployment. A separate backend would reintroduce cross-origin session handling and a second deployment target.
- **Consequences:** Domain mutations go through the API router, not Server Actions. Next.js middleware performs no database access. Webhook signature verification reads the raw request body before parsing. Authorization, idempotency, rate limiting, and audit behavior all live in the single API pipeline.
- **Why Model A:** Keeps frontend and backend in one deployable unit, one session model, one deployment, one set of environment variables, and one API surface to test. It satisfies the spec's unified serverless engine without a rewrite.
- **Rejected alternative - Model B:** A standalone Node project with `api/index.js` and a Vercel rewrite. It remains valid only if a literal `api/index.js` is mandatory. It was rejected because it splits the project into two deployments, duplicates configuration, and complicates same-origin sessions, CSRF, and preview testing.
- **Dependency verdict:** No new backend framework. D1 is architectural, not a dependency.

### 4.4 Language: TypeScript in strict mode

- **Why it fits:** The project has many status enums, permission strings, and response contracts that benefit from compile-time checks.
- **Advantages:** Shared types between server and client, safer refactors, better editor support, enforceable null handling.
- **Disadvantages:** Build step, occasional type friction with third-party SDKs, slower initial development than plain JavaScript.
- **Operational complexity:** Low. Type checking runs in CI.
- **Alternatives:** JavaScript with JSDoc. Rejected because the domain has too many state transitions to track without types.
- **Dependency verdict:** TypeScript is a build-time dependency with a clear payoff.

### 4.5 Database: Supabase PostgreSQL

- **Why it fits:** Sections 2.4 and 8 require PostgreSQL with strong constraints, partial unique indexes, transactions, and row locks. Supabase also supplies Storage and backups.
- **Advantages:** Managed Postgres, mature SQL feature set, connection pooler, RLS, Storage, dashboard, automated backups.
- **Disadvantages:** Plan limits, pooler behavior to understand, service role bypasses RLS, vendor coupling.
- **Operational complexity:** Low to moderate. Migrations and connection management need discipline.
- **Alternatives:** Neon, PlanetScale, Turso. PlanetScale lacks the foreign-key and transaction profile this schema expects. Neon is a credible Postgres alternative but adds a second vendor next to Storage.
- **Dependency verdict:** Already specified and appropriate.

### 4.6 Data access: `pg` plus Kysely over the pooled connection

- **Why it fits:** The key and ban workflows need `SELECT ... FOR UPDATE`, conditional updates, multi-statement transactions, and partial-index violation handling. A typed SQL builder keeps queries parameterized and readable.
- **Advantages:** Real transactions and row locks, full SQL control, compile-time column types, no hidden N+1 behavior, easy to test against Postgres.
- **Disadvantages:** More SQL knowledge required than a REST client, manual migration typing, Kysely adds a dependency and a learning curve.
- **Operational complexity:** Moderate. One pool per function instance, lazy initialization, transaction helper, and migration tooling.
- **Alternatives:** Supabase JS client, Drizzle, raw `pg`, Prisma. The Supabase client is convenient for CRUD but weak for explicit locks and conditional updates. Drizzle is a credible alternative with a similar profile. Prisma adds a query engine and less direct control over locking.
- **Dependency verdict:** Kysely is justified by the concurrency requirements. Raw `pg` alone would also work and is the fallback if the owner wants fewer dependencies. This choice requires approval because Section 11.1 mentions the Supabase client or query builder.

### 4.7 Validation: Zod

- **Why it fits:** Every route needs schema validation, and the same schemas can drive OpenAPI and TypeScript types.
- **Advantages:** Runtime validation, composable schemas, clear error messages that can be mapped to a generic external error, strong TypeScript inference.
- **Disadvantages:** One more dependency, schema duplication risk if not treated as the single source, runtime cost is small but nonzero.
- **Operational complexity:** Low. Schemas live beside route definitions.
- **Alternatives:** Yup, Valibot, JSON Schema with Ajv. Zod has the best TypeScript ergonomics for this project.
- **Dependency verdict:** Justified. The specification requires schema-based validation on every payload.

### 4.8 Authentication and sessions: custom Discord OAuth

- **Why it fits:** Section 9.11 requires opaque session tokens stored hashed, server-side expiry, immediate revocation, and `logout-all`. A custom `sessions` table gives exact control.
- **Advantages:** Full control over lifetime, rotation, revocation, audit, and cookie attributes. No second auth model layered over the app.
- **Disadvantages:** More security-sensitive code to write and test. State handling, token exchange, and session rotation are easy to get subtly wrong.
- **Operational complexity:** Moderate. Requires careful tests for state, replay, fixation, and revocation.
- **Alternatives:** Supabase Auth with the Discord provider. Faster, but the session model belongs to Supabase and must still be reconciled with the app's role and audit requirements.
- **Dependency verdict:** No new vendor. The custom option adds code, not infrastructure. This choice requires owner approval.

---

### 4.9 Payments: provider-independent interface, Midtrans and Duitku both pending

- **Why it fits:** Section 7.5 requires an abstract `PaymentVerifier` with one implementation per provider. No provider is named in the specification.
- **Advantages:** The domain code stays provider-neutral. Adding or replacing a provider is an adapter change. Webhook verification, idempotency, and reconciliation have one contract.
- **Disadvantages:** An abstraction has a cost. Provider-specific features such as taxes, subscriptions, and dispute handling still leak into operations.
- **Operational complexity:** Moderate. Requires a provider account, webhook endpoint, signing secret, reconciliation job, and sandbox testing.
- **Candidates assessed 2026-11-11 (Section 5.4):** **Midtrans and Duitku are both retained, both pending written eligibility approval** — neither is selected. Xendit was dropped on a conditional USD 50/month minimum fee that triggers at this volume; Stripe is unavailable in Indonesia (Preview, contact-sales only). Non-Indonesian options such as Paddle, Lemon Squeezy, and PayPal were not part of this review because the operating entity and target market are Indonesian and those processors do not settle IDR to an Indonesian merchant account on the same terms.
- **Dependency verdict:** The interface is justified. A specific SDK is not installed until the owner selects a provider. **D3 is reviewed but UNAPPROVED; the payment adapter is BLOCKED. Selection requires the eight-item written eligibility checklist in Section 5.4.9 to be satisfied first.**

### 4.10 Background jobs: Vercel Cron plus a Postgres job table

- **Why it fits:** Expiry checks, payment reconciliation, and cleanup need scheduled work. Section 12 already defines a `CRON_SECRET`.
- **Advantages:** No broker, no worker service, one deployment model. The job table gives idempotency, retries, and an audit trail.
- **Disadvantages:** Legacy Vercel Cron on Hobby cannot run more than once per day, while Pro allows once per minute. Schedules, the successor feature, is in beta and allows every 15 minutes on Hobby. Both allow 100 jobs per project under legacy Cron. Long jobs compete with request duration limits.
- **Operational complexity:** Low to moderate. A protected internal route, a job table, and an overlap lock are enough.
- **Alternatives:** Supabase `pg_cron` for database-only jobs, GitHub Actions scheduled workflows, an external scheduler, or a queue service. A queue is unnecessary until job volume or latency demands it.
- **Dependency verdict:** No new infrastructure. The job table is small and testable. Scheduler choice requires approval.

### 4.11 Caching: none initially

- **Why it fits:** The workload is low-volume and correctness-sensitive. A cache in front of key status or ban state would create a revocation race.
- **Advantages:** No stale authorization, no extra vendor, simpler incident response.
- **Disadvantages:** Higher database read load as traffic grows. Public catalog pages may feel slower without caching.
- **Operational complexity:** None at the start.
- **Alternatives:** Vercel CDN caching for public catalog pages with short revalidation; Upstash Redis for rate limits or sessions if Postgres contention appears.
- **Dependency verdict:** Adding a cache now would be premature. It requires measurement and owner approval before introduction.

### 4.12 API documentation: OpenAPI 3.1 from Zod schemas

- **Why it fits:** The API surface is large, and Sections 9 and 10 define stable permissions, errors, and state transitions. A generated contract keeps the implementation aligned.
- **Advantages:** One source for validation and documentation, machine-readable client generation, contract tests, easier review.
- **Disadvantages:** Generated output still needs curation, and some response shapes are easier to describe manually.
- **Operational complexity:** Low. Generate during CI and publish as a static artifact.
- **Alternatives:** A hand-written OpenAPI file, or no machine-readable contract. Hand-writing duplicates validation rules and drifts.
- **Dependency verdict:** A small generator dependency is justified. It is not a runtime dependency.

### 4.13 Testing: Vitest, Playwright, and SQL constraint tests

- **Why it fits:** The critical risks are state transitions, authorization, and concurrency, not rendering. The test stack must exercise real Postgres constraints.
- **Advantages:** Fast unit tests, API integration tests against a real database, browser tests for the critical user and admin paths, no second test runner.
- **Disadvantages:** Playwright adds browser binaries in CI, and database tests need isolation and cleanup.
- **Operational complexity:** Moderate. A test database, seeded fixtures, and a reset strategy are required.
- **Alternatives:** Jest, Cypress, Postman collections. Jest is slower with ESM and TypeScript. Cypress is viable but Playwright handles multiple browser contexts and concurrency better.
- **Dependency verdict:** Justified. The specification's invariants cannot be validated by unit tests alone.

### 4.14 Logging and monitoring: structured JSON, Vercel Observability, optional Sentry

- **Why it fits:** Section 12.7 requires structured logs and warns that runtime logs are short-lived. Durable records must live in Postgres.
- **Advantages:** Request IDs correlate logs, redaction prevents secret leakage, Vercel Observability covers invocations and errors, Sentry adds stack traces and release tracking if approved.
- **Disadvantages:** One more vendor if Sentry is added, noise if log levels are not disciplined, and no long-term log retention on either plan.
- **Operational complexity:** Low for JSON logging, moderate for an error-tracking vendor.
- **Alternatives:** Plain `console` JSON, Axiom, Datadog, Better Stack. Start with the built-in platform and add a vendor only when needed.
- **Dependency verdict:** A small logger such as Pino is justified for redaction and consistent fields. A paid vendor is optional and requires approval.
- **Retention:** Vercel runtime logs last one hour on Hobby and one day on Pro. Neither replaces the audit tables.

### 4.15 Hosting and deployment: not selected, D1a deferred

- **Status:** D1a is **UNAPPROVED — DEFERRED** (Section 5.2.8). D1 selects the deployment model, not the hosting plan. No host is chosen, and this subsection is research retained for comparison.
- **Commercial eligibility constraint:** any host must permit commercial use, because the platform sells subscriptions and processes payments. Vercel Hobby is limited to non-commercial personal use, so Vercel would require Pro or Enterprise if it were ever selected. This is a constraint on any future choice, not a selection.
- **Historical baseline, not a recommendation:** earlier revisions of this plan recommended Vercel Pro for one deploying seat. That recommendation was **superseded by the owner's deferral** and is retained only as the cost and limits baseline against which other options were compared. It must not be read as an approved or preferred host.
- **Why the research is retained:** Sections 2.2, 3, and 12 of `BACKEND.md` name Vercel, and the Vercel figures are the yardstick used in Section 5.2 to compare Render, Railway, Cloudflare, and the Helipod VPS candidate. Deleting it would remove the comparison basis. It is not an approval.
- **Disadvantages:** recurring platform fee, on-demand overage risk, optional Password Protection charged per protected project, and Supabase billed separately.
- **Operational complexity:** Low for a managed platform. A VPS alternative trades that for OS patching, TLS renewal, process supervision, and backup verification.
- **Alternatives still on the table:** the Helipod VPS S Jakarta candidate (unverified, owner-supplied), Render, Railway, Cloudflare Workers (rejected for D1 incompatibility), and the Vercel baseline. **None is approved.** See Section 5.2.8 for the full candidate record and unverified terms.
- **Dependency verdict:** Vercel is named in `BACKEND.md`, but the hosting tier and provider require owner approval as D1a. Procurement, account registration, domain purchase, and deployment are blocked until then.

### 4.16 Storage: Supabase Storage

- **Why it fits:** Script content, game images, and downloadable assets need object storage. Section 2.6 selects Supabase Storage.
- **Advantages:** Same vendor and auth model, S3-compatible API, CDN delivery, signed URL support.
- **Disadvantages:** Egress pricing, object storage is wrong for small frequently updated metadata, signed URL lifetime must be handled carefully.
- **Operational complexity:** Low. Bucket policy, content type validation, and signed URL issuance.
- **Alternatives:** Cloudflare R2, Vercel Blob, S3. R2 is attractive for egress, but adds a vendor.
- **Dependency verdict:** Already specified and appropriate for large blobs.

### 4.17 Package management and CI: pnpm and GitHub Actions

- **Why it fits:** Deterministic installs and a place to run type checks, lint, unit tests, integration tests, and the OpenAPI generation check.
- **Advantages:** Fast installs, strict dependency resolution, reproducible CI, a clear quality gate before Vercel deploys.
- **Disadvantages:** One more tool for contributors to install, and CI minutes are finite.
- **Operational complexity:** Low.
- **Alternatives:** npm, Yarn, GitLab CI, Vercel-only checks. npm is acceptable if the owner prefers fewer tools.
- **Dependency verdict:** Tooling only. It does not affect runtime behavior.

---

## 5. Architecture Decisions and Status

The specification resolves the domain model but leaves several implementation and vendor choices open. This plan recommends a default for each. D1 is approved; every other row is a recommendation only and is not applied until the owner approves it.

| ID | Decision | Recommendation | Why it matters | Blocks | Status |
|---|---|---|---|---|---|
| D1 | Deployment model A or B | Model A: one Next.js app with `app/api/[...path]/route.ts`, Node.js runtime | Keeps frontend and backend in one deployable unit and avoids mixing root `api/` with Next.js | Phase 1 | **FINAL — OWNER APPROVED** |
| D1a | Hosting tier and commercial terms | **DEFERRED by owner on 2026-11-10.** Helipod VPS S Jakarta is a candidate only, not approved | Budget target is approximately IDR 100,000/month all-in; no provider is approved and procurement is postponed until funds are available | Hosting procurement, account registration, domain purchase, database subscription, deployment, and production launch. It does **not** block architecture, schema, security, or review work | **UNAPPROVED — DEFERRED** |
| D2 | Session ownership | **RECOMMENDED (reviewed 2026-11-11, not yet approved):** custom Discord OAuth with a `sessions` table. Supabase Auth assessed and not recommended. See Section 5.3 | Exact control of hashed opaque tokens, revocation, rotation, and audit; Supabase Auth's JWT sessions cannot meet the Section 9.11 revocation requirement without added infrastructure | Phase 2 | **REVIEWED — OWNER APPROVAL REQUIRED** |
| D3 | Payment provider | **REVIEWED 2026-11-11, updated by owner decision 2026-11-11, UNAPPROVED:** Midtrans and Duitku are **both retained candidates with eligibility pending** — neither is selected. The owner has not registered with either and will submit eligibility assessments to both in parallel; selection follows the first **written, product-specific** approval, not response order or onboarding speed. Xendit was dropped on a conditional USD 50/month minimum fee that triggers at this volume; Stripe is not available to an Indonesian merchant. See Section 5.4, especially 5.4.9 | No provider is named in the spec; checkout and webhooks cannot be built without one. **The payment adapter is BLOCKED until the eight-item written eligibility checklist in Section 5.4.9 is satisfied** | Phase 6 | **REVIEWED — OWNER APPROVAL REQUIRED** |
| D4 | Free-key eligibility | Offer completion required, plus a per-user rate limit and a cap | Prevents offer farming while preserving the documented free-key flow | Phase 7 | Unapproved |
| D5 | HWID source and normalization | Per-platform trusted source, versioned canonical string, HMAC-SHA-256 with `HWID_HASH_SECRET` | The hash is only meaningful if the input is stable and documented | Phase 4 | Unapproved |
| D6 | Moderator capabilities | No ban, reversal, reactivation, or evidence permissions; limited non-sensitive operations only | Section 10 assigns all six ban permissions to admin only | Phase 8 | Unapproved |
| D7 | Retention windows | Separate windows for sessions, access logs, audit logs, and ban evidence | Privacy, storage cost, and partition design depend on it | Phase 10 | Unapproved |
| D8 | Data access library | `pg` plus Kysely, with raw SQL for locks | Row locks and conditional updates are required by the workflow | Phase 1 | Unapproved |
| D9 | Scheduler | Vercel Cron plus a Postgres job table and `CRON_SECRET` | Needed for expiry, reconciliation, and cleanup jobs | Phases 6 and 7 | Unapproved |
| D10 | Idempotency storage | A table with scope, key, actor, request hash, status, response body, and expiry | Section 9 requires replay-safe calls but defines no store | Phase 1 | Unapproved |
| D11 | Rate-limit storage | Postgres fixed-window or token-bucket table; external Redis only if needed | Serverless instances do not share memory | Phases 1 and 4 | Unapproved |
| D12 | Reversal request TTL | A configurable expiry, proposed as 14 days, with a cleanup job | Prevents an indefinite `pending_approval` queue | Phase 5 | Unapproved |
| D13 | Cancellation reason | Store a nullable `cancellation_reason` or keep the reason in audit metadata only | The current table has no cancellation reason field | Phase 5 | Unapproved |
| D14 | Reactivation outside reversal | Keep the current scope: only a reversed ban creates an authorization | Extending scope would require a schema and workflow change | Phase 5 | Unapproved |
| D15 | Approval audit name | Keep `key.ban_reversal` | Renaming would churn Sections 8, 9, and 10 for no behavior gain | None | Unapproved |
| D16 | Approver may authorize reactivation | Allow it, as Section 10 states | Self-approval rule applies only to the reversal decision | None | Unapproved; previously resolved in the domain model |
| D17 | Error-tracking vendor | Start with Vercel Observability; add Sentry only if needed | A paid vendor is not required for correctness | Phase 9 | Unapproved |
| D18 | Roblox integration credentials | Per-place server credential, HMAC with timestamp and nonce | Section 9.13 requires server-side authentication, not client trust | Phase 4 | Unapproved |

D1 is resolved. D1a is resolved **as deferred** by the owner, which closes the planning gate without approving any provider; its procurement block remains in force. **D3 was reviewed on 2026-11-11 and updated by owner decision on 2026-11-11; it remains UNAPPROVED, with Midtrans and Duitku both pending written eligibility approval and the payment adapter blocked.** D2, D3, D8, D10, and D11 should be resolved before Phase 1 ends. D5 and D18 should be resolved before Phase 4. D4, D9, and D12 to D14 should be resolved before their owning phases. D7 and D17 can wait until hardening, but delaying D7 too long complicates table design.

### 5.1 D1 - Deployment model (FINAL)

**Status:** FINAL — OWNER APPROVED on 2026-11-10.

**Decision:** Model A. One Next.js App Router application serves the frontend and backend. The only API entry point is `app/api/[...path]/route.ts`.

**Rationale:** One deployable unit, one session model, one environment configuration, one API pipeline for authorization and audit, and no separate backend deployment to secure or monitor. Model B would split the project and complicate same-origin sessions, CSRF, preview testing, and deployment.

**Architecture consequences:**

- `app/api/[...path]/route.ts` is the only API Route Handler. No second `route.ts` exists under `app/api/`.
- No `vercel.json` rewrite routes API traffic, and there is no separate `api/index.js` backend project.
- The handler declares the Node.js runtime. Database-dependent operations never run on the Edge runtime.
- Next.js middleware performs no database access. Session, role, and ownership lookups run inside the API function.
- Browser and API requests are same-origin, so session cookies stay first-party. CSRF protection is still enforced on cookie-authenticated state changes.
- Webhook signatures are verified against the raw request body before parsing.
- Domain mutations go through the API router, not Server Actions.
- "One function" means one API function under `/api`. Page-render and middleware functions may also exist and are not API entry points.

**Deployment and function constraints:** One API function reduces cold-start surface, deployment drift, and function-count limits. It also means the API bundle must stay under the platform bundle cap and all API routes share one runtime configuration. Next.js function detection can create an extra API function if another `route.ts` appears under `app/api/`, so the deployed function list is a release check.

**Rejected alternative - Model B:** A standalone Node project with `api/index.js` and a Vercel rewrite. It remains documented for comparison but is not the selected architecture. It is appropriate only if a literal `api/index.js` is mandatory.

### 5.2 D1a - Hosting tier and commercial terms (UNAPPROVED)

**Status:** **UNAPPROVED — DEFERRED** by the owner on 2026-11-10 and **reaffirmed on 2026-11-11**. Hosting procurement is postponed until the owner has sufficient funds. No account was registered, no VPS or domain was purchased, no subscription was changed, and nothing was deployed. D1 remains FINAL — OWNER APPROVED (Model A). The alternative-hosting research below is retained as historical comparison and is not an approval of any provider. Other sections still show the earlier Vercel baseline; that baseline is also not a current recommendation and is reconciled only if and when D1a is decided.

**Reason for deferral:** The owner has decided to postpone VPS purchasing until sufficient funds are available. This is a funding decision, not a technical rejection of any provider.

**Research question:** Which provider is the cheapest option that genuinely permits commercial use and preserves D1: one Next.js App Router application, one catch-all API Route Handler at `app/api/[...path]/route.ts`, Node.js runtime, no separate backend application, and same-origin frontend/API requests?

**Cost boundary:** All prices are USD as published on 2026-11-10. They exclude sales tax/VAT, domain registration, paid APM, and overages beyond the stated assumptions. The database is priced as a separate line on Supabase Pro because `BACKEND.md` selects Supabase PostgreSQL and Supabase Storage. Provider-native Postgres is not substituted, because that would change the approved data platform.

**Official sources checked 2026-11-10:**

- Vercel baseline: `https://vercel.com/pricing`, `https://vercel.com/docs/plans/hobby`, `https://vercel.com/docs/plans/pro-plan`, `https://vercel.com/docs/limits`, `https://vercel.com/docs/limits/fair-use-guidelines`, `https://vercel.com/docs/functions/limitations`, `https://vercel.com/docs/schedules/cron-jobs/usage-and-pricing`, `https://vercel.com/docs/schedules/limits`, `https://vercel.com/docs/functions/runtimes/node-js`.
- Render: `https://render.com/pricing`, `https://render.com/docs/web-services`, `https://render.com/docs/deploy-nextjs-app`, `https://render.com/docs/cronjobs`, `https://render.com/docs/disks`, `https://render.com/docs/regions`, `https://render.com/docs/deploys`, `https://render.com/docs/rollbacks`, `https://render.com/docs/logging`, `https://render.com/docs/platform-features-by-plan`, `https://render.com/docs/outbound-bandwidth`, `https://render.com/docs/compute-plans`, `https://render.com/docs/node-version`, `https://render.com/docs/configure-environment-variables`, `https://render.com/terms`.
- Railway: `https://railway.com/pricing`, `https://docs.railway.com/reference/pricing`, `https://docs.railway.com/reference/pricing/plans`, `https://docs.railway.com/reference/pricing/faqs`, `https://docs.railway.com/guides/nextjs`, `https://docs.railway.com/guides/cron-jobs`, `https://docs.railway.com/reference/regions`, `https://docs.railway.com/reference/volumes`, `https://docs.railway.com/observability`, `https://docs.railway.com/reference/deployments`, `https://docs.railway.com/guides/variables`, `https://railway.com/legal/terms`, `https://railway.com/legal/acceptable-use`.
- Cloudflare Workers: `https://developers.cloudflare.com/workers/platform/pricing/`, `https://developers.cloudflare.com/workers/platform/limits/`, `https://developers.cloudflare.com/workers/framework-guides/web-apps/nextjs/`, `https://developers.cloudflare.com/workers/runtime-apis/nodejs/`, `https://developers.cloudflare.com/workers/reference/how-workers-works/`, `https://developers.cloudflare.com/workers/configuration/cron-triggers/`, `https://developers.cloudflare.com/hyperdrive/`, `https://developers.cloudflare.com/workers/configuration/versions-and-deployments/`.
- Supabase: `https://supabase.com/pricing`, `https://supabase.com/docs/guides/platform/regions`, `https://supabase.com/docs/guides/database/connecting-to-postgres`, `https://supabase.com/docs/guides/database/connecting-to-postgres/serverless-drivers`, `https://supabase.com/kb/troubleshooting/disabling-prepared-statements-qL8lEL`.

#### 5.2.1 Verified facts

**Render**

- Workspace plans: Hobby **$0/month + compute**, Pro **$25/month + compute**, Scale **$499/month + compute**. Hobby is limited to **1 member** and **25 services**; Pro adds unlimited seats/services, 25 GB bandwidth, 14-day logs, and 15 retained builds.
- Hobby includes **5 GB/month outbound bandwidth**; overage is **$0.15/GB**. Pro includes 25 GB. Inbound bandwidth is free.
- Web compute: **0.5 CPU / 512 MB at $7/month**, **1 CPU / 2 GB at $25/month**, **2 CPU / 4 GB at $85/month**. The free instance is 0.1 CPU / 512 MB and is not production-appropriate.
- Cron jobs are separate services: **$0.00016/minute**, minimum **$1/month per cron service**, maximum **12 hours** per run, and no persistent disk.
- Persistent disks are **$0.25/GB/month** and disable zero-downtime deploys. They are unnecessary because storage is on Supabase.
- Regions: Oregon, Ohio, Virginia, Frankfurt, **Singapore**. Node.js default is **24.22.1**, configurable via `NODE_VERSION`, `.node-version`, `.nvmrc`, or `engines`.
- Next.js is deployed as a Node web service with a build command and `next start`; the official guide documents exactly that path. The runtime is full Node.js.
- Environment variables and secret files are supported; secret files are capped at 1 MB per service. Rollbacks reuse retained build artifacts. Paid services deploy with zero downtime unless a persistent disk is attached.
- Hobby runtime logs are retained **7 days**; **HTTP request logs are Pro-only**. Hobby also lacks autoscaling, preview environments, and audit logs.
- Render Terms of Service contain **no plan-based non-commercial restriction** and expressly contemplate commercial use. The Hobby description ("for individuals building personal projects and prototypes") is positioning, not a contractual ban. Pro is described as the tier for teams deploying production-grade apps.

**Railway**

- Plans: Free **$0** with $1/month credit, Hobby **$5/month including $5/month usage**, Pro **$20/month including $20/month usage**.
- Usage: **CPU $20/vCPU-month**, **RAM $10/GB-month**, **egress $0.05/GB**, **volumes $0.15/GB-month**. The Hobby bill is the greater of $5 or actual usage; Pro is the greater of $20 or actual usage.
- Hobby limits: 48 vCPU / 48 GB per service, 6 replicas, 5 GB volume, **7-day logs**. Pro: 1,000 vCPU / 1 TB per service, 42 replicas, 30-day logs.
- The official Next.js guide supports standalone output, Node.js runtime, Postgres, and pre-deploy migrations. The runtime is full Node.js.
- Cron jobs are separate services. The minimum interval is **5 minutes**, schedules use UTC, timing has no absolute minute precision, and the process must exit cleanly without leaving connections open.
- Regions: US West (California), US East (Virginia), EU West (Amsterdam), **Southeast Asia (Singapore)**.
- Variables support shared values and **sealed variables**; deployments support zero-downtime overlap and rollback within the plan's image-retention window (72 hours on Hobby, 120 hours on Pro).
- Railway's Acceptable Use Policy contains **no non-commercial clause**. The pricing FAQ states: "If you are supporting a commercial application, we highly recommend you to upgrade to the Pro plan for higher resource limits and access to priority support." Railway also documents that Pro/Enterprise workloads may be prioritized over Free/Hobby during high demand, and that Hobby deployments can be paused or queued while Pro is not affected.

**Cloudflare Workers**

- Workers Paid is **$5/month minimum** and includes **10 million requests**, **30 million CPU-milliseconds**, Hyperdrive, Cron Triggers, and **20 million log events** with **7-day retention**. Requests overage is **$0.30/million**; CPU overage is **$0.02/million CPU-ms**. Egress is free. Workers Free is 100,000 requests/day with 10 ms CPU and is not viable for this workload.
- Hard limits: **128 MB memory per isolate**, **64 MiB uncompressed Worker bundle**, **5 minutes maximum CPU time** (default 30 seconds), **6 simultaneous outgoing connections** per request, **128 environment variables** per Worker, and **250 Cron Triggers** per account.
- Cron Triggers are included, run in UTC, have a **15-minute wall-time limit**, and have CPU limits of 30 seconds for intervals under one hour or 15 minutes for intervals of one hour or more.
- Workers run as **V8 isolates on Cloudflare's global network**, with no region selection. They are not containers and do not run a conventional Node.js process.
- Cloudflare supports a **subset of Node.js APIs** plus polyfills. The documentation explicitly says many npm packages need these APIs and that some methods are stubbed or throw. This is compatibility, not a Node.js runtime.
- The documented Next.js path is **vinext**, and the documentation states: "**vinext is in beta.**" `vinext` is a Vite plugin that reimplements the Next.js API surface; `vinext check` must be run against the project, and the compatibility dashboard must be reviewed. App Router is listed as supported, but image optimization is only partially supported and `next/*` imports are "mostly supported." OpenNext is the alternative for existing OpenNext applications.
- Hyperdrive supports Postgres, including Supabase, and the documentation shows `pg` with a `Client` created per request. Hyperdrive maintains the underlying pool. Cloudflare documents `pg` support; **Kysely plus Hyperdrive is not officially validated** in the sources reviewed.
- Versions, deployments, gradual rollouts, and rollbacks are supported. R2 provides object storage, but Supabase Storage is already selected.

**Supabase (database line, all providers)**

- Pro starts at **$25/month** and includes a **$10/month compute credit** that covers one **Micro** instance ($10, 1 GB RAM, 60 direct / 200 pooler connections). Included: 8 GB disk per project, 250 GB egress, 100 GB file storage, 7-day backups, and 7-day logs.
- Free is **$0** with 500 MB database storage and **pauses after one week of inactivity**; it has no backups. It is not a production database for this platform.
- Singapore is available as a general APAC region and as `ap-southeast-1`.
- Supavisor transaction mode (port 6543) does **not support prepared statements or query pipelining**, and session-level state is lost between transactions. The client must disable prepared statements and keep the pool size at 1 in serverless environments. Direct connections are for migrations and administrative work.
- `pg` is supported. The Supabase documentation gives a Kysely example for Vercel and a Cloudflare Workers driver list that includes `node-postgres`; a combined Kysely + Hyperdrive configuration still requires project-level validation.

#### 5.2.2 Commercial eligibility findings

1. **Cloudflare Workers Paid is commercially eligible.** It is a standard paid self-serve plan with no non-commercial restriction in the pricing or limits documentation. Commercial eligibility is not the reason to reject it; D1 compatibility is.
2. **Render Hobby is commercially permitted.** No plan-based non-commercial clause was found in the Terms, and the Terms expressly address commercial use. The Hobby tier's limits (one member, 25 services, 5 GB bandwidth, 7-day logs, no HTTP request logs, no autoscaling) are operational constraints, not a commercial-use ban. The owner may still ask Render support for written confirmation before purchase.
3. **Railway Hobby is permitted but not the vendor-recommended commercial tier.** The Terms and Acceptable Use Policy contain no non-commercial prohibition, but the pricing FAQ recommends Pro for commercial applications, and Railway documents that Hobby workloads may be deprioritized or paused during high demand while Pro is not. Treat Railway Hobby as a cost-saving option with a reliability and support caveat, not as the default production tier.
4. **Vercel Hobby remains non-commercial.** The earlier finding is unchanged: the platform sells subscriptions and processes payments, so Vercel Pro or Enterprise is required if Vercel is retained. Vercel Pro remains the known-compatible fallback at about **$45/month** including Supabase Pro.

#### 5.2.3 Provider comparison

| Criterion | Render | Railway | Cloudflare Workers |
|---|---|---|---|
| Commercial eligibility | Hobby permitted; Terms expressly contemplate commercial use; Pro is the production-positioned tier | Hobby permitted; vendor recommends Pro for commercial; Hobby can be deprioritized | Paid plan is clearly commercial; no non-commercial restriction found |
| D1 compatibility | **Full.** Full Node.js, Next.js `next start`, catch-all Route Handler, `pg` + Kysely, Supavisor transaction mode | **Full.** Full Node.js, Next.js standalone, catch-all Route Handler, `pg` + Kysely, Supavisor transaction mode | **Partial.** V8 isolate, Node.js subset, vinext beta, 128 MB memory, 64 MiB bundle; not a Node.js runtime |
| Security and reliability | Managed TLS and DDoS protection, private network, zero-downtime deploys; Hobby has no HTTP request logs or autoscaling | Managed TLS, zero-downtime overlap, regional private networking; Hobby can be deprioritized during high demand | Strong edge DDoS/TLS and global anycast; beta runtime, 128 MB memory ceiling, no region selection |
| Cost, minimal / growth / higher | $33.00 / $54.00 / $65.63 | $32.25 / $41.72 / $61.40 | $30.00 / $30.30 / $36.90 |
| Operational complexity | Low: connect repo, build, start, add cron service | Low: connect repo or Dockerfile, add cron service, manage usage | High: vinext migration, Workers limits, Hyperdrive, connection and runtime testing |
| Migration risk | Low: standard Next.js Node deployment | Low: standard Next.js Node deployment | High: would reopen D1 and require a full compatibility pass |
| Overall | **Recommended candidate** | **Runner-up; cheapest conventional** | **Not recommended under D1** |

**Ranking rationale:**

1. **Render** ranks first because it is the cheapest option that combines full D1 compatibility with commercial terms that do not require leaving Hobby. It also has a Singapore region, a documented Next.js Node path, cron, rollbacks, and no documented Hobby deprioritization.
2. **Railway** is the absolute cheapest conventional option, but its own documentation recommends Pro for commercial applications and allows Hobby workloads to be deprioritized. It is a valid cost-saving choice only if the owner accepts that trade-off.
3. **Cloudflare Workers** advertises the lowest total, but it fails the approved architecture. The Workers runtime is a V8 isolate with a Node.js API subset, not a Node.js process; the recommended Next.js path is beta `vinext`; and the 128 MB memory ceiling is a hard risk for Next.js SSR. Choosing it would require reopening D1, not merely changing the hosting plan.

#### 5.2.4 Cost scenarios

**Assumptions (not measured application data):**

- One always-on Next.js web service and one scheduled job. No separate background worker, queue, or paid APM.
- Supabase Pro Micro at **$25/month** for one project. No Supabase disk, egress, storage, or compute overage is assumed.
- No persistent disk and no provider-native database. Storage remains on Supabase.
- Minimal: 512 MB RAM, 0.1 vCPU average, 1 million dynamic requests/month, 5 GB app egress/month, daily one-minute cron.
- Expected early growth: 1 GB RAM (Railway) or 2 GB RAM (Render), 0.25 vCPU average, 3 million dynamic requests/month, 25 GB app egress/month, cron every 15 minutes for one minute.
- Higher usage: 2 GB RAM, 0.5 vCPU average, 15 million dynamic requests/month, 100 GB app egress/month, cron every 5 minutes for two minutes.
- Cloudflare CPU assumptions: 10 ms/request minimal, 15 ms/request growth, 20 ms/request higher. A 50 ms/request sensitivity is shown below.
- Taxes, VAT, domain fees, and currency conversion are excluded. Prices can change.

**Render**

| Line item | Minimal | Expected growth | Higher usage |
|---|---:|---:|---:|
| Hobby workspace | $0.00 | $0.00 | $0.00 |
| Web compute | $7.00 (0.5 CPU / 512 MB) | $25.00 (1 CPU / 2 GB) | $25.00 (1 CPU / 2 GB) |
| Cron service | $1.00 (minimum) | $1.00 (minimum; metered $0.46) | $1.38 (8,640 minutes × $0.00016) |
| Bandwidth | $0.00 (5 GB included) | $3.00 (20 GB × $0.15) | $14.25 (95 GB × $0.15) |
| Logs and monitoring | $0.00 | $0.00 | $0.00 |
| Supabase Pro | $25.00 | $25.00 | $25.00 |
| **Total** | **$33.00** | **$54.00** | **$65.63** |

Render higher-memory alternative: **2 CPU / 4 GB at $85** gives **$125.63** ($85 + $1.38 + $14.25 + $25). A 512 MB launch with a pre-approved upgrade to 1 CPU / 2 GB costs **$51.00** at minimal traffic ($25 + $1 + $0 + $25).

**Railway**

Railway bills the greater of the plan fee or metered usage. The application usage below is RAM GB × $10 + vCPU × $20; cron usage assumes 0.5 GB RAM and 0.1 vCPU only while the job runs.

| Line item | Minimal | Expected growth | Higher usage |
|---|---:|---:|---:|
| App usage | $7.00 (0.5 GB × $10 + 0.1 × $20) | $15.00 (1 GB × $10 + 0.25 × $20) | $30.00 (2 GB × $10 + 0.5 × $20) |
| Cron usage | $0.005 (30 minutes) | $0.47 (2,880 minutes) | $1.40 (8,640 minutes) |
| Egress | $0.25 (5 GB × $0.05) | $1.25 (25 GB × $0.05) | $5.00 (100 GB × $0.05) |
| Metered usage | $7.25 | $16.72 | $36.40 |
| Hobby bill (max of $5 or usage) | $7.25 | $16.72 | $36.40 |
| Supabase Pro | $25.00 | $25.00 | $25.00 |
| **Total** | **$32.25** | **$41.72** | **$61.40** |

Railway Pro alternative: the bill is the greater of $20 or metered usage. That gives **$45.00 / $45.00 / $61.40** before Supabase, or **$70.00 / $70.00 / $86.40** including Supabase. The Pro tier removes the Hobby deprioritization caveat and adds 30-day logs.

**Cloudflare Workers**

| Line item | Minimal | Expected growth | Higher usage |
|---|---:|---:|---:|
| Workers Paid | $5.00 | $5.00 | $5.00 |
| Requests | $0.00 (1M included) | $0.00 (3M included) | $1.50 (5M over × $0.30) |
| CPU time | $0.00 (10M CPU-ms included) | $0.30 (15M over × $0.02) | $5.40 (270M over × $0.02) |
| Cron | $0.00 | $0.00 | $0.00 |
| Logs | $0.00 | $0.00 | $0.00 |
| Egress | $0.00 | $0.00 | $0.00 |
| Supabase Pro | $25.00 | $25.00 | $25.00 |
| **Total** | **$30.00** | **$30.30** | **$36.90** |

Cloudflare sensitivity: at 50 ms CPU per request, expected growth is **$32.40** and higher usage is **$45.90**. These totals exclude the cost of engineering time for a vinext migration and the risk that the app exceeds 128 MB memory or the 64 MiB bundle limit. A memory failure is not a billing overage; it is an outage or a forced architecture change.

**Vercel baseline (for comparison, not a new recommendation):** Vercel Pro is **$20/month** including a $20 usage credit, plus Supabase Pro **$25/month**, for about **$45/month** before overage. Hobby remains non-commercial. The alternatives above are cheaper only if the owner accepts a Hobby-tier workspace or Cloudflare's compatibility risk.

#### 5.2.5 Render 512 MB assessment

512 MB is the **minimum viable** size, not a comfortable production size. A Next.js App Router server with Node.js, React Server Components, `pg`, Kysely, session handling, and JSON logging can fit in 512 MB at low concurrency, but it leaves little headroom for SSR bursts, image work, or memory fragmentation. The 0.5 CPU allocation compounds the risk under concurrent requests.

Use 512 MB only as a launch tier with memory and latency alerts, a documented upgrade trigger (for example, sustained RSS above roughly 70% or repeated OOM restarts), and a pre-approved move to 1 CPU / 2 GB. The expected-growth and higher-usage scenarios therefore use **1 CPU / 2 GB at $25/month**. If the owner wants a comfortable launch rather than a minimum-cost launch, start at 1 CPU / 2 GB; the minimal total becomes **$51/month**.

#### 5.2.6 Research ranking

**Research candidate: Render Hobby with 0.5 CPU / 512 MB at $33/month for a minimum-cost launch, or 1 CPU / 2 GB at $54/month for expected growth.** Render is the cheapest option reviewed that genuinely satisfies both requirements: it runs the approved single Next.js Node.js app without changing D1, and its commercial terms do not require leaving Hobby. It provides a Singapore region, a documented Next.js deployment path, cron, rollbacks, 7-day runtime logs, TLS, DDoS protection, and zero-downtime deploys without a persistent disk. The 512 MB tier is accepted only with the monitoring and upgrade conditions in §5.2.5.

This ranking is historical and is **not an approval**. The owner deferred procurement on 2026-11-10 (§5.2.8). None of the providers below is authorized.

**Runner-up: Railway Hobby at $32.25/month minimal and $41.72/month expected growth.** It is the absolute cheapest conventional option and fully D1-compatible, but Railway explicitly recommends Pro for commercial applications and may deprioritize Hobby workloads. If the owner wants the vendor-recommended commercial tier, Railway Pro is **$45/month at minimal and expected growth** and **$61.40/month at higher usage** before Supabase. That is still competitive with Render's 1 CPU / 2 GB growth plan, but it is not cheaper than the Render Hobby recommendation at launch.

**Rejected for D1: Cloudflare Workers.** It is the cheapest at **$30.00-$36.90/month**, but it is not a conventional Node.js host, the recommended Next.js path is beta `vinext`, and the 128 MB memory ceiling is a hard production risk. Selecting it would require reopening D1 and accepting a different runtime model, not just a cheaper plan.

**Fallback (historical, not approved): Vercel Pro at about $45/month plus Supabase.** It remains the least risky Next.js integration and the known baseline, but it is not cheaper than the Render or Railway Hobby options. Like every option in this subsection, it is a research artifact and not an approval; D1a is deferred (Section 5.2.8).

#### 5.2.7 Technical risks and unresolved questions

- **Actual memory and CPU are unmeasured.** The 512 MB conclusion is an estimate until the app is built and load-tested. The first production week must record RSS, p95 latency, restart count, and OOM events.
- **Supavisor transaction mode requires client discipline.** Disable named prepared statements, avoid query pipelining, avoid session-level state, and use a direct connection for migrations. `pg` plus Kysely is expected to work but must be integration-tested against the pooled connection string.
- **Cloudflare + Kysely + Hyperdrive is unverified.** Cloudflare documents `pg` and Hyperdrive separately; the combined Kysely path is not officially validated. `vinext check` has not been run against this project, and `vinext` is beta.
- **Render Hobby commercial acceptance is inferred from the Terms, not confirmed in writing.** The Terms contain no non-commercial restriction, but the owner may request written confirmation before paying.
- **Railway Hobby commercial acceptance is permitted but not recommended by Railway.** The owner must decide whether the Pro recommendation and Hobby deprioritization are acceptable for a paid platform.
- **No Hobby tier includes a contractual uptime SLA.** Render, Railway, and Cloudflare paid self-serve plans do not provide the enterprise SLAs; the platform should be designed for retries and graceful degradation.
- **Logs are short-lived on every candidate.** Render Hobby and Railway Hobby retain 7 days; Cloudflare Paid retains 7 days; Vercel Pro retains 1 day. Durable audit data must stay in Postgres.
- **Prices, plan limits, and terms can change.** Re-verify before purchase and before launch. Taxes/VAT, payment-method requirements, and currency conversion are excluded from the estimates.
- **Unresolved owner choices:** All provider choices are on hold while D1a is deferred. When procurement resumes, the owner must compare a verified Helipod all-in cost against Render Hobby, Railway Hobby or Pro, and Vercel Pro, and decide whether a VPS's operational burden is acceptable.

#### 5.2.8 Owner decision (2026-11-10, reaffirmed 2026-11-11): D1a DEFERRED

**Decision:** D1a is deferred, not approved. The owner will reconsider VPS procurement when sufficient funds are available. No provider, plan, domain, database, or backup subscription is authorized at this time. Reaffirmed on 2026-11-11 with no change.

**Budget target:** approximately **IDR 100,000/month all-in**, covering VPS, database, domain, backup, and supporting services. Every recurring line must fit inside that ceiling, not just the VPS headline price. At an approximate exchange rate of IDR 16,000-16,500 per USD, that is about **USD 6.00-6.25/month** before tax and payment fees. For scale, the researched managed platforms are far above that ceiling: Render about $33-$54/month, Railway about $32-$42/month, and Vercel Pro about $45/month including Supabase Pro. Those figures are not directly comparable to a VPS, because they include a managed runtime, TLS, deploys, and logs, but none of them fits the stated budget without the owner raising it.

**Candidate only - Helipod VPS S Jakarta (owner-supplied checkout information, not verified):**

| Item | Owner-supplied detail | Verification status |
|---|---|---|
| Price | IDR 79,900/month | Advertised checkout price; not independently verified |
| vCPU | 2 | Owner-supplied |
| RAM | 2 GB | Owner-supplied |
| Storage | 40 GB | Owner-supplied; disk type and IOPS unknown |
| Bandwidth | 500 GB | Owner-supplied; overage and throttling policy unverified |
| Port | 20 Mbps | Owner-supplied; shared or guaranteed not stated |
| Region | Jakarta | Owner-supplied |
| Managed PostgreSQL | Included bonus | Limits, storage, backups, and renewal price unverified |
| VPS backup | One month included | Renewal price and restore process unverified |
| Email API | Included bonus | Quota, sender domain, and deliverability terms unverified |
| Domain | One year included | TLD, registrar, renewal price, and transfer rights unverified |

**Unverified terms that must be confirmed before any purchase consideration:**

- **Managed PostgreSQL.** Storage limit, connection limit, backup frequency and retention, region, upgrade path, and the renewal price after any promotional term are all unknown. Whether it is a managed service or a shared instance on the same node is unknown.
- **VPS backup.** "One month included" is unverified. Whether backups continue after month one, at what price, and whether restore is self-service or support-mediated is unknown. A backup that stops silently is worse than no backup promise.
- **IPv4.** Whether a dedicated IPv4 address is included, and whether it is a separate recurring charge, is unknown. IPv4 exhaustion means some providers bill for it separately.
- **Domain.** TLD, registrar, who holds the registration (the owner or the provider), renewal price, and transfer rights are unknown. A "free one-year domain" often renews at full price and is registered to the provider.
- **Bandwidth and port.** The overage policy above 500 GB, the throttling behavior, and whether the 20 Mbps port is guaranteed or shared/burstable are unknown. A shared 20 Mbps port under contention is not a stable production baseline.
- **Renewal pricing.** The IDR 79,900 may be a first-term or promotional rate. The renewal rate is the number that determines whether this fits the budget long term.
- **Taxes and payment fees.** Whether the advertised price includes VAT/PPN, and any payment processing or currency conversion fee, is unknown.
- **SLA, support, refund, and acceptable-use terms.** Support response time, uptime commitment, refund policy, and whether hosting a commercial script-distribution platform is permitted are unknown.
- **Email API.** Sending quota, verified sender domain, deliverability terms, and spam-handling policy are unknown. This matters if transactional email is ever needed for account notifications.

**Why it is only a candidate:**

- The advertised IDR 79,900 leaves only **IDR 20,100/month** for domain renewal, PostgreSQL renewal, backup renewal, email, taxes, and payment fees. That is unlikely to cover every recurring line if any bonus is promotional or metered.
- Managed PostgreSQL is a checkout bonus, not a verified service. Self-hosting PostgreSQL on the same 2 GB VPS would compete with the Next.js app for memory and is not recommended for production. On a 2 GB VPS, a Next.js server plus PostgreSQL plus a reverse proxy is a tight memory budget that will be the first thing to fail under load.
- The price may be a first-term or promotional rate. Renewal pricing is unknown.
- IPv4 allocation, backup retention, snapshot and restore, SLA, support response, acceptable-use terms, and refund policy are unknown.
- A VPS is not a PaaS. It adds OS patching, a reverse proxy, TLS renewal, process supervision, firewall rules, deploy automation, and backup verification. That burden is acceptable only if the owner trades it for the lower price.

**Portability of this plan under a VPS:** D1 remains portable to a VPS because the architecture is a standard Next.js Node.js application, not a platform-specific runtime. The single catch-all API Route Handler, the Node.js runtime requirement, the `pg` plus Kysely data layer, and the Supavisor pooled connection all work on any host that runs Node.js. What changes is operational, not architectural: process supervision, TLS termination, deploy automation, and log shipping become the owner's responsibility instead of the platform's. The API function-count constraint in `BACKEND.md` Section 3.1 is a Vercel-specific post-build check; on a VPS it is satisfied trivially by the fact that there is one Node.js process.

**Effect on the plan:**

- D1a does **not** block architecture, module design, schema design, threat modeling, or security review. Those can continue.
- D1a **does** block hosting procurement, account registration, domain purchase, database subscription, deployment, and production launch.
- D1 remains unchanged: one Next.js App Router app, one catch-all API Route Handler, Node.js runtime, one deployment, no separate backend.
- Render, Railway, Cloudflare Workers, Vercel, and Helipod are research candidates only. None is approved.

**Owner approval required:** Yes. D1a remains **UNAPPROVED — DEFERRED**. No account may be registered, no VPS or domain purchased, no subscription changed, and no deployment started. Procurement resumes only when the owner confirms funds are available and approves a provider, plan, and verified all-in monthly cost within the budget. D1 is unchanged and remains FINAL — OWNER APPROVED.

### 5.3 D2 - Session ownership (REVIEWED, UNAPPROVED)

**Status:** Reviewed on 2026-11-11. **Not approved.** The recommendation below replaces the earlier unargued default. This review does not approve D2.

**Question:** Should the platform use (A) custom Discord OAuth with server-side opaque sessions, or (B) Supabase Auth with the Discord provider?

`BACKEND.md` Section 4.4 presents both as valid and recommends custom "if the platform requires full control over session lifetime, revocation, and audit." This review tests whether that condition genuinely holds, rather than assuming it.

#### 5.3.1 What both options share

Both options perform the same Discord OAuth authorization code flow. Discord's authorize and token endpoints, the `state` parameter, the `identify` scope, and the `/users/@me` call are identical. Neither option stores a Discord password; neither uses the Discord token as a session. `users.discord_id` remains the identity anchor in both. The Supabase Discord provider is a wrapper around this same flow, not a different identity source.

Two details are shared but easy to miss. Discord advertises `response_types_supported: ["code"]` only, so the authorization code grant is the only relevant flow. Discord also returns an `iss=https://discord.com` parameter on every authorization response per RFC 9207, advertised as `authorization_response_iss_parameter_supported: true`; validating it against the expected issuer is a cheap guard against provider mix-up and applies equally to either option. Neither detail distinguishes A from B.

The differences are therefore entirely about **who owns the session record and the token lifecycle**, and that is where the Section 9.11 requirements decide the question.

#### 5.3.2 Comparison table

| Criterion | A. Custom Discord OAuth | B. Supabase Auth (Discord provider) |
|---|---|---|
| Discord OAuth integration | One adapter in `src/providers/discord/`. Full control of scopes, redirect URI, prompt, and error mapping. | Supabase performs the exchange; scope and redirect configuration live in the Supabase dashboard and cannot be mapped to internal error codes as precisely. |
| Immutable Discord user ID | `users.discord_id` upserted from `/users/@me`. Identity anchor is directly and visibly under our control. | Available on `identities.provider_id` and in the JWT `sub`. Requires a mapping step to reach `users.discord_id`; a **second** `auth.users` table and an `auth.uid` exist alongside our `users.id`. |
| OAuth state | Our `state`, our storage, single-use, bound to a short-lived cookie or `oauth_states` row. Our own comparison determines the outcome, so our own negative tests cover it. | Supabase's auth library generates and validates state inside the provider flow. Correct in itself, but the visible surface is smaller: our negative tests assert Supabase's behavior rather than our code, and a state failure surfaces as a generic SDK error unless we map it. |
| PKCE | We would implement `code_challenge`/`code_verifier` ourselves if adopted. Discord advertises S256 support (verified in its authorization server metadata, see §5.3.2.1), so the protocol side is available; the implementation and its failure modes would be ours. | The SDK may use PKCE depending on its flow configuration, but that is a Supabase client setting and is **not** evidence about what Discord supports or enforces. PKCE configuration in Option B was not verified in this review. |
| Session security | Opaque 256-bit token, only `sha256` stored, constant-time compare. Exactly matches Section 9.11. | JWT access token (default 1 hour) plus refresh token. A stolen JWT is valid until expiry; the app cannot revoke another party's access token. |
| Cookie security | Attributes are set explicitly by our code, so `HttpOnly`, `Secure`, `SameSite`, scoped `Path`, and a bounded `Max-Age` are deliberate choices that tests can assert. Because nothing in the browser needs to read the session, `HttpOnly` can hold the entire credential. | Attributes are **configuration, not a fixed SDK default**, and what is usable depends on the application's architecture. `@supabase/ssr` writes a cookie named `sb-<project_ref>-auth-token` through a `getAll`/`setAll` adapter whose cookie options the application supplies, and the value may be split into numbered chunk cookies. If a browser-side client must read the session, `HttpOnly` is constrained; if all auth happens server-side inside the catch-all handler, `HttpOnly` is available. See §5.3.2.2. |
| Session revocation | Delete the row (or set `revoked_at`). Because every request performs a database lookup, the lookup itself observes the revoked state. Effective on the next request, no client cooperation. Matches Section 9.11 directly. | **The hard blocker.** Revoking refresh tokens does not invalidate an outstanding access token for up to its TTL. Closing that gap requires a per-request check that asks the server whether the session is still live — see the JWT discussion below. Option B converges on Option A once that check is added. |
| Logout | Delete one row, clear cookie. | Sign-out clears the local session and revokes the refresh token; a previously issued access token is not revoked by that call and remains usable until it expires, unless a status check rejects it. |
| Logout-all | `UPDATE sessions SET revoked_at = now() WHERE user_id = $1`. One statement, immediate and auditable. | A global sign-out invalidates the user's refresh tokens. Its exact semantics, and whether it needs elevated privileges, were **not verified in this review** and should be confirmed in Supabase's session documentation before relying on it. Either way it does not bound an already-issued access token, and it does not touch `keys.owner_discord_id` or key sessions, so account-level and key-level revocation remain two different systems. |
| Role and permission resolution | `user_roles` in our schema, reloaded from the database on every privileged request. One authority, shared by session and key identity. | `user_roles` would have to be either mirrored into `app_metadata` (requires an Admin API write on every role change, a second source of truth) or reloaded from `public.user_roles` anyway. The JWT's `app_metadata` claim would also be attacker-relevant only if a signing key leaked, but mirroring adds a sync path that can silently drift. |
| CSRF protection | SameSite cookie plus a CSRF token or double-submit check on cookie-authenticated mutations, per Section 11. | Equivalent work, plus a second token that the SDK's auto-refresh path must also honor. The refresh endpoint itself becomes a CSRF-relevant target. |
| Expiration and rotation | 7 day absolute plus an idle window and rotation on privilege change. Directly configurable constants. | Configurable via Supabase settings, but rotation is intertwined with refresh-token reuse detection and the SDK refresh loop, so the effective policy is less obvious to reason about and harder to assert in tests. |
| Database schema implication | Adds the `sessions` table already defined in `BACKEND.md` Section 8. Nothing else changes. | Adds the `auth` schema tables Supabase manages, plus an `auth_id` link column on `users`, and either an `app_metadata` role mirror or a per-request `user_roles` read. |
| Compatibility with D1 (one catch-all API Route Handler, Node.js runtime) | **Direct.** The handler reads a cookie, hashes it, looks up the row, and updates `last_seen_at`. Authorization is resolved in exactly one place. | **Architecturally friction-heavy, though not a literal D1 breach.** The documented Next.js SSR pattern uses a proxy/middleware layer to refresh tokens because Server Components cannot write cookies. D1 forbids **database access** in Next.js middleware, not middleware itself, and Supabase's refresh path calls the Auth server over HTTP rather than the database, so this does not automatically violate D1. The real friction is that it introduces a second, framework-level session-resolution and cookie-write path alongside the single API pipeline that D1 makes the only place authorization decisions happen. |
| Operational complexity | Moderate: we own state handling, rotation, revocation, and their tests. All of it is code we can read. | Lower at first for the happy path; **higher** once immediate revocation, logout-all semantics, and role mirroring are added, because they are either outside the SDK's model or require the Admin API. |
| Security risk profile | Risk is concentrated in our own code — mitigated by explicit negative tests in Phase 2 and Phase 9. | Risk is transferred to a dependency and to Supabase's session model, and the Section 9.11 requirements are **not** satisfied by default. |
| Implementation cost | Estimated at roughly one to two weeks of Phase 2 effort: provider adapter, `sessions` repository, cookie helpers, CSRF, guards, and tests. This is an estimate, not a measured figure. | Faster to a working login, then an open-ended tail of reconciliation work: a revocation status check, role sync, cookie hardening, logout-all bridging, and test coverage. The tail is the reason this row is a wash rather than a saving. |
| Maintenance cost | Constant and ours: token rotation policy, cookie attributes, and expiry constants. | We inherit Supabase Auth's breaking changes, SDK churn, and cookie-format changes, while still maintaining the reconciliation layer. |
| Vendor coupling | Supabase is needed for Postgres and Storage; auth stays ours. Replacing Supabase as the database vendor does not touch session logic. | Auth is additionally coupled to Supabase; migrating auth out later means migrating session and identity storage. |

##### 5.3.2.1 PKCE: what was verified, and what was not

PKCE (RFC 7636) binds the authorization code to the client that requested it by sending a `code_challenge` on the authorization request and the matching `code_verifier` on the token request.

**Verified from Discord's official documentation:**

- Discord's authorization-server metadata at `https://discord.com/.well-known/oauth-authorization-server` advertises `"code_challenge_methods_supported": ["S256"]`. The `S256` method is therefore advertised as available.
- The metadata also advertises `token_endpoint_auth_methods_supported` including `client_secret_basic`, `client_secret_post`, and `none`, and `response_types_supported` of `["code"]`.
- Discord's docs recommend using the authorization code grant with PKCE for production apps in the implicit-grant section, and explicitly warn that the implicit grant is unsuitable outside prototypes.

**Not verified, and not to be assumed:**

- Discord's main OAuth2 reference does not document `code_challenge` or `code_verifier` parameters in its authorization-code-grant section. It documents `client_id`, `scope`, `redirect_uri`, `state`, `prompt`, and `integration_type` on the authorization URL, and `grant_type`, `code`, and `redirect_uri` on the token exchange.
- Whether Discord **enforces** PKCE at the token endpoint, or merely accepts and ignores it, was not verified. Metadata advertising a capability is not the same as the server requiring or honoring it.
- This review did not send an authorization request to Discord, did not run an OAuth flow, and did not test any client behavior against the live service. No network flow was executed.

**The claim this review rejects:** that PKCE is supported by Discord OAuth *because* Supabase uses PKCE in its SSR integration. Supabase performing PKCE on its own client libraries says nothing about Discord's implementation. That inference is exactly the reasoning to avoid. The evidence for Discord's side is the metadata above, and it establishes advertised support only, not enforced behavior.

**Consequence for Q7:** whether PKCE should be adopted is a Phase 2 decision, and it should be confirmed against a live Discord application in a sandbox before it is treated as mandatory. The recommendation to include it stands on the protocol level, but the "mandatory" label is not yet earned.

##### 5.3.2.2 Supabase cookies: configuration-dependent, not a fixed default

A claim in the earlier draft — that `@supabase/ssr` "defaults to non-HttpOnly" — was not established by the sources checked and has been removed.

**What the Supabase documentation actually establishes:**

- `@supabase/ssr` stores the session in cookies. The default cookie name is `sb-<project_ref>-auth-token`, and the value can be split across numbered chunk cookies when it is large.
- Cookie reading and writing are **not hard-coded**. The application supplies `getAll` and `setAll` callbacks, and on write receives `{ name, value, options }`, where `options` is the cookie options object. Whether `HttpOnly`, `Secure`, `SameSite`, `Path`, and `Max-Age` are set to particular values is therefore determined by the application's own cookie configuration, not by a fixed SDK constant.
- The documented Next.js SSR pattern writes cookies from a proxy/middleware layer **and** from Server Components, and pairs `setAll` with `Cache-Control`, `Expires`, and `Pragma` headers to stop a CDN caching one user's `Set-Cookie`.
- Supabase warns that a refresh token can generally be used only once, with narrow reuse windows; a refresh from two places can revoke the whole session and sign users out unpredictably.

**Why this matters for the comparison:** the real constraint is not a fixed `HttpOnly` default. It is the **architecture**. If a browser-side client must read the session — for example to use Realtime, let the browser call the Data API directly, or refresh tokens in the client — then `HttpOnly` is structurally constrained, because the browser needs to read the credential. If every auth operation happens server-side inside the catch-all API handler, `HttpOnly` remains available. The honest statement is that Option A enables `HttpOnly` unconditionally, because nothing in the browser needs the session value, while Option B makes it depend on which Supabase features the application chooses to use on the client. That is a real but conditional difference, not an absolute one.

**Not verified:** the exact default `options` object that `@supabase/ssr` passes to `setAll`, and the current chunk-splitting threshold. Both should be read from the package source at implementation time if Option B is selected.

##### 5.3.2.3 JWT verification versus session status checking

These are two different operations, and conflating them is the most common mistake in this comparison.

- **Local JWT verification.** The server checks the token's signature against a cached public key (JWKS). Supabase documents this as the behavior of `getClaims` on projects with asymmetric signing keys. It is fast because it needs no network round trip. Its crucial property is that it answers only "was this token issued by the auth server and is it well formed and unexpired?" It says **nothing** about whether the session still exists, whether the user was banned, or whether the role changed one second ago.
- **Session status checking.** The server asks an authority — the database, or the Auth server — whether the session is still valid right now. This is what catches revocation, bans, and role changes. It costs a lookup on every protected request. Supabase's `getUser` does this by making a network call to the Auth instance.

This distinction is what drives the revocation row in the comparison:

1. A signed access token is self-validating. Once issued, local verification accepts it until `exp` regardless of what has happened to the session since. A ban, a logout, or a permission removal does not reach the token.
2. Revoking refresh tokens stops **future** token issuance. It does not reach an access token that is already in a client's hands.
3. Supabase's own documentation therefore treats `getSession` as unsafe for authorization decisions on the server, because it reads the cookie without revalidating, and directs callers to `getClaims` for verification and `getUser` for a fresh server-confirmed record. `getUser` is the session status check, and it is a network call per request.
4. Section 9.11 requires revocation to be server-side and effective on the next request with no grace period, and requires `logout-all` to revoke every session. That is a session status check on every protected request, which means Option B must perform a per-request server-side check anyway. At that point Option B has the same per-request lookup cost as Option A, plus the JWT layer and the identity mapping on top.
5. The realistic middle ground for Option B is a short access-token TTL plus a bounded-grace design, where the window is a deliberate owner choice rather than a property of the system. That is why Q2 asks the owner whether immediate revocation is a hard requirement. If it is hard, Option B does not satisfy it as-is. The row values in the threat table that depend on this reading carry the *by-design* hedge: they describe the out-of-the-box model, not a hardened variant.

##### 5.3.2.4 Four controls that must not be conflated

Earlier drafts of this review used "state", "PKCE", "cookie security", and "revocation" loosely enough that they could read as substitutes for one another. They are four independent controls. A deployment can have any one of them without the other three, and passing one says nothing about the others.

| Control | What it actually proves | What it does not prove | Where each option stands |
|---|---|---|---|
| **OAuth `state` validation** | The callback corresponds to an authorization request this browser started, and is not a cross-site forgery or a replayed callback. | Nothing about the session after login. Nothing about revocation. | Both options implement it. A: our own code and tests. B: the library's flow; our tests assert its behavior. |
| **PKCE support and enforcement** | The client redeeming the authorization code is the one that started the flow, so an intercepted code cannot be redeemed elsewhere. | Nothing about `state`, cookies, or sessions. | Discord advertises `S256` in its metadata; enforcement is unconfirmed (§5.3.2.1). A would implement it; B's configuration was not verified. |
| **Session cookie security** (`HttpOnly`, `Secure`, `SameSite`, `Path`, `Max-Age`) | How the session credential travels and how hard it is to steal by script, network, or cross-site request. | Whether the session is still valid server-side. A stolen-but-valid cookie still works until it is revoked. | A sets attributes unconditionally. B's attributes are configuration and depend on architecture (§5.3.2.2). |
| **Server-side session revocation** | The session is currently active, checked on the server, after the other three controls have already passed. | Nothing about `state`, PKCE, or cookie flags. | A: a per-request lookup in `sessions`. B: requires an added status check, because local JWT verification is not a status check (§5.3.2.3). |

**Why the separation decides the comparison:** Section 9.11's requirement — revocation effective on the next request, plus `logout-all` — lands on the fourth row only. `state` validation, PKCE, and cookie hardening are all necessary and all desirable, and every one of them could be fully satisfied while a revoked session still worked for another hour. That is the trap in evaluating Option B: its `state` handling and its possible PKCE use look like session security, but neither one revokes anything.

**Consequence for the plan:** the Phase 2 test list must cover the four controls separately, including a negative test for each. A passing `state` test is not evidence of revocation, and a hardened cookie is not evidence of revocation either.

#### 5.3.3 Threat analysis

**These ratings are analyst judgments, not measurements.** Low, Medium, and High are ordinal labels assigned by this review after reading the cited documentation. They are not CVSS scores, not the output of a penetration test, and not derived from any traffic, telemetry, or exploit attempt. No system was tested. A different reviewer could reasonably set an adjacent label. They are useful for ranking the options against each other and should not be quoted as measured risk.

Values are stated relative to the other option, not absolutely. Where a rating depends on configuration rather than design, the analysis says so.

| Threat | A. Custom | B. Supabase Auth | Analysis |
|---|---|---|---|
| Access token replay after logout | Low | **High by design; Medium if hardened** | Out of the box, a signed access token remains acceptable until `exp` after sign-out, because local verification does not consult session state. This is the Section 9.11 gap. Adding a per-request status check closes it, but that is the `sessions` table again. The rating is the judgment that the default posture is the wrong side of a stated requirement. |
| Session token theft | Medium | Medium | Both depend on cookie theft resistance. A can be `HttpOnly` unconditionally, because no browser code needs the session, and stores only a hash so a database read yields no usable credential. B's `HttpOnly` posture depends on whether a browser-side client must read the session, per §5.3.2.2. The rating is equal because the difference is architectural choice rather than inherent safety. |
| Session fixation | Low | Low | A creates a fresh session after callback and rotates on privilege change. B's auth helpers also rotate on callback. Both are testable. |
| CSRF on state-changing routes | Low | Medium | Both need an explicit token. B adds the refresh path as an additional CSRF-relevant surface, and if a browser-side client reads the session then an XSS foothold yields a usable credential. The rating assumes the browser-read configuration; a server-only configuration would narrow the gap. |
| Role escalation through stale claims | Low | Medium | A reloads `user_roles` per privileged request, so a revoked role takes effect immediately. B either trusts an `app_metadata` claim (stale until token refresh and dependent on a correct Admin API sync) or needs the same per-request read, negating its convenience. |
| Identity confusion between `auth.users.id` and `users.id` | N/A | Medium | Two user identifiers exist. Every ownership check in keys, bans, reversals, and reactivations uses `owner_discord_id` and `users.id`. A mapping mistake here is a cross-account access class of bug. Option A has one user table and one identifier. |
| Revocation sweep for bans | Low | Medium | A ban revokes `key_sessions` and the account session through one owned mechanism. B's account session lives in Supabase, so account-level revocation for a banned user requires an Admin API call in addition to the key-session revocation. |
| Third-party outage surface | Medium | Medium | Both depend on Discord. B adds Supabase Auth availability to the login path, on top of the Postgres and Storage dependency that already exists. |
| Supply-chain risk | Low | Medium | A's auth code is small and first-party. B adds an SDK whose cookie names, chunking, and refresh behavior are part of the security boundary and which we do not control. |
| Secret exposure | Low | Low | A holds the Discord client secret and a session hash secret server-side. B holds the Discord client secret in Supabase and a service-role key for Admin API revocation calls — one more powerful credential in the environment. |

**The decisive finding:** Section 9.11 requires revocation to be server-side and effective on the next request, with no client cooperation and no grace period, and requires `logout-all` to revoke every session. In a JWT model, local signature verification is silent about session state, and revoking refresh tokens does not reach an already-issued access token. Closing that gap requires a per-request session status check. Adding that check is, in substance, the `sessions` table. Option B therefore does not remove the work — it adds a layer on top of it. This finding rests on documented behavior; the ratings attached to it are judgments per §5.3.3.

#### 5.3.4 Recommendation

**Recommend Option A — custom Discord OAuth with a server-side `sessions` table.** This is a recommendation for owner approval, not an approval.

Reasons, in order of weight:

1. **Option B cannot meet Section 9.11 as written.** Immediate revocation and `logout-all` require a server-side check on every request. That check is the `sessions` table, which is Option A.
2. **One identity authority.** Keys, bans, reversals, reactivations, audit rows, and subscriptions all key off `users.discord_id` and `users.id`. Option B introduces `auth.users` and `auth.uid` as a parallel identity, and a banning workflow that must revoke an account session in another system is a reconciliation hazard in the highest-risk area of the project.
3. **Single-pipeline alignment.** D1 makes the API router the only place authorization decisions happen. The documented Supabase SSR pattern resolves sessions in a framework-level proxy as well, which does not violate D1's database-access rule but does place session handling in two layers instead of one.
4. **Cookie guarantees.** Under Option A, `HttpOnly`, `Secure`, `SameSite`, scoping, and `Max-Age` are unconditional choices we set and tests can assert. Under Option B they depend on the application's architecture, which is a weaker guarantee rather than an absent one.
5. **Cost of being wrong.** Option A's downside is code we own and test. Option B's downside is a requirement we cannot meet without rebuilding Option A underneath it.

**What would change the recommendation:** If the owner decides that a bounded revocation window is acceptable rather than immediate revocation — for example tolerating up to the access-token TTL — and accepts the dual-identity mapping and architecture-dependent cookie posture, then Option B becomes defensible as a time-to-market trade-off. That is an owner risk decision, not a technical recommendation.

**Explicitly not decided by this review:** whether PKCE is adopted, the final absolute and idle session lifetimes, and the multi-device session policy. PKCE is recommended at the protocol level, but per §5.3.2.1 its support is established only at the metadata level and should be confirmed against a live Discord application before anyone calls it mandatory. These points are listed in Section 5.3.7.

#### 5.3.5 Exact schema implications for Phase 1

**Conditional, not optional.** `oauth_states` is required only if D2 resolves to Option A. It appears here because Section 5.3 recommends Option A. If the owner selects Option B, the table is not created; while D2 is undecided, it must not be assumed. Phase 1 may prepare the table for Option A without treating D2 as approved, provided the conditional status is recorded in the migration itself.

Option A introduces **one new support table**, `oauth_states`, alongside the `sessions` table already specified. `BACKEND.md` Section 8.2 defines:

**`sessions`** — `id` uuid PK; `user_id` uuid FK `users(id)` on delete cascade; `token_hash` text unique not null; `user_agent` text; `ip` text; `expires_at` timestamptz not null; `revoked_at` timestamptz; `created_at` timestamptz. Unique on `token_hash`; indexes on `user_id` and `expires_at`.

Required additions for the Section 9.11 idle window and the rotation rule. These are columns, not a new table, and they belong in the Phase 1 migration:

| Column | Type | Purpose | Source |
|---|---|---|---|
| `last_seen_at` | `timestamptz` not null | Idle-window enforcement. Section 9.11 requires an idle window for the account session, mirroring `key_sessions.last_seen_at`. | Section 9.11 "Expiration," applied to the account session |
| `rotated_at` | `timestamptz` nullable | Records the last rotation, so the sliding regeneration interval can be measured server-side. | Section 4.3 "Renewal" |
| `absolute_expires_at` | `timestamptz` nullable | Optional. Only needed if the owner wants a maximum lifetime that is longer than the current `expires_at` while the sliding window extends `expires_at`. | Section 4.3 "absolute lifetime plus idle timeout" |

Also required in Phase 1:

- **`oauth_states`** — a new table, not merely an extra column. `BACKEND.md` Section 4.2 names "a `sessions`/`oauth_states` row" as an option but does not define `oauth_states` as a table in Section 8, so Phase 1 specifies it. Columns: `state_hash` (store a hash, not the raw state), `code_verifier` if PKCE is adopted, `redirect_path`, `created_at`, `expires_at`, `consumed_at`. Index on `expires_at` for cleanup.
- A cleanup path for expired `oauth_states` and expired or revoked `sessions` rows, run by the scheduled job planned in Phase 1. Row growth is otherwise unbounded.

**Precise accounting for Option A:** one new support table (`oauth_states`), three added columns on the existing `sessions` table, and one new cleanup job. No new domain table.

No admin-API reconciliation table, no `auth_id` column, and no role-mirror table is required. `user_roles` stays the single role authority.

**If Option B were selected instead:** Phase 1 would additionally need an `auth.users` to `users` mapping (an `auth_id uuid unique` column on `users`), a decision on whether `user_roles` is mirrored into `app_metadata`, and a revocation-check table for the access-token gap — which is the `sessions` table again. Phase 1 would also carry the RLS interaction risk described in Section 5.3.6.

#### 5.3.6 Implementation risks

Severity and likelihood in this table are **analyst estimates** on the same ordinal scale as §5.3.3, not measurements or the output of any assessment tool.

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| Session token handling implemented subtly wrong (rotation, comparison, expiry) | High | Medium | Constant-time compare, hash-only storage, an injectable clock, and the Phase 2 negative suite: missing state, mismatched state, replayed state, expired state, expired session, revoked session, logout-all. |
| `sessions` table grows unbounded | Low | High | Indexed `expires_at`, a scheduled cleanup job, and a retention window under D7. |
| Cookie lost or dropped across environments | Medium | Medium | Exact redirect-URI allowlist per environment, `Secure` only on HTTPS origins, and a documented local-development exception that is never enabled in production. |
| Discord redirect URI mismatch between preview, staging, and production | Medium | Medium | Register a redirect URI per environment; CI check that the configured URI matches the registered one. |
| Session fixation or fixation-like reuse | High | Low | New session row created after callback; the pre-login cookie value is never promoted to an authenticated session. |
| Clock skew between the app and the database | Medium | Low | Single time authority for expiry checks; the injectable clock in tests; no client-supplied timestamps. |
| PKCE adds a failure mode if `code_verifier` is not persisted reliably | Low | Medium | Store the verifier in the `oauth_states` row, single-use, with an expiry; treat a missing verifier as `invalid_state`. |
| CSRF coverage missed on a new mutation route | High | Medium | CSRF is a middleware step in the single API pipeline, not a per-route opt-in; the route table declares access level, and the pipeline applies CSRF to every cookie-authenticated mutation by default. |
| Option B only: session cookie shape and readability depend on architecture | Medium | Medium | If Option B is chosen, decide explicitly whether a browser-side client needs to read the session. If not, keep every auth operation server-side so `HttpOnly` stays available; if yes, treat the cookie as browser-readable and compensate with CSP, short TTL, and rotation. Confirm the actual cookie `options` and the chunk-splitting threshold from the package source. |
| Option B only: `auth.users.id` versus `users.id` identity confusion | High | Medium | If Option B is chosen, every ownership check must be reviewed against the mapping, and a mapping test belongs in the security suite. |
| Option B only: RLS interaction with the SDK session | Medium | Medium | The service role already bypasses RLS by design. The SDK's use of the anon key with a user JWT must not become a second, differently authorized data path into `users`, `keys`, or `user_roles`. Keep application data access on the service role inside the API function, as D1 already requires. |

#### 5.3.7 Unresolved questions requiring owner input

| ID | Question | Why it matters | Recommended default | Blocks |
|---|---|---|---|---|
| Q1 | Approve D2 as Option A (custom Discord OAuth with `sessions`)? | Determines Phase 2 entirely: provider adapter, session repository, cookie handling, and the test list. | **Approve Option A.** | Phase 2 |
| Q2 | Is immediate session revocation on the next request a hard requirement, or is a bounded window acceptable? | If a window is acceptable, Option B becomes cheaper. If it is hard, Option B cannot be selected without adding `sessions` anyway. | Hard requirement. Section 9.11 states it. | Phase 2 |
| Q3 | Multi-device policy for the account session: allow unlimited concurrent sessions, cap the count, or allow one active session per user? | Affects `logout-all` semantics, the `sessions` schema, and the ban-revocation sweep. `BACKEND.md` does not state an account-level device limit; it states one **active device** only for keys, which is a key rule, not an account rule. | Allow multiple sessions, expose "sessions" in the dashboard, and enforce one active key device per key. | Phase 2 |
| Q4 | Is the Discord `access_token` persisted after `/users/@me`, or discarded immediately? | A persisted Discord token is a second credential with Discord-side scope. Discarding it means the account session is the only credential, which matches Section 9.11. | Discard immediately after the profile fetch. Never store it. | Phase 2 |
| Q5 | Should the `email` scope be requested? | `users.email` is nullable and only populated if the scope is granted. Requesting it increases the consent screen and the PII footprint. | `identify` only. No `email` scope unless a concrete feature needs it. | Phase 1 schema, Phase 2 |
| Q6 | Final absolute and idle lifetimes for the account session. | Section 9.11 states 7 days absolute and Section 4.3 permits 7-30 days; no idle window is stated for the account session. | 7 days absolute, 24 hours idle, rotation after 24 hours of use. | Phase 2 |
| Q7 | Is PKCE adopted, and is it mandatory or recommended? | Adds a `code_verifier` to the flow and one more failure mode; adds defense against authorization-code interception. Discord advertises `S256` in its metadata but does not document enforcement, and its prose docs do not enumerate the parameters (§5.3.2.1). | Adopt PKCE, but label it required only after a sandbox run confirms Discord honors `code_verifier`. Until then it is defense in depth, not a hard gate. | Phase 2 |
| Q8 | Is a session visible to the user (device list with self-revoke)? | Section 9 does not define a session-management endpoint. It changes the endpoint list, not the schema. | Add `GET /api/auth/sessions` and `DELETE /api/auth/sessions/{id}` as owner-scoped, non-admin routes. | Phase 2 |
| Q9 | Do login and logout failures emit an audit row at `info` severity, or only at `warn` for anomalies? | Audit volume and signal-to-noise in `audit_logs`. | Audit every login, logout, and logout-all; log failed callbacks as warnings with a request ID and no PII. | Phase 2 |
| Q10 | Does the application need a browser-side Supabase client (Realtime, direct Data API calls, or client-side token refresh), or is all authentication server-side inside the catch-all handler? | **Conditional question — relevant only if Option B (Supabase Auth) is approved.** Under Option A it is moot, because no Supabase Auth client exists in the browser. If Option B is approved, this single decision determines whether `HttpOnly` remains available and whether its refresh path requires a proxy layer. It is the hinge for §5.3.2.2. | Server-only authentication. No browser-side Supabase client. | Phase 1 and Phase 2 **only if Option B is approved**. Under Option A it blocks nothing and is recorded as not applicable. |
| Q11 | Which of the four controls in §5.3.2.4 are treated as hard requirements: state validation, PKCE, cookie hardening, or immediate revocation? | The answer determines whether Option B is viable at all, or whether it must be rebuilt on a session table. | State validation and immediate revocation are hard; PKCE and cookie hardening are strong preferences. | Phase 2 |

These questions are additional to, and consistent with, the existing D2 and U2 entries. None of them is resolved by this review.

#### 5.3.8 Verification status and sources

**Verified from official documentation on 2026-11-11:**

- Discord's OAuth2 documentation: the authorization code grant parameters, the `state` parameter, the `iss` parameter, scopes, token exchange, refresh, and revocation. Discord's metadata advertises `code_challenge_methods_supported: ["S256"]`. Discords docs recommend the authorization code grant with PKCE for production apps in the implicit-grant section. Sources: `https://discord.com/developers/docs/topics/oauth2`, `https://discord.com/.well-known/oauth-authorization-server`.
- Supabase's Server-Side Auth with Next.js guide: the `@supabase/ssr` cookie model, the `sb-<project_ref>-auth-token` name, the application-supplied `getAll`/`setAll` adapter with `{ name, value, options }`, the chunked value behavior, the proxy/middleware refresh requirement, the CDN cache-header requirement, refresh-token reuse detection, and the `getClaims` / `getUser` / `getSession` distinction. Source: `https://supabase.com/docs/guides/auth/server-side/nextjs`.
- `BACKEND.md` Sections 2.4, 2.5, 4.1-4.5, 8.2, 9.1, and 9.11, as the project authority for the session requirements.

**Not verified, and not to be assumed:**

- Whether Discord **enforces** PKCE at its token endpoint, or accepts and ignores it. Only advertised support is established.
- Whether Option B actually uses PKCE in any given configuration. No `@supabase/auth-js` package source was read, and the earlier reference to a `flowType: "pkce"` setting was removed as unsourced.
- The exact default cookie `options` object and the chunk-splitting threshold in `@supabase/ssr`.
- The precise revocation and global-sign-out semantics of Option B, and whether the global form requires elevated privileges.
- Default access-token and refresh-token lifetimes on a current Supabase project.
- Any behavior of the live services. No OAuth flow was run, no request was sent to Discord or Supabase, and no system was tested.

**Method note:** this was a documentation review. Every severity, likelihood, and cost figure in §5.3.2 through §5.3.6 is an analyst estimate. Nothing in this section is a measurement, and nothing here should be quoted as verified test evidence.

**Recommendation standing:** Option A remains the recommendation and remains **UNAPPROVED**. Corrections in this revision narrowed two claims that were overstated — the PKCE reasoning and the cookie default — without changing the recommendation, because the revocation argument rests on documented behavior. Whether that recommendation survives is the owner's decision at Q1, Q2, and Q11.

### 5.4 D3 - Payment provider (REVIEWED, UNAPPROVED; two candidates pending eligibility)

**Status:** Reviewed 2026-11-11, then updated by owner decision on 2026-11-11. **D3 remains UNAPPROVED.** This section is a technical and operational review built from official provider documentation, plus the owner's recorded selection procedure in §5.4.9. It selects no provider, authorizes no merchant account, and authorizes no code. **Midtrans and Duitku are both candidates with eligibility pending; provider selection is pending written eligibility approval; the payment adapter is BLOCKED.** Phase 6 requires an affirmative owner decision and a written, product-specific approval from the selected provider.

The project context that constrains every option: the operating entity and target market are **Indonesia**, plans are priced in **IDR**, products are **monthly, 3-month, and 6-month** periods, and `BACKEND.md` §7.2 defines renewal as a *new payment that creates a new period*, not an automatic charge.

#### 5.4.1 Mandatory requirements extracted from BACKEND.md

| Requirement | Source | Consequence for provider selection |
|---|---|---|
| Provider-independent `PaymentVerifier`, one implementation per provider | §7.5 | No provider SDK may be imported outside `src/providers/payments/*` |
| Signed server callback is the only proof of payment | §7.5 | A browser redirect, `finish` page, or client state is never evidence |
| Verify signature, persist a `payment_events` row, then mark `paid` and grant | §7.5, §8.2, §9.7 | Requires raw-body access and a unique event key |
| Idempotency and replay protection | §7.5, §9.7 | Unique `(provider, provider_event_id)`; duplicates acknowledge without granting |
| Audit logging for payment events | §11 | `audit_logs` row per accepted or rejected event |
| Reconciliation job queries the provider for pending transactions | §7.5 | The provider must expose a status/query API, not only webhooks |
| Amount is computed server-side from `plans.price_minor` | §7.5, §8.2, §9.7 | Provider must accept an amount we choose per transaction |
| Store `provider`, `provider_txn_id`, `amount_minor`, `currency`, `status` | §8.2 | Provider transaction id must be stable and unique per provider |
| Plans by `duration_days`, code `monthly` / `3month` / `6month` | §7.2, §8.2 | One-time period payment is sufficient; auto-renewal is not required |
| Renewal creates a new period; stacking extends `expires_at` | §7.2 | No stored card credential or token vault is required |
| One webhook route `POST /api/webhooks/payments/{provider}` | §9.7 | Provider must be addressable by a single path segment |
| Provider secrets server-only | §7.5, §11 | No key, server key, or token may reach the client bundle |

**The decisive negative finding:** nothing in `BACKEND.md` requires native recurring billing, stored card tokens, or automatic charging. §7.2 explicitly models renewal as a fresh payment. Any provider capability beyond that is optional, and optional capability must not drive the choice.

#### 5.4.2 Provider comparison

| Capability | Midtrans | Xendit | Duitku | Stripe |
|---|---|---|---|---|
| Indonesian merchant onboarding | Yes, documented | Yes, documented, with an authorized-representative requirement | Yes, documented | No self-serve path: Indonesia is marked **Preview** and routes to contact-sales |
| Individual (non-PT) merchant accepted | Yes: KTP + NPWP | Restricted: individual applications only as XP sub-accounts | Yes: KTP + NPWP + bank proof, all in the same name | Not applicable |
| Indonesian payment methods | Bank transfer/VA, cards, GoPay, ShopeePay, QRIS, minimarket, cardless credit, e-banking | VA (BCA, BNI, BRI, BSI, Mandiri, Permata, CIMB, BNC, Muamalat, BSS), cards, OVO, DANA, LinkAja, ShopeePay, JeniusPay, AstraPay, QRIS, Alfamart, Indomaret, Kredivo, Indodana, Akulaku | VA (BCA, BNI, BRI, Mandiri, Permata, CIMB, Danamon, BSI, Artha Graha, Sahabat Sampoerna), cards, OVO, DANA, LinkAja, ShopeePay, QRIS, Indomaret, Alfamart, Pegadaian, POS, JeniusPay, Indodana, Atome | Not applicable in Indonesia |
| Native recurring/subscription | Yes: Subscription API, card token or GoPay tokenization, `interval_unit: month`, `max_interval: 12`, configurable retry schedule | Yes: requires a Merchant-Initiated-Transaction channel; retry and deactivation options | **No.** The Nov 2025 changelog removed `isSubscription` and `subscriptionDetail` from the inquiry request | Not applicable |
| Refund API | Yes, no additional refund fee, requires `settlement` status, only for supported channels | Yes, refund webhooks, **each refund charged a processing fee** | **Split by API surface, not a flat "no".** Direct API: no refund endpoint; the published FAQ states refunds are not provided and are handled by the merchant. **SNAP API: a Debit Payment Refund endpoint exists, but it is gated behind ASPI registration (~14 business days). Direct Credit Card: both `void` (pre-settlement) and `refund` (post-settlement) endpoints exist.** Activation, eligibility, and cost are unconfirmed | Not applicable |
| Dispute/chargeback handling | Card chargebacks documented | Card chargeback fee **USD 25**, local-method chargeback fee **USD 15** | Not documented in the material reviewed | Not applicable |
| Sandbox environment | Yes, separate credentials and a sandbox IP | Yes | Yes, `sandbox.duitku.com` | Not applicable |
| Status/query API for reconciliation | Yes (Status API) | Yes (payment request status) | Yes (Check Transaction) | Not applicable |
| Published webhook retry policy | Yes, status-code matrix | Yes, six retries with backoff table | Yes, five attempts then email, plus dashboard resend | Not applicable |
| Published webhook IP allowlist | Yes, production and sandbox ranges | Not published in the pages reviewed | **Split by API product.** SNAP API publishes production and sandbox callback IP addresses. No equivalent published list was found for the standard Direct API callback | Not applicable |
| Fixed or minimum monthly fee | **None** | **USD 50 monthly minimum** | **None** | Not applicable |

#### 5.4.3 Official sources

Checked on 2026-11-11. Every row in §5.4.2 and §5.4.4 traces to one of these.

**Midtrans**

- Webhooks and redirect URLs: `https://docs.midtrans.com/docs/https-notification-webhooks`
- Notification best practice and status checks: `https://docs.midtrans.com/reference/best-practices-to-handle-notification`
- Notification retry matrix: same page as above
- Notification failure and IP allowlist: `https://docs.midtrans.com/docs/why-did-i-not-receive-any-http-notification-from-midtrans-system`
- Account legal documents: `https://docs.midtrans.com/docs/what-are-the-legal-documents-required-for-midtrans-account-registration`
- Fee structure and VAT: `https://docs.midtrans.com/docs/how-much-does-midtrans-charge-for-its-payment-service`
- QRIS MDR: `https://docs.midtrans.com/docs/what-is-the-applicable-transaction-fee-for-qris`
- Refund fees: `https://docs.midtrans.com/docs/will-i-be-charged-for-chargebacks-or-refunds`
- Recurring and tokenization: `https://docs.midtrans.com/docs/one-click-two-clicks-and-recurring-transaction`
- Subscription API: `https://docs.midtrans.com/reference/create-subscription`
- Payout and withdrawal timing: `https://docs.midtrans.com/docs/how-can-i-have-my-money-in-my-account-payout`
- Transaction minimums and maximums: `https://docs.midtrans.com/docs/is-there-a-minimum-and-maximum-transaction-value-that-i-can-charge-with-midtrans`
- Prohibited business categories: `https://docs.midtrans.com/docs/can-all-types-of-businesses-accept-payments-through-midtrans`
- Published price list: `https://midtrans.com/pricing`

**Xendit**

- Handling webhooks, deduplication, `x-callback-token`: `https://docs.xendit.co/docs/handling-webhooks`
- Webhook event catalogue: `https://docs.xendit.co/docs/payments-api-webhooks`
- Retry and manual resend: `https://docs.xendit.co/apidocs/webhook-behavior`
- HMAC callback headers: `https://docs.xendit.co/apidocs/payment-status-callback-webhook`
- Fees and deductions: `https://docs.xendit.co/docs/transaction-fees`
- Pricing policy, minimum and chargeback fees: `https://help.xendit.co/hc/en-us/articles/59516240127129-Xendit-Pricing-Policy`
- Settlement timing: `https://docs.xendit.co/docs/settlements-overview`
- Subscriptions: `https://docs.xendit.co/docs/how-subscriptions-work`
- Verification and authorized representative: `https://docs.xendit.co/docs/verifying-your-account`
- Indonesia documents and individual restriction: `https://docs.xendit.co/docs/indonesia-business-documents`

**Duitku**

- Price list, refund policy, withdrawal timing, PPn statement: `https://www.duitku.com/harga`
- FAQ, refund-by-channel statements, disbursement conditions, transaction limits: `https://www.duitku.com/frequently-asked-questions/`
- Direct API reference, inquiry and callback signatures, changelog: `https://docs.duitku.com/api/en/`
- SNAP API reference, Debit Payment Refund endpoint, callback IP allowlist, SNAP registration: `https://docs.duitku.com/snap-api/id/`
- Direct Credit Card reference, `void` and `refund` endpoints: `https://docs.duitku.com/direct-credit-card/id/`
- Merchant documents and NPWP FAQ: `https://www.duitku.com/faq/`

**Stripe**

- Country availability: `https://stripe.com/global`

#### 5.4.4 Transaction costs (checked 2026-11-11)

All figures are IDR per successful transaction as published by the provider. Effective percentages are analyst arithmetic for illustration only, using a **Rp 50,000** and a **Rp 100,000** plan price; they are not quoted rates.

**Midtrans** — no setup fee, no monthly fee, charged per successful transaction.

| Channel | Published fee | VAT treatment | Effective at Rp 50,000 | Effective at Rp 100,000 |
|---|---|---|---|---|
| Bank transfer / VA | Rp 4,000 flat | Excluded; 11% VAT applies on the fee | Rp 4,440 (8.9%) | Rp 4,440 (4.4%) |
| QRIS | 0.7% | Inclusive | Rp 350 (0.7%) | Rp 700 (0.7%) |
| GoPay | 2% | Inclusive | Rp 1,000 (2.0%) | Rp 2,000 (2.0%) |
| ShopeePay | 2% | Inclusive | Rp 1,000 (2.0%) | Rp 2,000 (2.0%) |
| Other e-wallets | 1.5% | Excluded | Rp 833 (1.7%) | Rp 1,665 (1.7%) |
| Credit card | 2.9% + Rp 2,000 | Excluded | Rp 3,450 (6.9%) | Rp 4,900 (4.9%) |
| Minimarket | Rp 5,000 flat | Excluded | Rp 5,550 (11.1%) | Rp 5,550 (5.6%) |

The published page adds a caveat that must not be lost: **"Gaming & digital product companies are subject to different rates."** The actual rate for this business category is not published and cannot be obtained without contacting Midtrans. Every Midtrans figure above is therefore an *upper bound assumption*, not a quote for this merchant.

**Duitku** — no setup fee, no monthly fee, charged per successful transaction. The published page states that **all displayed prices already include PPn (VAT)** and that there are no hidden fees.

| Channel | Published fee (VAT-inclusive) | Effective at Rp 50,000 | Effective at Rp 100,000 |
|---|---|---|---|
| Bank transfer / VA, general | Rp 3,000 | 6.0% | 3.0% |
| Mandiri VA | Rp 4,000 | 8.0% | 4.0% |
| BCA VA | Rp 5,000 | 10.0% | 5.0% |
| QRIS | 0.7% | 0.7% | 0.7% |
| OVO / DANA / LinkAja | 1.67% | 1.67% | 1.67% |
| ShopeePay | 2% | 2.0% | 2.0% |
| Credit card | 2.9% + Rp 2,500 | 7.9% | 5.4% |
| Alfamart / Pegadaian / POS | Rp 2,500 | 5.0% | 2.5% |
| Indomaret | Indomaret-set MDR + Rp 1,000 | not computable | not computable |

At the Rp 50,000 price point Duitku's general VA is **Rp 4,440 versus Rp 3,000**, roughly a third cheaper than Midtrans after VAT. At Rp 100,000 the gap narrows to Rp 4,440 versus Rp 3,000, still in Duitku's favour.

**Xendit** — three cost layers stack, and one of them is fatal at this scale.

| Cost layer | Published amount | Note |
|---|---|---|
| Per-channel payment fee | Not verifiable here | `xendit.co/en/pricing` returned HTTP 403 to this review; the documented fee page defers to it |
| Xendit Processing Fee | Additional fee on every payment acceptance, payout, and refund attempt | Introduced 1 Oct 2026; applies to failed card attempts too |
| Refund fee | Each successful refund incurs its own processing fee | The original payment fee is retained |
| Card chargeback dispute fee | **USD 25** per chargeback | Non-refundable regardless of outcome |
| Local-method chargeback dispute fee | **USD 15** per dispute | Non-refundable |
| **Monthly Minimum Fee** | **USD 50**, charged only to a **Dormant Account** or to an account whose **monthly invoice is below USD 50** | Conditional, not unconditional. See the note below |

**The Monthly Minimum Fee is conditional and must not be stated as a flat charge on every account.** Xendit's pricing policy defines two triggers: (a) a **Dormant Account**, which Xendit defines as an account with **no transactions within 180 calendar days** after the go-live date or the last transaction date; or (b) a month in which the **total invoice, excluding chargeback fees, is below USD 50**. Where neither trigger applies, the fee does not apply. Xendit also advises closing a dormant account to avoid it.

**Consequence for a low-volume merchant, which is the situation this project is in.** The fee is small for a merchant who transacts regularly, but this platform does not. Its realistic early profile is a handful of subscriptions per month, which means a monthly invoice well under USD 50 and the **second trigger firing every month**. At an assumed exchange rate of about IDR 16,000 per USD, the effective charge is roughly **IDR 800,000 per month** — about **eight times** the entire IDR 100,000/month hosting budget — until sustained transaction volume brings accrued fees above USD 50 on their own. The 180-day dormancy trigger is a separate risk during any quiet period. The rate is an assumption; the USD 50 amount and both triggers are verified.

**Stripe** — not costed, because there is no self-serve Indonesian path to price.

#### 5.4.5 Webhook security comparison

| Control | Midtrans | Xendit | Duitku (Direct API) | Duitku (SNAP API) |
|---|---|---|---|---|
| Transport | `POST`, JSON body | `POST`, JSON body | `POST`, `application/x-www-form-urlencoded` | `POST`, JSON body |
| Where the signature lives | Body field `signature_key` | Header, `x-callback-token` (token) or `X-Callback-Signature` + `X-Callback-Timestamp` (HMAC SHA256) | Body field `signature` | Request headers, `X-SIGNATURE` with `X-TIMESTAMP`, `X-PARTNER-ID`, `X-EXTERNAL-ID` |
| Algorithm | `SHA512(order_id + status_code + gross_amount + ServerKey)` | HMAC SHA256 over the raw body with the callback token, plus a timestamp for replay windows | `HMAC_SHA256(merchantCode + amount + merchantOrderId, apiKey)` | SNAP symmetric/asymmetric signature scheme, per the SNAP specification |
| Requires raw request body | Yes, to recompute the hash exactly | Yes, for the HMAC form | No, the form fields are sufficient; the hash covers three named fields | Yes, the JSON body is signed |
| Replay protection provided by provider | Timestamp is not signed; deduplicate on `order_id` | `X-Callback-Timestamp` supports a window; deduplicate on `payment_id` / `capture_id` | No timestamp; deduplicate on `merchantOrderId` / `reference` | `X-TIMESTAMP` is part of the signed header set |
| Documented duplicate behavior | Possible duplicates; `order_id` is the dedup key | Duplicates expected after retries; provider publishes server-side ids for dedup | Resends while HTTP 200 is not returned | Documented handling of double payments in the SNAP flow |
| Retry policy | Matrix by response code: 2xx none, 500 once, 503 four, 400/404 twice, other five; 307/308 followed up to five times | Six retries at 15m, 45m, 2h, 3h, 6h, 12h | Five attempts, then an email; manual resend from the dashboard | Follows the SNAP registration and callback agreement; not stated as a fixed public matrix |
| Source IP allowlist | Published production and sandbox ranges | Not published in the pages reviewed | **Not published** for the standard Direct API callback | **Published**: production and sandbox callback addresses |
| Endpoint constraints | Must be public internet, standard port, no auth, no VPN, no IP-literal host, must not redirect | Public HTTPS endpoint | Public endpoint | Public endpoint, **default ports only (80/443)**, no custom port |
| Provider-acknowledgement timeout | 15 seconds | Not stated as a fixed number; 2xx required | HTTP 200 required | Per SNAP callback contract |
| Availability conditions | Standard merchant activation | Standard merchant activation | Standard merchant activation | **Requires SNAP registration and an ASPI recommendation letter; roughly 14 business days if no revision** |

**Do not generalise across Duitku's products.** Duitku ships two distinct integration surfaces, and their security properties are not interchangeable. The **Direct API** is the older, simpler integration: a form-encoded callback secured by an HMAC over three fields, with no published IP allowlist. The **SNAP API** is the Bank Indonesia standard: a JSON body, a signed header set including a timestamp and partner identifiers, a published callback IP allowlist, and a registration gate in front of it. A design that assumes the SNAP properties while integrating against the Direct API would be wrong, and vice versa.

All four surfaces can satisfy `BACKEND.md` §7.5. Midtrans offers the strongest published operational contract: a signed body field over an idempotent order id, a documented retry matrix, a published IP allowlist, and an explicit status-query backstop. Duitku's Direct API is the simplest to implement but the weakest on replay: its signature covers `merchantCode + amount + merchantOrderId` and carries no timestamp, so freshness must come entirely from our own dedup on `merchantOrderId`. That is acceptable only because §7.5 already requires idempotency on `(provider, provider_event_id)`. Duitku's SNAP surface closes most of that gap but adds a registration dependency before a single sandbox call can be verified.

Xendit's `x-callback-token` scheme is a shared secret compared as a token, not a message MAC over the payload; its newer API surface adds a genuine HMAC plus timestamp. That is workable but means the adapter's verification code differs by which Xendit endpoint family is used.

#### 5.4.6 Recurring versus manual payment

**Recommendation: manual per-period payment. Do not adopt native recurring for Phase 6.**

The reasoning is not a cost argument; it is a fit argument.

- `BACKEND.md` §7.2 already defines the required behavior: a new payment creates a new subscription period, and stacking extends `expires_at`. Nothing in the specification asks for automatic charging.
- Native recurring (Midtrans card or GoPay tokenization, Xendit MIT channels) requires storing a payment token tied to a saved credential. That adds a token vault, a PCI-scope conversation, a failed-payment dunning flow, and a new class of dispute where the user says they never authorised the later charge. None of that is in `BACKEND.md` §8.2.
- Every supported recurring path discards the Indonesian channels most users actually hold. Midtrans subscription is card and GoPay only. Xendit subscriptions require a Merchant-Initiated-Transaction channel. A wallet-first Indonesian buyer would still pay manually.
- Manual payment keeps the audit trail simple: one transaction, one webhook, one entitlement, one `payment_events` row. Auto-charge would require linking a provider-side cycle id to a local transaction, which is a second identity space in the schema.

**What manual payment does not change, stated plainly.** Choosing manual renewal avoids **automatic recurring charges**. It does **not** remove, reduce, or defer any of the following, all of which must still be designed, tested, and funded:

- **Refund obligations.** A user who is refused a refund still has a claim. Manual payment changes the mechanism, not the liability.
- **Duplicate and double payments.** The customer pays twice, or a retry produces a second settled charge. This must be detected and refunded manually, which is precisely why Duitku's Direct API having no refund endpoint is an operational burden rather than a neutral fact.
- **Chargebacks and disputes.** A card issuer can reverse a charge regardless of what our renewal model is. The dispute fee, the evidence deadline, and the entitlement reversal still apply.
- **Fraud.** Stolen cards, account takeover, and abuse of the free-key path are unaffected by the renewal model.
- **Consumer-protection and record-keeping duties.** A transaction record, a receipt, a stated refund policy, and a complaint path are owed to the buyer on their own footing, not because a subscription auto-renewed.
- **Reconciliation exceptions.** A missed webhook or a delayed settlement still has to be repaired against the provider.

**The honest summary:** manual payment solves one problem, the unauthorised-repeat-charge problem. It does not make the refund or dispute surface disappear, and any provider assessment that treats "no recurring" as "no refund exposure" is wrong. §5.4.10 Q17 requires a written policy either way.

Native recurring therefore stays a **future option behind the adapter**, not a Phase 6 requirement. If the owner later wants it, it is an adapter addition plus a schema addition, not a redesign.

#### 5.4.7 Vendor lock-in analysis

| Lock-in surface | How strongly it binds | Mitigation already required by the plan |
|---|---|---|
| Webhook payload shape and signature algorithm | Moderate. Each provider differs enough that the parser is provider-specific | Confined to one adapter; `payment_events.raw_payload` preserves the original body |
| Transaction identity | Low if we own the order reference. Midtrans uses `order_id`, Duitku uses `merchantOrderId`, Xendit uses its own ids plus our reference | Keep our own reference as the join key and store the provider id separately in `provider_txn_id` |
| Checkout UI | Low to moderate. Midtrans Snap, Xendit Payment Session, Duitku redirect are all hosted pages | Checkout is a redirect plus a return route; no provider component is embedded in our pages |
| Stored payment credentials | High where recurring is used | Avoided entirely by the manual-payment decision in §5.4.6 |
| Settlement and payout cycle | Operational, not technical | Tracked in the reconciliation job, not in domain tables |
| Merchant onboarding / KYC | **High and outside our control.** Re-onboarding is days to weeks and can be rejected | Cannot be mitigated in code; it is the real switching cost and belongs in the owner's decision |
| Fees | Medium. Fee changes are unilateral | `amount_minor` is ours; fees are a margin input, not a stored value |

Net: the technical switching cost is roughly **one adapter plus a re-onboarding cycle**. The `PaymentVerifier` boundary in `BACKEND.md` §7.5 is adequate. The binding constraint is merchant approval, not code.

#### 5.4.8 Eligibility risk that outranks the technical comparison

**Owner direction (2026-11-11): eligibility is decided by parallel written applications to both retained candidates. That process is recorded in §5.4.9.**

This must be resolved before any provider is chosen, because a technically correct choice that cannot be onboarded is worthless.

Midtrans publishes a prohibited-business list. Three entries bear directly on a paid game script product:

- **"Selling Copyright-Infringing or Counterfeit Products"** — covering trademarks, copyrights, and patents.
- **"Goods and/or Services Involving Hacking or Unauthorized Access."**
- **"Game boosting or rank-up services (Joki)."**

No document reviewed states how Midtrans classifies a paid automation script for a third-party game. **This review does not conclude that the product will be accepted, and it does not conclude that it will be rejected.** Both remain open. What is established is that the categories exist, that they are broad, and that an activation rejection is a realistic outcome that would strand Phase 6 after the work is done.

**Eligibility review is mandatory for every candidate, including Duitku.** Duitku publishes a merchant document list and an operational FAQ but no readable prohibited-business list was located during this review, and an unlocated list is not the same as no list. Duitku must not be treated as the fallback that is automatically safe just because its risk is undocumented.

**Therefore:** every retained candidate carries an unresolved eligibility question. No adapter code may be written against any provider until that provider has given a **written** position that specifically names the BOYFINITY product and business model. A verbal indication, a generic merchant approval, or an inference from a published list is not sufficient.

**Disclosure duty, which is part of the requirement and not a nicety.** Both providers must receive the **same, honest, complete** product description. The application must not conceal, soften, or omit the intended use of the product in order to obtain approval. An approval obtained by misrepresentation is not an approval: it is a latent termination risk, it would invalidate every downstream planning assumption, and it would put settlement, refunds, and chargebacks at risk after launch. If the honest description is refused, that refusal is a valid and useful result — it removes a candidate before any code is written.

#### 5.4.9 Provider selection procedure (owner decision, 2026-11-11)

**Owner decision, recorded in effect:** the retained candidate set is **Midtrans and Duitku**. Xendit and Stripe are no longer candidates, for the reasons already documented in §5.4.4 and §5.4.11. The owner has **not registered with either provider**. The owner will submit **eligibility assessments to both providers in parallel**. The provider that first returns a **written approval that specifically covers the BOYFINITY Hub product and business model** becomes the primary choice.

**Status after this decision:**

| Item | Status |
|---|---|
| D3 | **UNAPPROVED** |
| Midtrans | **Candidate — eligibility pending** |
| Duitku | **Candidate — eligibility pending** |
| Provider selection | **Pending written eligibility approval** |
| Payment adapter | **BLOCKED** |
| Phase 1 | **NOT STARTED** |

**Selection rule, stated precisely.** The deciding event is a *written approval that specifically names the product and business model*. It is **not**:

- the order in which a provider replies,
- the speed of onboarding or sandbox access,
- a generic "merchant approved" status that does not address the product category,
- a verbal indication from a sales or support contact,
- an inference from a published acceptable-use list.

**The owner's instruction on this point is explicit: do not select a provider based on informal response order or onboarding speed.** A provider that answers first with a generic merchant approval has **not** satisfied the rule. A provider that answers first with a written, product-specific approval has.

**No provider is the current default.** Both are candidates on equal footing until the written positions arrive. Any earlier framing in this section that treated Midtrans as "primary" and Duitku as "alternative" is **superseded** by this procedure; the technical findings behind that framing remain valid as a comparison, but they no longer imply an ordering.

**Required verification checklist.** Before a provider selection is treated as final, all eight items must be recorded and verified for the winning candidate:

| # | Item to verify | Why it must be in writing |
|---|---|---|
| 1 | Is the BOYFINITY product category accepted? | A generic merchant approval does not answer this |
| 2 | Are the business model and the product distribution method permitted? | The model is paid subscriptions plus a free-key offer path, not a simple one-off sale |
| 3 | Can an individual merchant register? | Both candidates document individual onboarding, but the accepted entity type must be confirmed for this application |
| 4 | Which legal and tax documents are required? | Determines whether registration can complete at all; NPWP is required by both |
| 5 | What is the **actual** rate for this product category? | Midtrans applies an unpublished schedule to "gaming and digital product" merchants |
| 6 | Which payment channels are available? | Determines the effective fee mix and the checkout surface |
| 7 | What are the refund, dispute, chargeback, and settlement policies? | `BACKEND.md` §7.5 defines a `refunded` status but no policy |
| 8 | Is the approval written and citable? | It must be referenceable in this plan and in any later dispute |

**Outcome handling, as directed by the owner:**

- **If exactly one provider approves** with a written, product-specific approval, that provider becomes the primary choice. The other remains documented as the fallback. D3 still requires the owner's explicit approval before it is marked approved; a provider's approval is a necessary input, not the D3 approval itself.
- **If both approve**, the owner chooses between them using the §5.4.4 cost comparison, the §5.4.5 webhook comparison, and item 5 of the checklist above.
- **If one refuses**, the other remains a candidate. A refusal is not a D3 failure; it is the process working.
- **If both refuse, or if neither gives a definite position, no payment adapter is built.** In that case Phase 6 does not proceed on payment integration, and the monetization model must be revisited with the owner before any further payment work. This is a hard stop, not a prompt to seek a third provider without the owner's direction.

**Binding constraint:** this subsection is the gate. Until items 1 through 8 are recorded in writing for the selected provider, **the payment adapter stays BLOCKED** and D3 stays **UNAPPROVED**.

#### 5.4.10 Unresolved questions requiring owner input

Q12 and Q15 below are now partly answered by the decision in §5.4.9: the owner has committed to asking both providers. They remain open until the written answers arrive.

| ID | Question | Why it blocks | Proposed default |
|---|---|---|---|
| Q12 | **Can this product be onboarded at all?** Does a paid game automation script fall under a prohibited category at Midtrans or Duitku? | If both refuse, no adapter is built and the monetization model needs owner reconsideration | Owner is obtaining written positions from both in parallel (§5.4.9). No provider has been cleared |
| Q12a | If Duitku is selected, is the **Direct API** or the **SNAP API** the integration target? | Refund capability, callback IP allowlist, signature scheme, and the onboarding timeline all differ between them | SNAP adds an ASPI registration step of roughly 14 business days; Direct API is faster but has no refund endpoint |
| Q13 | Is the merchant a registered business (PT/CV) or an individual? | Changes the required documents and the accepted entity type for this application | Assume individual: KTP + NPWP, matching bank account name |
| Q14 | Does the owner hold an NPWP? | Both retained candidates require it in some form; Duitku offers student/spouse alternatives | Required for Midtrans and Duitku individual onboarding |
| Q15 | What is the **actual** rate for a "gaming and digital product" merchant? | Midtrans applies a different, unpublished schedule; the real fee is unknown until a written quote is obtained | Obtain a written quote from the selected provider before Phase 6 estimates are treated as reliable |
| Q16 | Manual per-period payment, or native recurring? | Decides whether a token vault and dunning flow exist at all | Manual, per §5.4.6 |
| Q17 | What is the refund policy, and which provider can actually execute it? | `BACKEND.md` §7.5 defines the `refunded` status but no policy. Duitku's refund support is split by API surface and channel, so the answer changes the integration choice, not just the policy | Decide before launch; a written policy is required regardless of provider |
| Q18 | Which channels must be enabled at launch? | Determines the effective fee mix and the checkout UI | QRIS plus one VA plus GoPay, if the provider allows selective activation |
| Q19 | Which settlement destination bank account, and in whose name? | Payout fails if the account name does not match the merchant identity | Must match the merchant documents exactly |
| Q20 | If **both** providers refuse or neither commits to a written position, what replaces the paid-subscription model? | §5.4.9 closes with a hard stop: no adapter is built and Phase 6 cannot proceed on payment | Owner decision required before any further payment work. Do not silently substitute a third provider |

#### 5.4.11 Verification status and method

**Verified from official documentation on 2026-11-11:** the Midtrans signature formula, retry matrix, IP allowlist, legal-document requirements, fee structure with VAT treatment, minimum and maximum transaction values, withdrawal timing, refund fee position, and the prohibited-category list; the Xendit minimum monthly fee **and both of its triggers (180-day dormancy and a monthly invoice below USD 50)**, refund and chargeback fees, retry schedule, `x-callback-token` and HMAC header documentation, Indonesia document requirement and the individual/XP restriction, settlement variability, and subscription prerequisites; the Duitku price list with its PPn-inclusive statement, withdrawal timing, **the Direct API absence of refunds, the SNAP Debit Payment Refund endpoint, the Direct Credit Card `void` and `refund` endpoints, the channel-specific refund guidance in the FAQ, the SNAP callback IP allowlist, and the SNAP registration and ASPI recommendation requirement**, callback signature formula and five-attempt resend behaviour, and its individual merchant document requirements including the NPWP position; and Stripe's Indonesia status as **Preview** with a contact-sales link rather than a registration link.

**Corrected in this pass (2026-11-11):**

- The earlier statement that "Duitku states it does not provide refunds" was **too broad**. It describes the Direct API and the general FAQ wording only. Duitku's SNAP API exposes a Debit Payment Refund endpoint, and Direct Credit Card exposes both `void` and `refund`. The refund table now distinguishes support **per API surface and per payment channel**, as it must.
- The Xendit USD 50 fee was described as if charged to every account. It is **conditional**: it applies to a Dormant Account or to an account whose monthly invoice is below USD 50. The consequence for low volume is unchanged and argued separately, but the fee itself is no longer stated as unconditional.
- The Duitku webhook row claimed no published IP allowlist. The **SNAP API publishes production and sandbox callback addresses**; the standard Direct API does not. The webhook table is now split by API product rather than generalised.
- The claim that manual payment lowers refund exposure was **wrong and is removed**. Manual renewal avoids automatic recurring charges only. Refund, duplicate payment, chargeback, fraud, and consumer-protection duties remain.
- The eligibility section previously implied a determination about the product. It now states explicitly that **no acceptance or rejection is concluded**, and that **both retained candidates carry the same unresolved question**.

**Not verified, and not to be assumed:**

- Whether the BOYFINITY product is eligible at **either** retained candidate. No written position has been requested or received.
- Whether either provider will return a product-specific approval rather than a generic merchant approval, and on what timeline.
- Any Midtrans rate for a "gaming and digital product" merchant. The different-rate statement is published; the number is not.
- Xendit's per-channel fee percentages. The pricing page returned HTTP 403 to this review.
- Duitku's prohibited-business or acceptable-use list. **No readable list was located; this is an absence of evidence, not evidence of absence.**
- Whether SNAP refund is enabled for a given merchant, which channels the SNAP refund path covers, whether refunds carry a fee, and whether SNAP registration would be granted.
- Whether Duitku disbursement is available to an individual (non-company) merchant. The FAQ states disbursement registration requires a **company-name** account.
- Whether the SNAP published IP addresses also cover the standard Direct API callback. No equivalent list was found for the Direct API.
- Any settlement, approval, or activation outcome. No account exists, no application was submitted, and no provider was contacted.
- The IDR/USD exchange rate used to size the Xendit minimum fee. Only the USD 50 amount and its triggers are verified.

**Owner decision recorded (2026-11-11):** Midtrans and Duitku are the retained candidates; Xendit and Stripe are dropped. The owner has not registered with either provider and will submit eligibility assessments to both in parallel. Selection is decided by the first **written, product-specific** approval, not by response order or onboarding speed. No adapter is built until the eight-item checklist in §5.4.9 is satisfied. This is a **process decision only** — it does not approve D3, does not approve a provider, and does not unblock the adapter.

**Method note:** this was a documentation review. No merchant account was created, no sandbox was called, no transaction was attempted, and no webhook was delivered. Every effective-percentage figure in §5.4.4 is analyst arithmetic on published rates, and every risk statement in §5.4.7 and §5.4.8 is an analyst judgment, not a measured result.

---

## 6. Module Dependency Map

### 6.1 Layers

| Layer | Modules | Purpose |
|---|---|---|
| L0 | Decision records, threat model, environment inventory | Remove blocking ambiguity before code |
| L1 | Config, env validation, logger, errors, request IDs, DB client, migration runner, idempotency store, rate-limit store | Shared foundation used by every module |
| L2 | Discord OAuth, sessions, CSRF, role loading, authorization guards | Identity and access control |
| L3 | Users, profiles, account deletion, user settings | Account domain |
| L4 | Games, scripts, versions, publishing, public catalog, access logs | Content domain |
| L5 | Keys, key sessions, HWID binding and reset, usage, access orchestration | Entitlement domain |
| L6 | Ban proposals, bans, evidence, reversals, reactivations, ban enforcement | Trust and safety domain |
| L7 | Plans, subscriptions, transactions, payment adapters, reconciliation | Monetization domain |
| L8 | Offers, offer intents, offer completions, provider adapters | Free-key acquisition |
| L9 | Admin endpoints, permission matrix, audit viewer, settings, announcements, changelogs | Administrative surface |
| L10 | User and admin UI integration, public pages, design-system components | Frontend delivery |
| L11 | Hardening, performance, backups, staging, production readiness | Release quality |

### 6.2 Dependency graph

```text
L0 decisions
  |
  v
L1 foundation and schema
  |
  v
L2 auth and roles
  |
  v
L3 users
  |
  v
L4 catalog
  |
  v
L5 keys
  | \
  |  v
  | L6 trust and safety
  |
  +----> L7 monetization ----+
  |                          |
  +----> L8 offers ----------+
                             |
                             v
                          L9 admin surface
                             |
                             v
                          L10 frontend delivery
                             |
                             v
                          L11 hardening and release
```

### 6.3 Explicit dependencies

| Module | Depends on | Reason |
|---|---|---|
| Config and env validation | L0 decisions | Secret names, provider choices, and runtime mode must be known |
| DB client and migrations | Config | Connection string, pool settings, and migration target |
| Idempotency store | DB client | Durable replay protection |
| Rate-limit store | DB client | Shared counters across instances |
| OAuth and sessions | Config, DB, users table | State storage, token exchange, session rows |
| Role guards | Sessions, `user_roles` | Server-side permission resolution |
| Users | Auth | A user row is created by the OAuth callback |
| Catalog | Auth, roles, DB, storage | Admin writes need authorization; content may live in Storage |
| Keys | Catalog, users, auth | Ownership, script eligibility, and session identity |
| Access orchestration | Keys, catalog | Combines key validity with script eligibility without a module cycle |
| Bans | Keys, auth, roles | A ban targets a key and requires `key.ban` or `key.ban.review` |
| Reversals | Bans, keys, auth | A request targets a confirmed ban and is owned by the key owner |
| Reactivations | Reversals, keys, auth | An authorization follows a reversed ban and is consumed by activation |
| Plans and subscriptions | Users, keys | A subscription grants or extends key access |
| Transactions and payments | Plans, keys, config | A verified payment creates a subscription or paid key |
| Offers | Keys, users, config | A verified offer issues a free key |
| Admin surface | All domain modules, roles, audit | It orchestrates existing domain operations |
| Frontend delivery | Auth contract, domain endpoints, `DESIGN.md` | Pages consume stable APIs and design tokens |
| Hardening | All prior layers | It tests and hardens what exists |

### 6.4 Cycle avoidance

Two natural cycles must be broken deliberately:

1. **Catalog and keys.** Script retrieval needs key validation, while key validation needs script eligibility. Resolve this with a planned `src/access` orchestration service that depends on both modules. Neither the catalog module nor the keys module imports the other directly. Both routes call `access.authorizeScript(...)`.
2. **Bans and keys.** A ban changes key status, and key activation checks ban state. Resolve this by making `keys.status` the single enforcement source. The ban module writes the status and the key module reads it. The key module never imports the ban module.

A third potential cycle is payments and keys: a payment can create a key, and a key can link a subscription. Resolve it with a service that creates the entitlement after the payment is verified. The payment module does not call key route handlers, and the key module does not verify payments.

### 6.5 Parallel work

After L1 and L2 are stable, these streams can run in parallel with clear interfaces:

- Catalog backend and public catalog UI.
- Design-system components and dashboard shells.
- Payment provider adapter sandbox work, after a provider is chosen.
- Offer provider sandbox work, after callback formats are verified.
- Test harness, fixtures, and CI pipeline.

Do not parallelize ban work with key work. The ban workflow writes key status and needs a stable key state machine. Do not parallelize reactivation with reversal. Reactivation consumes a ban outcome that must exist first.

### 6.6 Release gates by dependency

| Gate | Must be true |
|---|---|
| Foundation ready | One API function under `/api` deploys, health passes, migrations apply to a fresh database |
| Auth ready | OAuth round trip works, state mismatch is rejected, roles load from the database |
| Catalog ready | Published and enabled scripts are readable, admin writes are authorized and audited |
| Keys ready | Activation, validation, reset, single session, and terminal status gates pass |
| Trust and safety ready | Ban, review, reversal, reactivation, and consumption invariants pass |
| Monetization ready | Signed webhooks grant exactly once and replays do nothing |
| Offers ready | Verified callbacks issue one key and redirects grant nothing |
| Admin ready | Every matrix cell is enforced and every mutation is audited |
| Release ready | No critical or high findings, restore rehearsal passed, staging smoke passed |

---

## 7. Proposed Project Structure

No directories or files are created by this plan. The tree below is the target for Phase 1 and later phases.

```text
BOYFINITY-Hub/
├── app/
│   ├── (public)/                  public landing, catalog, game, docs, changelog pages
│   ├── (dashboard)/               authenticated user dashboard pages
│   ├── admin/                     admin dashboard pages
│   ├── api/
│   │   └── [...path]/route.ts     the only API function entry point
│   ├── layout.tsx                 root layout and metadata
│   └── globals.css                design tokens and base styles
├── src/
│   ├── core/
│   │   ├── config/                typed environment parsing and runtime guards
│   │   ├── errors/                error codes, external shape, internal mapping
│   │   ├── http/                  request parsing, response helpers, request IDs
│   │   ├── logging/               structured logger and redaction
│   │   ├── time/                  clock abstraction for tests
│   │   └── crypto/                constant-time compare, token and HMAC helpers
│   ├── middleware/                body limits, session, rate limit, CSRF, auth, roles
│   ├── router/                    route table, matcher, dispatcher
│   ├── modules/
│   │   ├── auth/                  OAuth, sessions, logout, logout-all
│   │   ├── users/                 profile, account deletion, user settings
│   │   ├── catalog/               games, scripts, versions, publishing, public reads
│   │   ├── keys/                  lifecycle, sessions, HWID, usage
│   │   ├── access/                script authorization orchestration
│   │   ├── trust-safety/          bans, evidence, reversals, reactivations
│   │   ├── billing/               plans, subscriptions, transactions, webhooks
│   │   ├── offers/                offer intents, completions, provider callbacks
│   │   └── admin/                 overview, users, audit, settings, announcements
│   ├── providers/
│   │   ├── discord/               OAuth client
│   │   ├── payments/              PaymentVerifier implementations
│   │   ├── offers/                work.ink and LootLabs adapters
│   │   └── storage/               Supabase Storage adapter and signed URLs
│   ├── db/
│   │   ├── client.ts              pooled connection and transaction helper
│   │   ├── schema.ts              typed table definitions
│   │   └── repositories/          SQL for each domain
│   ├── jobs/                      scheduled job handlers and registry
│   ├── validators/                Zod schemas shared by routes and OpenAPI
│   └── lib/                       small shared utilities with no domain logic
├── supabase/
│   └── migrations/                ordered SQL migrations
├── tests/
│   ├── unit/                      pure functions and validators
│   ├── integration/               API and database against a test Postgres
│   ├── contract/                  OpenAPI and response-shape checks
│   ├── concurrency/               parallel activation, decisions, consumption
│   └── e2e/                       Playwright user and admin journeys
├── scripts/                       local maintenance and test helpers
├── public/                        static assets
├── docs/                          planned ADRs and generated OpenAPI artifact
├── DESIGN.md
├── AGENTS.md
├── BACKEND.md
├── BACKEND.documentation-complete.checkpoint.md
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

### 7.1 Directory responsibilities

- `app/` contains routing and page composition only. No business rules. Only one `route.ts` exists under `app/api/`, and it is the catch-all. No Server Actions are used as a mutation path.
- `src/core/` contains behavior every module needs. It has no knowledge of keys, bans, or payments.
- `src/middleware/` contains cross-cutting request policy. It does not contain domain rules and does not open database connections.
- `src/router/` maps method and path to a handler and declares access and permission requirements.
- `src/modules/` contains domain rules, one folder per bounded context. Each module exposes handlers, services, and a repository interface.
- `src/providers/` isolates external vendors behind narrow interfaces, which keeps payment and offer changes contained.
- `src/db/` owns SQL and transactions. No route handler writes SQL directly.
- `src/jobs/` owns scheduled work and job idempotency.
- `src/validators/` owns request and response schemas. It is the source for OpenAPI.
- `tests/` is separated by test kind so slow and destructive tests are easy to schedule.
- `supabase/migrations/` is the only place schema changes live.
- `docs/` holds decision records and generated API documentation, not runtime code.

---

## 8. Phased Implementation Roadmap

### 8.1 Phase numbering and the existing roadmap

`BACKEND.md` Section 14 defines ten phases. This plan keeps the same intent but re-sequences work so no module starts before its dependencies exist. The mapping is:

| This plan | `BACKEND.md` Section 14 |
|---|---|
| Phase 0 | Not present; decision gate added |
| Phase 1 | Phase 1 foundation, Phase 2 database, and the skeleton of Phase 3 |
| Phase 2 | Phase 4 |
| Phase 3 | Phase 5 plus the user-facing part of Phase 8 |
| Phase 4 | Phase 6 |
| Phase 5 | Not separate; expands Section 6.11 and Section 9.5 |
| Phase 6 | Phase 7 payments |
| Phase 7 | Phase 7 offers |
| Phase 8 | Phase 9 plus the remaining part of Phase 8 |
| Phase 9 | Phase 10 security testing |
| Phase 10 | Phase 10 production deployment |

This is a planning re-sequencing, not a contradiction. The Section 14 list remains the documented phase vocabulary.

### 8.2 Phase 0 - Architecture and project setup decisions

**Objective:** Remove blocking ambiguity and record the choices that shape every later phase.

**Prerequisites:** The documentation audit in Section 2.

**Deliverables:**

- Decision records for D1 to D18 and D1a, each with context, options, decision, and consequences.
- Hosting terms record for D1a with official sources, commercial-eligibility finding, cost, and recommended tier.
- Environment variable inventory with scope and owner for each secret.
- Threat model covering OAuth, sessions, key ownership, HWID, bans, evidence, payments, and offers.
- Provider selection or explicit deferral for payments, offers, error tracking, and scheduling.
- Retention proposal for sessions, access logs, audit logs, and ban evidence.
- Confirmation that no executor, anti-cheat, or unauthorized game integration is in scope.

**Planned files and modules:** `docs/adr/`, `docs/decision-log.md`, `docs/threat-model.md`.

**API endpoints:** None.

**Database changes:** None.

**Security requirements:** Every secret has an owner and a storage location. The threat model explicitly lists what is not trusted from the client. Decisions that weaken a FINAL rule are rejected.

**Unit tests:** None. A decision checklist is reviewed manually.

**Integration tests:** None.

**Acceptance criteria:** D1 is recorded as FINAL. D2, D3, D8, D10, and D11 are resolved. D5 and D18 have an owner and a deadline. **D1a is closed for planning purposes by the owner's deferral** (2026-11-10, reaffirmed 2026-11-11): the decision itself is complete because the owner has resolved it as deferred, with the budget target and candidate record captured in Section 5.2.8. That closure satisfies the planning gate only. **Procurement remains blocked:** no account registration, VPS purchase, domain purchase, database subscription, or deployment may occur until D1a is affirmatively approved with a verified all-in cost inside the budget. No phase starts with a blocking decision unresolved.

**Risks and blockers:** Decision paralysis. Reversing a vendor choice later is expensive. A payment provider may impose country or payout constraints that invalidate the preferred option. Hosting procurement is deferred, so deployment cannot start until D1a is decided. Helipod's advertised price and bonus terms are unverified and may not fit the IDR 100,000/month all-in budget once renewals, tax, IPv4, and database costs are known. A deployment that assumes Vercel Hobby would breach Vercel's commercial-use terms.

**Phase 0 completion checklist:**

- [x] D1 deployment model recorded as FINAL — OWNER APPROVED (Model A).
- [x] Model B documented as a rejected alternative with its comparison material preserved.
- [x] Model A consequences recorded: single API Route Handler, Node.js runtime, no rewrite, no separate backend, raw-body webhook verification, no Server Actions, no database access from Next.js middleware.
- [x] D1a baseline research completed from official Vercel sources.
- [x] D1a alternative-hosting research completed from official Render, Railway, Cloudflare Workers, and Supabase sources on 2026-11-10.
- [x] D1a research ranking recorded: Render Hobby first, Railway Hobby runner-up, Cloudflare Workers rejected for D1 incompatibility; none approved.
- [x] D1a hosting deferred by the owner on 2026-11-10 and reaffirmed on 2026-11-11. Budget target is approximately IDR 100,000/month all-in; no purchase or subscription is authorized.
- [x] Helipod VPS S Jakarta (2 vCPU, 2 GB RAM, 40 GB storage, 500 GB bandwidth, 20 Mbps, Jakarta, advertised IDR 79,900/month plus unverified bonuses) recorded as a candidate only, with no purchase authorization.
- [x] D1a unverified terms recorded: managed PostgreSQL, VPS backup renewal, IPv4, domain renewal and registrar, bandwidth overage and port guarantee, renewal pricing, taxes, SLA, acceptable-use, and Email API quota.
- [x] D1a procurement block recorded: D1a does not block architecture, schema, or security work, but it blocks procurement, account registration, domain purchase, database subscription, deployment, and production launch.
- [x] D1 portability under a VPS recorded: the architecture is standard Next.js on Node.js and is not tied to a specific platform; a VPS changes operational burden, not the approved design.
- [ ] Helipod bonus terms, renewal pricing, IPv4, backup renewal, bandwidth policy, taxes, and managed PostgreSQL cost verified.
- [x] D1a decision closed for **planning** by the owner's deferral (2026-11-10, reaffirmed 2026-11-11). This satisfies the Phase 0 decision gate; it does **not** approve a provider, a plan, a price, or a purchase.
- [ ] D1a provider, plan, and verified all-in recurring cost fit within IDR 100,000/month.
- [ ] D1a hosting tier and commercial terms approved by the owner after funds are available.
- [ ] D1a purchase authorized by the owner.
- [ ] D2 session ownership approved.
- [ ] **D3 payment provider approved — BLOCKED, not started.** No provider is selected. Midtrans and Duitku are both candidates pending written, product-specific eligibility approval (Section 5.4.9).
- [ ] D3 eligibility assessments submitted to both retained providers, with the **same, honest, complete** product description, and the resulting written positions recorded.
- [ ] D3 eight-item written checklist satisfied for the selected provider (product category, business model, individual merchant, legal/tax documents, actual rate, channels, refund/dispute/chargeback/settlement, citable written approval).
- [ ] D3 owner inputs recorded from Section 5.4.10: Q12 and Q15 (pending the written provider answers), Q12a Direct vs SNAP API if Duitku is selected, Q13 entity type, Q14 NPWP, Q16 manual versus recurring, Q17 refund policy, Q18 launch channels, Q19 payout account, Q20 fallback if both providers refuse. **D3 remains UNAPPROVED until a written product-specific approval is received and the owner approves on that basis.**
- [ ] D8 data access library approved.
- [ ] D10 idempotency storage approved.
- [ ] D11 rate-limit storage approved.
- [ ] D5 and D18 have an owner and a deadline.
- [ ] Documentation corrections approved and applied when protected files may be edited.
- [ ] Owner inputs for D2 recorded: Q1, Q2, Q11 unconditionally, plus Q7 if Option A is chosen or Q10 if Option B is chosen.
- [ ] `oauth_states` conditional status recorded in the Phase 1 migration (required if D2 resolves to Option A, not created under Option B, not assumed before D2 is decided).

### 8.3 Phase 1 - Project foundation and database

**Objective:** Produce a deployable skeleton with one API function under `/api` and the complete Section 8 schema.

**Prerequisites:** Phase 0 and decisions D8, D10, D11. D1 is already approved. **D1a is not a prerequisite for this phase:** it is deferred, and Phase 1 may build and test locally or against a hosted Postgres. D1a blocks only deployment, hosting procurement, domain purchase, and production launch (Section 5.2.8).

**Deliverables:**

- Next.js and TypeScript project with strict settings and Tailwind mapped to `DESIGN.md` tokens.
- The single API Route Handler at `app/api/[...path]/route.ts` with the Node.js runtime declared, a data-driven route table, and a normalized response helper.
- In-handler middleware skeleton: request ID, body size limits, session resolution, rate limit, CSRF hook, validation hook.
- Typed environment loader that fails fast on a missing secret.
- Structured logger with redaction.
- Pooled Postgres client and transaction helper. No database access from Next.js middleware.
- Ordered migrations for every table in Section 8, plus planned support tables for idempotency, rate limits, jobs, and OAuth state.
- RLS enabled with default deny and no client access policy.
- `/api/health` and a CI pipeline for type check, lint, unit tests, and migration checks.

**Planned files and modules:** `app/api/[...path]/route.ts`, `src/core/*`, `src/router/*`, `src/middleware/*`, `src/db/*`, `supabase/migrations/*`, `tests/unit/*`, `tests/integration/*`.

**API endpoints:** `GET /api/health`. A placeholder `GET /api/config/public` may be added but must return only non-secret data.

**Database changes:** All tables from Section 8: `users`, `user_roles`, `sessions`, `games`, `scripts`, `script_versions`, `script_access_logs`, `plans`, `keys`, `key_bans`, `key_ban_evidence`, `key_ban_reversals`, `key_reactivations`, `key_device_history`, `key_hwid_resets`, `key_sessions`, `system_settings`, `subscriptions`, `transactions`, `payment_events`, `offers`, `offer_completions`, `announcements`, `changelogs`, `audit_logs`. Planned support tables: `idempotency_keys`, `rate_limit_counters`, `jobs`, and `oauth_states`. **`oauth_states` is conditional, not optional.** It becomes required when D2 resolves to Option A (custom Discord OAuth), where it holds the single-use OAuth state and an optional `code_verifier` (Section 5.3.5). Under Option B it is not needed, because the auth library owns state storage. It must not be treated as mandatory before D2 is decided, and it must not be dropped as optional if Option A is approved. All enums, CHECK constraints, foreign keys, partial unique indexes, and indexes are included.

**Security requirements:**

- Service role key is server-only.
- RLS is enabled on every table with default deny.
- No secret is logged, returned, or bundled into client code.
- Migrations are reviewed SQL, not generated against production.
- The deployed API function list contains exactly one entry under `/api`.
- No second `route.ts`, `vercel.json` rewrite, Edge runtime for database work, Server Action mutation, or database connection from Next.js middleware is introduced.

**Unit tests:** Environment parsing, error mapping, request ID generation, route matching, response shape, logger redaction.

**Integration tests:** Migrations apply to a fresh database; each status CHECK rejects an invalid value; the partial unique index rejects a second pending reversal; the reactivation partial unique index rejects a second unused authorization; RLS denies anon reads; `/api/health` returns 200.

**Acceptance criteria:** A clean deploy succeeds. `/api/health` returns 200. The deployed API function list shows one API function under `/api`. Migrations apply from zero. Invalid rows are rejected by the database, not only by application code.

**Risks and blockers:** Next.js function detection may create an extra API function if a second `route.ts` appears under `app/api/`. Schema churn in later phases is expensive. Pool exhaustion is possible if the client is created per request. The function bundle must stay under 250 MB on either plan, and hosting cannot proceed on Hobby because the platform is commercial.

### 8.4 Phase 2 - Authentication and Discord OAuth

**Objective:** Establish immutable Discord identity, server-side sessions, and role-based authorization.

**Prerequisites:** Phase 1 and decision D2. D2 was reviewed in Section 5.3 on 2026-11-11 and **remains unapproved**; Phase 2 may start only after the owner approves D2. Phase 2 must answer the question set that D2 makes relevant: Q1 and Q2 unconditionally, Q11 to fix which controls are hard requirements, and **Q7** (PKCE, relevant if Option A is selected) and **Q10** (browser-side client, relevant only if Option B is selected) for whichever option is chosen. Under Option A, Q10 is not applicable and does not block Phase 2. The test list must treat the four controls in Section 5.3.2.4 separately, each with its own negative test.

**Deliverables:**

- Login, callback, session, logout, and logout-all handlers.
- `sessions` table usage with hashed opaque tokens, absolute expiry, idle window, rotation, and revocation.
- `user_roles` loading on every privileged request.
- CSRF protection for cookie-authenticated mutations.
- Reusable `requireUser`, `requireRole`, and `requirePermission` guards.
- Audit rows for login, logout, logout-all, and authorization denials.
- A mock Discord provider for automated tests.

**Planned files and modules:** `src/modules/auth/*`, `src/providers/discord/*`, `src/middleware/session.ts`, `src/middleware/csrf.ts`, `src/middleware/auth.ts`, `src/validators/auth.ts`, `tests/integration/auth/*`.

**API endpoints:** `GET /api/auth/login`, `GET /api/auth/callback`, `GET /api/auth/session`, `POST /api/auth/logout`, `POST /api/auth/logout-all`.

**Database changes:** `sessions`, `users`, `user_roles`; audit indexes. No new domain tables. **`oauth_states` is conditional, not optional:** it is required if and only if D2 resolves to Option A, and it is populated with `state_hash` and (if PKCE is adopted) `code_verifier` per Section 5.3.5. Under Option B the auth library owns state storage and the table is not created. Under the Section 5.3 recommendation, and only if Option A is approved, `sessions` gains `last_seen_at` and `rotated_at` (and optionally `absolute_expires_at`) in the Phase 1 migration, not as a later alteration.

**Security requirements:**

- State is random, single-use, bound to a short-lived cookie or row, and validated on callback.
- The token exchange uses the client secret only on the server.
- Session cookies are HTTP-only, Secure, SameSite, scoped, and bounded.
- Only a hash of the session token is stored. Comparison is constant-time.
- Session fixation is prevented by creating a new session after callback and rotating on privilege change.
- Redirect targets are allowlisted. No open redirect.
- Roles come from `user_roles` on every request. Client role claims are ignored.
- Login, callback, logout, and session endpoints are rate-limited.

**Unit tests:** State generation and comparison, cookie serialization, session expiry and idle checks, permission resolution, CSRF token verification, redirect allowlist.

**Integration tests:** Full login round trip with a mock Discord; missing state rejected; mismatched state rejected; replayed callback rejected; expired session rejected; logout revokes immediately; logout-all revokes every session; non-admin denied on an admin route; a forged role header changes nothing.

**Acceptance criteria:** A user can log in and out. A stale or forged state fails. A revoked session is rejected on the next request. Admin access requires the database role. An audit row exists for each authentication event.

**Risks and blockers:** Discord API or scope changes. Redirect URI misconfiguration between environments. Clock skew. Session cookie loss in a cross-site deployment. Custom auth has a larger security test burden than Supabase Auth.

---

### 8.5 Phase 3 - User accounts, dashboard, and catalog foundation

**Objective:** Deliver account self-service, the dashboard shell, and the catalog that key access will later authorize.

**Prerequisites:** Phase 2.

**Deliverables:**

- Profile read and update with only display fields writable.
- Soft account deletion request.
- Game and script storage, versioning, publishing, unpublishing, enable, disable, and soft delete.
- Public catalog reads that return only published, enabled, non-deleted scripts.
- Opaque `public_id` generation and server-side resolution.
- Script content or storage reference handling with short-lived signed URLs.
- Access-log writes for granted, denied, and not-found reads.
- User dashboard shell with profile, catalog, and placeholder sections for keys, subscriptions, and transactions.
- Admin catalog endpoints with authorization and audit, wired before the full admin UI.

**Planned files and modules:** `src/modules/users/*`, `src/modules/catalog/*`, `src/providers/storage/*`, `app/(public)/*`, `app/(dashboard)/*`, `src/validators/users.ts`, `src/validators/catalog.ts`, `tests/integration/catalog/*`.

**API endpoints:** Section 9.2 profile routes (`GET /api/users/me`, `PATCH /api/users/me`, `DELETE /api/users/me`); Section 9.3 scripts routes; Section 9.4 games routes. Key and subscription subroutes arrive with their domains. Free-key claiming is deferred until offers exist.

**Database changes:** `games`, `scripts`, `script_versions`, `script_access_logs`, plus user profile indexes. No key or ban tables are used yet.

**Security requirements:**

- `discord_id` and roles are never user-writable.
- Public reads use `public_id`, never internal UUIDs.
- Only `status = 'published'`, `enabled = true`, and `deleted_at IS NULL` content is returned.
- One generic error shape for missing and unauthorized content.
- Admin catalog writes require the correct role and write an audit row.
- Script content is rendered as text, never injected as HTML. If HTML rendering is ever required, it goes through a sanitizer.
- Storage URLs are short-lived and scoped.

**Unit tests:** Public ID generation, slug validation, version monotonicity, publish state rules, content reference validation, safe rendering helper.

**Integration tests:** Draft and disabled scripts are not public; soft-deleted scripts are invisible; an unauthorized admin route is denied; every public read writes an access log; version history is immutable; enumeration returns a uniform error.

**Acceptance criteria:** A user can view and edit their profile. The public catalog shows only eligible scripts. Admin catalog operations are authorized and audited. Evidence and internal IDs are not leaked.

**Risks and blockers:** Catalog scope creep. Content storage decisions may change the retrieval path. Large script bodies may hit the 4.5 MB payload limit, so storage references are preferred.

### 8.6 Phase 4 - Key lifecycle and validation

**Objective:** Implement ownership, activation, device binding, sessions, validation, reset, and admin key controls.

**Prerequisites:** Phase 3 and decision D5.

**Deliverables:**

- Key generation with cryptographically secure values, hashed storage, and a one-time plaintext response.
- Activation that claims an unused key, plus the suspended-key branch guarded by an unused `key_reactivations` authorization. The authorization endpoint arrives in Phase 5, so Phase 4 tests seed the authorization row directly.
- Validation with the nine-step server-side flow and a short-lived grant.
- Single active key session per key, with supersession and revocation.
- HWID normalization, keyed hashing, comparison, and reset with cooldown and cap.
- Owner key list, usage, and device history.
- Admin key list, revoke, reset, and device history.
- Access orchestration between key validity and script eligibility.
- Terminal status gates for `banned` and `suspended`, even though ban endpoints arrive in Phase 5. Tests may set these states directly.

**Planned files and modules:** `src/modules/keys/*`, `src/modules/access/*`, `src/core/crypto/hwid.ts`, `src/validators/keys.ts`, `tests/integration/keys/*`, `tests/concurrency/activation.test.ts`.

**API endpoints:** `POST /api/keys/activate`, `POST /api/keys/validate`, `POST /api/keys/reset-hwid`, `GET /api/keys/me`, `GET /api/keys/{id}/usage`, `GET /api/keys/{id}/devices`, `POST /api/admin/keys`, `GET /api/admin/keys`, `POST /api/admin/keys/{id}/revoke`, `POST /api/admin/keys/{id}/reset-hwid`, `GET /api/admin/keys/{id}/devices`. `POST /api/keys/claim` is deferred to the offers phase.

**Database changes:** `keys`, `key_sessions`, `key_device_history`, `key_hwid_resets`, plus key indexes and the single-session partial unique index. Activation updates `script_access_logs` and `audit_logs`.

**Security requirements:**

- Ownership always comes from the session. A client-supplied Discord ID is ignored.
- Terminal status is evaluated first: `banned`, then `revoked`, then `suspended`, then anything not `active`.
- HWID is normalized, HMAC-hashed with a server secret, never logged in full, and never returned.
- Activation and reset require `Idempotency-Key` where specified and are rate-limited.
- Activation locks the key row and creates the session in one transaction.
- A new activation supersedes the old session. A revoked session fails on the next request.
- Errors are generic externally and detailed only in audit logs.
- Admin key routes require the correct role and write audit rows.

**Unit tests:** Key formatting and entropy checks, HWID normalization and hashing, status precedence, expiry logic, reset cooldown and cap, error mapping, idempotency key validation.

**Integration tests:** Activation of an unused key; rejection of an already-owned key; validation with a valid session; validation with an expired or revoked session; HWID mismatch; reset cooldown and cap; admin revoke drops the session; a banned key fails activation, validation, and reset; a suspended key without an unused authorization fails activation; a suspended key with an authorization consumes it; a proposal-like state does not block; concurrent activation creates one session.

**Acceptance criteria:** The full key lifecycle works against a real database. Two parallel activations cannot both succeed. A banned key cannot perform any key operation. No response contains a raw HWID or a plaintext key after creation.

**Risks and blockers:** HWID trust varies by platform. Row locks can increase contention. Idempotency and rate-limit stores must exist before these endpoints are exposed. The 30 minute key session lifetime must be acceptable for the retrieval flow.

### 8.7 Phase 5 - Ban, reversal, and reactivation workflows

**Objective:** Implement the permanent ban lifecycle, owner reversal requests, admin review, and separate reactivation authorization.

**Prerequisites:** Phase 4 and decisions D12, D13, D14.

**Deliverables:**

- Immediate ban apply and ban proposal creation with evidence rows and server-derived confidence.
- Proposal review with confirm and reject decisions.
- Ban and proposal listing and detail with field-projected evidence.
- Owner reversal create, list, and cancel routes with ownership checks.
- Admin reversal queue, detail, approve, and reject routes.
- Separate admin reactivation authorization.
- Activation consumption of an unused authorization in the same transaction as device binding.
- Automatic ban rule evaluation from server-observed signals, with a recorded rule-set version.
- Audit rows for every transition using the Section 8 names.

**Planned files and modules:** `src/modules/trust-safety/bans/*`, `src/modules/trust-safety/reversals/*`, `src/modules/trust-safety/reactivations/*`, `src/modules/trust-safety/automation/*`, `src/validators/ban.ts`, `src/validators/reversal.ts`, `tests/integration/trust-safety/*`, `tests/concurrency/decisions.test.ts`.

**API endpoints:** `POST /api/admin/keys/{id}/bans`, `POST /api/admin/keys/{id}/ban-proposals`, `GET /api/admin/keys/{id}/bans`, `GET /api/admin/keys/{id}/bans/{banId}`, `POST /api/admin/keys/{id}/bans/{banId}/review`, `POST /api/keys/{id}/bans/{banId}/reversal-requests`, `GET /api/keys/{id}/bans/{banId}/reversal-requests`, `POST /api/keys/{id}/bans/{banId}/reversal-requests/{requestId}/cancel`, `GET /api/admin/ban-reversal-requests`, `GET /api/admin/ban-reversal-requests/{requestId}`, `POST /api/admin/ban-reversal-requests/{requestId}/approve`, `POST /api/admin/ban-reversal-requests/{requestId}/reject`, `POST /api/admin/keys/{id}/reactivation-authorizations`.

**Database changes:** `key_bans`, `key_ban_evidence`, `key_ban_reversals`, `key_reactivations`, ban mirror columns on `keys`, device history events, audit indexes. If D13 approves it, add a nullable cancellation reason column.

**Security requirements:**

- `key.ban`, `key.ban.review`, `key.ban.read`, `key.ban.reversal.approve`, `key.ban.reversal.reject`, and `key.reactivation` are admin-only and mapped per route.
- Owner reversal routes require key ownership and `requested_by` from the session. No admin permission is required or granted.
- Approval requires `decided_by <> requested_by`, enforced in the service and by the database CHECK.
- Approval sets `suspended`, never `active`, and creates no reactivation row.
- Reactivation authorization is a separate action with a reason and the `key.ban_reactivation_authorized` event.
- Activation consumes the authorization with a conditional update and writes `key.ban_reactivation_consumed`.
- Evidence is never returned to owners. Reversal request reads carry workflow fields only.
- Every evidence-bearing admin read writes `key.ban_evidence_viewed`.
- All decision routes fail closed on a missing permission and use the lock order from Section 8.
- Automation can propose or confirm only from server-observed evidence and can never reverse a ban.

**Unit tests:** Status transition table, confidence derivation rules, self-approval check, permission mapping, evidence projection, audit event selection, rule-set version recording.

**Integration tests:** All negative cases in Section 10 of this plan, plus: a proposal does not block; a rejected proposal does not ban; approval of a reversal yields `suspended` with no authorization; reactivation authorization does not activate; activation without authorization fails; activation consumes once; a second unused authorization is rejected; a cancelled request leaves the ban confirmed; a requester cannot decide their own request.

**Acceptance criteria:** Every transition in the Section 9 outcome contract is covered by a test. No path moves a banned key directly to active. Every decision and authorization writes the documented audit event. Concurrent decisions resolve to one terminal state.

**Risks and blockers:** The state machine is the highest-complexity area in the project. Automation can create false positives if thresholds are weak. The review queue can stall without a TTL. Evidence storage and projection must be designed before the admin UI is built.

---

### 8.8 Phase 6 - Subscription and payment integration

**Objective:** Add paid plans, checkout, verified payment callbacks, subscription lifecycle, and transaction history.

**Prerequisites:** Phase 4 and decisions D3 and D9. **D3 is UNAPPROVED and the payment adapter is BLOCKED.** Section 5.4.9 records the owner's selection procedure: Midtrans and Duitku are both candidates pending written, product-specific eligibility approval, and no adapter code may be written until the eight-item checklist in that subsection is satisfied for the selected provider. A rejected onboarding after the adapter is built strands the work.

**Deliverables:**

- Plan listing and seeded monthly, 3-month, and 6-month plans.
- Checkout intent that creates a pending transaction with a server-calculated amount.
- One payment adapter implementing `PaymentVerifier` for the selected provider.
- Webhook verification, event persistence, idempotency, and transaction completion.
- Subscription creation, extension, expiry, and renewal.
- User and admin transaction views.
- Reconciliation job for pending transactions.
- Expiry job for subscriptions and linked keys.

**Planned files and modules:** `src/modules/billing/*`, `src/providers/payments/*`, `src/jobs/reconcile-payments.ts`, `src/jobs/expire-subscriptions.ts`, `src/validators/billing.ts`, `tests/integration/billing/*`.

**API endpoints:** `GET /api/subscriptions/plans`, `GET /api/subscriptions/me`, `POST /api/subscriptions/checkout`, `POST /api/subscriptions/renew`, `GET /api/admin/subscriptions`, `PATCH /api/admin/subscriptions/{id}`, `GET /api/transactions/me`, `GET /api/transactions/{id}`, `GET /api/admin/transactions`, `POST /api/webhooks/payments/{provider}`.

**Database changes:** `plans`, `subscriptions`, `transactions`, `payment_events`, plus key and subscription expiry indexes. Seed plans in a migration or a controlled seed step.

**Security requirements:**

- The webhook verifies the signature against the raw request body before parsing.
- `(provider, provider_event_id)` is unique. A replay returns a successful acknowledgment without granting anything.
- Prices and durations come from the database, never from the client.
- The transaction is marked paid and the entitlement is granted in one transaction.
- A browser redirect is never proof of payment.
- Provider secrets are server-only.
- Admin subscription changes are audited.
- Expiry and reconciliation jobs are protected by `CRON_SECRET` and are idempotent.

**Unit tests:** Amount calculation, plan duration, signature verification with fixed vectors, event deduplication, status transitions, expiry boundary.

**Integration tests:** Valid webhook grants once; replayed webhook grants nothing; invalid signature is rejected; stale timestamp is rejected; amount mismatch is rejected; client-supplied price is ignored; expiry job moves an expired subscription and key to the correct state; reconciliation repairs a missed webhook; admin adjustment is audited.

**Acceptance criteria:** A signed callback creates exactly one entitlement. A replay does nothing. An unsigned or malformed callback grants nothing. A subscription expiry is reflected in key validation.

**Risks and blockers:** Provider fees, taxes, and payout eligibility. Section 5.4 documents that Midtrans applies an unpublished rate to "gaming and digital product" merchants, that Duitku's refund support differs between its Direct and SNAP APIs, and that **both retained candidates can refuse the product category**. **If both refuse, or if neither returns a definite written position, no payment adapter is built and this phase cannot proceed on payment integration** (Section 5.4.9, Q20). Webhook retries and ordering. Currency handling. Refund and dispute policy is not specified and needs an owner decision before launch (Section 5.4.10, Q17). Manual renewal avoids automatic recurring charges but does **not** remove refund, duplicate-payment, chargeback, fraud, or consumer-protection duties. No provider may be assumed approved until D3 is decided.

### 8.9 Phase 7 - Free-key offer verification

**Objective:** Implement offer start, signed provider callbacks, completion records, and free-key issuance.

**Prerequisites:** Phase 4 and verified provider callback formats.

**Deliverables:**

- Active offer listing.
- Offer start that creates a user-bound intent and returns the provider URL.
- work.ink and LootLabs adapters with signature and timestamp verification.
- Completion records with provider event uniqueness.
- Free-key issuance linked to the completion.
- `POST /api/keys/claim` for an eligible completion.
- User offer history and admin offer management.
- Replay and fraud controls.

**Planned files and modules:** `src/modules/offers/*`, `src/providers/offers/workink.ts`, `src/providers/offers/lootlabs.ts`, `src/jobs/expire-offer-intents.ts`, `src/validators/offers.ts`, `tests/integration/offers/*`.

**API endpoints:** `GET /api/offers`, `POST /api/offers/start`, `POST /api/webhooks/offers/{provider}`, `GET /api/offers/me`, `GET /api/admin/offers`, `POST /api/keys/claim`.

**Database changes:** `offers`, `offer_completions`, unique `(provider, provider_event_id)`, intent expiry index, foreign key from a completion to the issued key.

**Security requirements:**

- The callback signature is verified on the raw body.
- The timestamp must fall inside the tolerance window.
- The intent is bound to the user at start. A user ID in a query string is never trusted.
- One verified event issues at most one key.
- A browser redirect grants nothing.
- Offer start and claim are rate-limited per user and IP.
- Free-key eligibility and caps follow decision D4.
- Provider adapters never expose secrets to the browser.

**Unit tests:** Signature vectors, timestamp tolerance, intent expiry, eligibility rules, one-reward logic, claim authorization.

**Integration tests:** Valid callback issues one key; replay issues none; invalid signature issues none; stale callback issues none; a callback for another user's intent fails; redirect-only completion fails; claim by a non-owner fails; the issued key is immediately activatable.

**Acceptance criteria:** Only a verified server callback produces a free key. The key is bound to the correct user. Replays and redirects produce nothing. Offers can be disabled without breaking existing completions.

**Risks and blockers:** Provider documentation and signing schemes can change. Offer fraud and VPN abuse are external risks. Provider downtime delays rewards. The provider may not support a test sandbox.

### 8.10 Phase 8 - Admin dashboard and permission enforcement

**Objective:** Complete the admin surface, enforce the full permission matrix, and expose audit and settings operations.

**Prerequisites:** Phases 3 to 7.

**Deliverables:**

- Admin overview statistics.
- User list, search, status change, and role assignment.
- Full admin UI for games, scripts, keys, bans, reversals, reactivations, subscriptions, offers, transactions, announcements, changelogs, audit logs, and settings.
- Permission matrix enforcement for every route.
- Role assignment with audit and self-escalation protection.
- Audit log query by actor, action, target, and date.
- System settings read and update with audit.
- Field projection for evidence and sensitive records.

**Planned files and modules:** `src/modules/admin/*`, `app/admin/*`, `src/validators/admin.ts`, `tests/e2e/admin/*`, `tests/integration/admin/permissions.test.ts`.

**API endpoints:** Section 9.9 admin operations, plus wiring for every previously implemented admin route. `GET /api/config/public` and `GET /api/health` remain public.

**Database changes:** `announcements`, `changelogs`, `system_settings`, and audit query indexes. Role changes write `user_roles` and audit rows.

**Security requirements:**

- Only `admin` holds `key.ban`, `key.ban.read`, `key.ban.review`, `key.ban.reversal.approve`, `key.ban.reversal.reject`, and `key.reactivation`.
- `moderator` holds none of those permissions.
- Ordinary users hold none of them.
- Every privileged request reloads roles from `user_roles`.
- A request cannot grant itself a role or permission.
- Self-role-change and last-admin removal are blocked or require a separate controlled procedure.
- Every mutation writes an audit row with actor, target, and metadata.
- Evidence reads are projected and audited.
- Unknown admin routes fail closed.

**Unit tests:** Permission matrix lookup, moderator denial, self-escalation rejection, field projection, audit metadata shaping, settings validation.

**Integration tests:** Every matrix cell behaves as specified; a moderator is denied every ban and reactivation route; a user is denied every admin route; a forged role in the body is ignored; every mutation creates an audit row; evidence is absent from user responses; audit queries filter correctly; last-admin removal is blocked.

**Acceptance criteria:** The matrix and the route guards agree. No admin mutation lacks an audit row. No user or moderator can read evidence. The admin UI cannot bypass server authorization.

**Risks and blockers:** UI and backend permission drift. Missing audit coverage on a new route. Overly broad moderator access. Large audit tables slow queries without indexes or retention.

### 8.11 Phase 9 - Security hardening and automated testing

**Objective:** Prove the security controls and invariants with automated tests, reviews, and targeted exercises.

**Prerequisites:** Phases 1 to 8.

**Deliverables:**

- Complete negative test suite for authentication, authorization, keys, bans, reversals, reactivation, payments, and offers.
- Concurrency suite for activation, reversal decisions, reactivation consumption, and ban versus validation.
- API contract tests generated from OpenAPI.
- Database constraint tests for every CHECK and partial unique index.
- Dependency audit, secret scan, static analysis, and license review.
- CSRF, CSP, cookie, and security header review.
- Rate-limit load test.
- SQL injection review of every repository.
- Backup restore rehearsal.
- Incident response runbook and security findings report.

**Planned files and modules:** `tests/security/*`, `tests/contract/*`, `tests/concurrency/*`, `docs/security-review.md`, `docs/runbook.md`, CI security jobs.

**API endpoints:** None added. The phase tests existing routes.

**Database changes:** Index and retention adjustments only if measurements require them. No behavior change without a finding and review.

**Security requirements:**

- No critical or high finding remains open.
- Every FINAL invariant has a passing automated test.
- Secrets are absent from source, logs, and client bundles.
- Cookies are HTTP-only, Secure, and SameSite.
- CSRF protection is active on cookie-authenticated mutations.
- Error responses do not leak existence, stack traces, or internal IDs.
- Rate limits work across instances.
- The service role never reaches the browser.
- Evidence access is field-projected and audited.

**Unit tests:** The full existing unit suite, plus regression tests for every fixed finding.

**Integration tests:** The full negative suite, plus parallel activation, parallel approval and cancellation, duplicate authorization consumption, ban versus validation race, webhook replay, and offer replay.

**Acceptance criteria:** The suite passes in CI. No critical or high finding is open. A restore from backup is verified. The runbook covers secret rotation, provider outage, ban mistake, and data incident.

**Risks and blockers:** Tests can create false confidence if they only cover happy paths. Concurrency tests can be flaky without deterministic barriers. Security review time is often underestimated.

### 8.12 Phase 10 - Staging, deployment, and production readiness

**Objective:** Deploy to a production-like environment, verify operations, and release with a rollback path.

**Prerequisites:** Phase 9.

**Deliverables:**

- Staging Supabase project and Vercel preview or staging deployment.
- Separate production, preview, and development environment variables.
- Controlled migration procedure and rehearsal on a production-like database.
- Smoke suite for auth, catalog, activation, validation, ban, reversal, reactivation, payment, and offer callbacks.
- Monitoring dashboards, alert thresholds, and on-call ownership.
- Backup schedule, retention, and a tested restore.
- Rollback and forward-fix procedure.
- Launch checklist and post-launch review.

**Planned files and modules:** `docs/deployment.md`, `docs/runbook.md`, `tests/e2e/smoke/*`, CI deploy workflow, monitoring configuration.

**API endpoints:** `GET /api/health` and `GET /api/config/public` are the primary probes.

**Database changes:** Apply the reviewed migration set. No unreviewed production DDL.

**Security requirements:**

- Production secrets are set per environment and never shared with preview.
- Preview data is isolated from production.
- Admin access is limited and audited.
- Health and error alerts have an owner.
- Backups are encrypted and access-controlled.
- The restore procedure is executed, not just documented.

**Unit tests:** Not applicable beyond the existing suite.

**Integration tests:** Staging smoke suite, migration rehearsal, restore rehearsal, and a load check on public catalog and key validation endpoints.

**Acceptance criteria:** Production deploys from the main branch. Health passes. Smoke tests pass. A restore is verified. Alerts reach an owner. Rollback is documented and tested. The function list is correct.

**Risks and blockers:** Platform plan limits, usage-based overage, single-region latency if the plan is not configured for multiple regions, short log retention, provider outages, and a failed migration. A production incident without a runbook is the highest operational risk.

---

## 9. Security Review

This review follows `BACKEND.md` Section 11 and the FINAL rules in Sections 6, 8, 9, and 10. It is a plan for controls and tests, not a claim that any control is implemented.

### 9.1 Trust boundaries

| Boundary | Trusted | Never trusted |
|---|---|---|
| Browser to API | Nothing beyond the request itself | Roles, user IDs, Discord IDs, permissions, HWID values, prices, confidence values, ownership claims |
| API to database | Server-side service role and parameterized SQL | Client-supplied query fragments or identifiers used as SQL |
| API to Discord | Discord token exchange and `/users/@me` response | Discord tokens as the application session |
| Provider to API | Signature-verified payment and offer callbacks | Redirect parameters, client-declared completion, unsigned payloads |
| Admin UI to API | The server-side session after a role reload | UI visibility as authorization |
| Game server to API | A signed per-place request with timestamp and nonce | A LocalScript request or a client-declared Roblox UserId |

### 9.2 Authentication and session controls

| Control | Requirement | Verification |
|---|---|---|
| OAuth state | Random, single-use, short-lived, bound to the initiating browser or row | State mismatch, reuse, and missing-state tests |
| Redirect URI | Exact allowlist per environment | Negative test with an unlisted URI |
| Token exchange | Server-side only, client secret never exposed | Bundle and response inspection |
| Session token | 256-bit CSPRNG, opaque, stored only as a hash | Database inspection and unit test |
| Cookie | HTTP-only, Secure, SameSite, scoped, bounded `Max-Age` | Response header test |
| Comparison | Constant-time hash comparison | Code review and unit test |
| Expiry | Seven day absolute plus an idle window | Boundary and clock tests |
| Rotation | New token on privilege change and after a fixed interval | Integration test |
| Fixation | New session created after callback, old value invalidated | Login flow test |
| Revocation | Server-side row deletion or `revoked_at`, effective immediately | Post-revoke request test |
| Logout-all | Revokes every session for the user | Multi-session test |
| CSRF | SameSite plus a CSRF token or double-submit check on cookie-authenticated mutations | Cross-origin form and fetch tests |
| Open redirect | No arbitrary return URL. Allowlisted internal paths only | Negative test |

PKCE is recommended as defense in depth even for a confidential server-side client. It is not required by the current specification and does not change the documented flow.

### 9.3 Authorization

- The Discord user ID is the immutable identity anchor. Username, display name, and discriminator changes never change identity, and `discord_id` is never user-writable.
- Every privileged route resolves the actor from the session and reloads roles from `user_roles`.
- Permissions are a static map. Holding one permission never implies another.
- Owner routes authorize by resource ownership, not by an administrative permission.
- Admin routes require the mapped permission before reading or writing any domain row.
- Unknown routes fail closed. A missing mapping is a denial, not an admin default.
- A request body that contains `role`, `permissions`, `discord_id`, `requested_by`, or `owner_discord_id` cannot influence authorization. Ignore or reject such fields.
- Admin UI visibility is not a security control. The server enforces every action independently.
- Role assignment is itself privileged and audited. Self-escalation and last-admin removal are blocked.
- `moderator` receives none of the six ban and reactivation permissions. This is verified per route, not just in the UI.

### 9.4 Key, HWID, and session controls

- The owner identity is `owner_discord_id`, set from the session at activation and immutable afterward.
- `banned` is evaluated first, then `revoked`, then `suspended`, then any non-`active` state.
- A proposal never changes key status and never revokes a session.
- A confirmed ban revokes sessions in the same transaction that sets the status.
- Validation requires account session plus key session. A key token is bound to one key and one user.
- One active key session per key is enforced by a partial unique index, not only by application code.
- Activation locks the key row. A new activation supersedes the previous session.
- HWID is normalized, keyed-hashed with a server-only secret, compared in constant time, and never stored raw.
- Raw HWID is never logged, returned, or shown to admins. Only a short non-reversible fingerprint is displayed.
- An HWID mismatch is a denial and an anomaly signal, never proof of sharing by itself.
- Reset has a cooldown and a cap, revokes the current session, is rate-limited, and is audited.
- A banned key cannot activate, validate, reset, or hold a session.
- A suspended key from a reversed ban requires an unused `key_reactivations` row.
- The reactivation consume is a conditional update inside the activation transaction, so double consumption is impossible.

### 9.5 Ban, reversal, and reactivation invariants

| Invariant | Enforcement | Required test |
|---|---|---|
| A proposal is not a ban | Separate `review_status`, no key status change | Proposal leaves validation working |
| A confirmed ban is terminal for normal use | `keys.status = 'banned'`, status checked first | Banned key fails activate, validate, reset |
| Evidence requires `key.ban.read` | Field projection and route guard | User, moderator, and owner denied |
| Evidence access is audited | `key.ban_evidence_viewed` on every evidence read | Audit row exists |
| Only the owner can request reversal | Session ownership plus ban-belongs-to-key check | Non-owner gets not found or not owner |
| Only one open request per ban | Partial unique index | Second create returns `reversal_pending` |
| Requester cannot decide their own request | Service check plus database CHECK | `self_approval_forbidden` |
| Approval ends at `suspended` | Approval transaction sets `suspended` | Key is not active and has no authorization |
| Approval does not authorize reactivation | No `key_reactivations` insert in approval | Authorization count remains zero |
| Rejection and cancellation keep enforcement | No key or ban transition | Key remains banned |
| Reactivation needs a separate admin action | `key.reactivation` plus a reason | Missing permission denied |
| Reactivation authorization does not activate | Status unchanged | Key remains suspended |
| Activation consumes exactly once | Conditional update on `consumed_at IS NULL` | Parallel activation yields one success |
| A consumed authorization cannot be reused | Same conditional update | Second activation denied |
| No direct banned-to-active path | State machine and tests | Every route rejects the shortcut |
| Automation cannot reverse a ban | No reverse code path in automation | Review and test |

### 9.6 Payment and offer security

- Webhook signatures are verified against the raw body before JSON parsing.
- Signature comparison is constant-time.
- Event IDs are unique per provider. Replays are acknowledged without side effects.
- Payment amount, currency, and plan are derived from the database, never from the client.
- A payment grants exactly one entitlement inside one transaction.
- A reconciliation job repairs missed callbacks but never double-grants.
- Offer callbacks are signature-verified, timestamp-bounded, and bound to an intent created at offer start.
- A browser redirect is never proof of completion.
- One offer event issues at most one free key.
- Provider secrets are server-only and are never sent to the browser.
- Provider APIs are called only at allowlisted hosts. No user-supplied URL is fetched.

### 9.7 Input, output, and data access

- Zod validates every body, query parameter, and path parameter. Unknown fields are stripped or rejected.
- Body size is capped below the 4.5 MB platform limit. Array lengths and pagination are capped.
- Content type is checked. Unexpected content types are rejected.
- SQL is parameterized. Dynamic identifiers use a fixed allowlist, never string interpolation.
- No raw SQL is built from a user string.
- Error responses use one shape and never include stack traces, SQL, internal IDs, or provider details.
- Logs redact tokens, cookies, keys, HWID, secrets, and personal data.
- React escapes output by default. `dangerouslySetInnerHTML` is prohibited for user or admin content unless it passes a reviewed sanitizer.
- A content security policy restricts scripts and frames. Inline script is avoided.
- Script content is delivered as text or a signed storage reference, never as executable HTML in the dashboard.
- File uploads, if added for images, validate MIME type, size, and extension, and are stored outside executable paths.
- Enumeration is limited by opaque public IDs and uniform not-found responses.

### 9.8 Rate limiting and abuse

- A shared store is mandatory because serverless instances do not share memory.
- Limits are keyed by IP, user, key, and route class, with stricter limits on login, activation, validation, reset, reversal create, checkout, and webhooks.
- A rate limit is checked before expensive database work where possible.
- `Idempotency-Key` is required on the state-changing routes named in Section 9.
- Idempotency records are scoped to actor and route, store a request hash, and expire.
- Webhook rate limits do not replace signature verification.
- Denials are logged without leaking whether a key exists.

### 9.9 Secret management and operations

- Secrets live in Vercel environment variables per environment. No secret is committed.
- The service role key, database URL, Discord secret, session secret, HWID secret, payment secret, offer secrets, and cron secret are server-only.
- Secrets are rotated on a documented schedule and immediately after suspected exposure.
- Preview deployments do not receive production secrets.
- Logs and error trackers are configured not to capture request bodies or headers on sensitive routes.
- Backups are encrypted and access-controlled. Restore access is limited and audited.

### 9.10 Audit and evidence

- Every sensitive mutation writes an `audit_logs` row with actor, action, target, timestamp, and metadata.
- Documented ban and reactivation events are used unchanged: `key.ban`, `key.ban_proposed`, `key.ban_applied`, `key.ban_rejected`, `key.ban_denied`, `key.ban_reversal_requested`, `key.ban_reversal`, `key.ban_reversal_rejected`, `key.ban_reversal_cancelled`, `key.ban_reactivation_authorized`, `key.ban_reactivation_consumed`.
- Evidence reads write `key.ban_evidence_viewed` with actor, ban, request ID, and timestamp.
- Audit rows never contain raw HWID, tokens, plaintext keys, or secrets.
- Audit rows are append-only for their lifecycle and survive the records they describe.
- Audit access is itself privileged and read-only.
- Runtime logs are not an audit store. Hobby retains them for one hour and Pro for one day.

### 9.11 Residual risks

| Risk | Why it remains | Mitigation |
|---|---|---|
| HWID spoofing | A determined client can forge a device signal | Treat HWID as a soft signal, combine with account and session checks, log anomalies |
| Account sharing | A shared Discord account defeats owner binding | Rate limits, anomaly detection, admin review, terms enforcement |
| Single region | Hobby runs in one region; Pro can use multiple regions | Accept latency or configure multiple regions, keep queries indexed, monitor duration |
| Short log retention | Hobby keeps one hour and Pro one day | Durable audit and access tables, external error tracking if approved |
| Service role compromise | The server has broad database access | Strict server-only handling, least-privilege deployment, secret rotation, review |
| Malicious admin | An admin can read evidence and ban keys | Separation of duties, self-approval block, audit trail, least-privilege roles |
| Provider outage | Discord, Supabase, payment, or offers can fail | Clear errors, retries, reconciliation, status page, incident runbook |
| Dependency compromise | Third-party packages can be malicious | Lockfile, audit, minimal dependencies, review of new packages |
| Denial of service | Public endpoints are reachable | Rate limits, body caps, timeouts, Vercel edge protection |
| Test false confidence | Passing tests do not prove production safety | Negative tests, concurrency tests, restore rehearsal, manual review |

### 9.12 Security release gates

1. No critical or high finding open.
2. Every FINAL invariant has an automated test.
3. Every admin route has a permission mapping and an audit assertion.
4. Every secret is server-only and absent from the client bundle.
5. Every webhook has a signature, timestamp, and replay test.
6. Every ban and reactivation transition has a negative test.
7. A backup restore has been performed successfully.
8. The incident runbook names an owner and a contact path.

---

## 10. Testing Strategy

### 10.1 Principles

- Test behavior and invariants, not implementation details.
- Every security decision has a negative test.
- Every state transition has a test for the allowed path and for each denied path.
- Concurrency rules are tested with real parallel requests against a real Postgres, not mocked.
- External providers are mocked at the HTTP boundary with fixed signature vectors and replay fixtures.
- A passing suite is evidence of tested behavior, not proof of production safety.

### 10.2 Test layers

| Layer | Tool | Scope | Speed |
|---|---|---|---|
| Unit | Vitest | Pure functions, validators, state transitions, permission lookup, hashing | Fast |
| Integration | Vitest plus test Postgres | Route handlers, repositories, transactions, constraints | Moderate |
| Contract | Vitest plus OpenAPI | Request and response shapes, error codes, permission labels | Moderate |
| Database constraint | SQL harness | CHECKs, FKs, partial unique indexes, RLS | Moderate |
| Concurrency | Vitest with parallel clients | Locks, conditional updates, races | Slow |
| Security | Vitest plus targeted scripts | Auth, authz, replay, injection, leakage | Moderate |
| End-to-end | Playwright | Login, dashboard, key activation, ban review, reversal, reactivation | Slow |
| Operational | Scripts and staging | Migrations, restore, smoke, load | Manual or scheduled |

### 10.3 Unit tests

- Environment parsing fails on a missing or malformed secret.
- Error mapping never leaks an internal reason.
- Key generation has sufficient entropy and a stable format.
- HWID normalization is deterministic and versioned.
- Status precedence returns `banned` before `revoked`, `suspended`, and expired.
- Permission resolution returns exactly the mapped permission and no implied one.
- Reversal state transition table rejects every invalid transition.
- Confidence derivation accepts only server-observed signals.
- Signature verifiers accept a valid vector and reject a modified body.
- Offer intent expiry and eligibility rules work at the boundary.
- Amount and duration calculations use integer minor units.
- Response projection removes evidence fields for non-admin callers.

### 10.4 Integration and API contract tests

- Every Section 9 route returns the documented success shape and error codes.
- List endpoints enforce pagination caps and stable ordering.
- Owner routes return only the owner's rows.
- Admin routes deny a user, a moderator, and an admin missing the specific permission.
- A route with no permission mapping fails closed.
- Idempotent replay returns the stored response and creates no second side effect.
- A different payload with the same idempotency key returns a conflict.
- Session revocation is effective on the next request.
- A revoked key session fails validation even if the account session is valid.
- The public catalog never returns a draft, disabled, or soft-deleted script.
- An error response never contains a stack trace, SQL fragment, or internal UUID.

### 10.5 Database constraint tests

- Each status enum rejects an unknown value.
- The `key_ban_reversals` CHECK rejects a pending row with decision fields set.
- The self-approval CHECK rejects `decided_by = requested_by`.
- The partial unique index rejects a second `pending_approval` row for one ban.
- The partial unique index rejects a second unused reactivation for one key.
- `key_reactivations` rejects `consumed_at < authorized_at`.
- `key_bans` rejects a confirmed or reversed row without `banned_at`.
- `key_bans` rejects a pending row with `banned_at` set.
- A foreign key rejects an orphan reversal, evidence row, or authorization.
- RLS denies anon and authenticated client roles on every table.
- The `keys.status` CHECK makes `banned` mutually exclusive with `active`.

### 10.6 Authentication tests

- Login redirects with a state value and the expected scopes.
- Callback rejects a missing state.
- Callback rejects a mismatched state.
- Callback rejects a replayed state.
- Callback rejects an expired state.
- Callback rejects an unlisted redirect URI.
- A failed token exchange returns a generic error.
- Session cookie flags are correct.
- Session token is absent from logs and responses.
- Session expiry is enforced at the boundary.
- Idle timeout is enforced.
- Logout invalidates only the current session.
- Logout-all invalidates every session.
- Session fixation does not survive login.
- A forged role header or cookie field changes nothing.

### 10.7 Authorization tests

- The full Section 10 matrix is exercised cell by cell.
- `admin` with the exact permission succeeds.
- `admin` missing the permission is denied.
- `moderator` is denied every ban and reactivation route.
- `user` is denied every admin route.
- Owner can submit, list, and cancel only their own request.
- Owner cannot list another owner's request.
- Owner cannot cancel another owner's request.
- Owner cannot cancel a decided or already cancelled request.
- Admin cannot act as the requester for an owner route.
- A client-supplied `requested_by`, `discord_id`, role, or permission is ignored.
- A key that does not belong to the session is denied before ban rows are read.

### 10.8 Payment and offer tests

- A valid payment signature grants exactly once.
- A modified body fails signature verification.
- A replayed payment event grants nothing.
- A stale payment event is rejected.
- A client-supplied amount or plan is ignored.
- A failed payment leaves the transaction pending.
- A reconciliation job grants a missed payment once.
- A valid offer signature issues one key.
- A replayed offer event issues nothing.
- A stale offer callback is rejected.
- A callback for another user's intent does not issue a key.
- A redirect without a callback issues nothing.
- A disabled offer cannot be started.
- A claim without an eligible completion is denied.

### 10.9 Concurrency tests

| Test | Expected result |
|---|---|
| Two activations of the same unused key | Exactly one active session; the loser is denied |
| Two activations that consume the same authorization | Exactly one consume; the loser gets `reactivation_not_authorized` |
| Approval and cancellation of one request | Exactly one terminal state |
| Approval and rejection of one request | Exactly one terminal state |
| Two confirms of one proposal | Exactly one applied ban |
| Ban and validation on the same key | The grant cannot commit past the ban |
| Two review decisions on a reversed ban | The second gets `invalid_transition` |
| Two reactivation authorizations for one key | Exactly one unused row |
| Concurrent idempotent replays | One side effect, identical responses |
| Concurrent cancel and approve | One terminal state, the loser gets a conflict |

Concurrency tests use separate connections, deterministic barriers, and a real Postgres. A test that passes only when run serially is not a concurrency test.

### 10.10 Security tests

- SQL injection strings in every text field do not alter queries.
- Stored script content cannot execute as HTML in the dashboard.
- Error responses do not reveal whether a key, ban, or user exists.
- Evidence is absent from every user and moderator response.
- Evidence reads create audit rows.
- Rate limits trigger before expensive work.
- CSRF protection blocks a cross-origin mutation.
- A session token from one key cannot validate another key.
- A key session cannot be used without the account session where both are required.
- Provider secrets are absent from the client bundle.
- Logs contain no tokens, keys, HWID, or secrets.
- A request with an oversized body is rejected below the platform limit.

### 10.11 Required negative cases

At minimum, the suite must demonstrate all of the following statements:

- A banned key cannot activate.
- An approved reversal does not automatically activate a key.
- An owner cannot authorize their own reactivation.
- Reactivation requires a valid unused authorization.
- An authorization cannot be consumed twice.
- Concurrent activation requests cannot bypass consumption rules.
- Rejected or cancelled reversal requests do not reverse a ban.
- Client-supplied identity and permission data are ignored.

The cases below operationalize those statements.

| Case | Expected result |
|---|---|
| A banned key attempts activation | Denied with a banned key code |
| A banned key attempts validation | Denied before session and expiry checks |
| A banned key attempts HWID reset | Denied |
| An approved reversal attempts to activate without authorization | Denied with `reactivation_not_authorized` |
| An owner tries to create a reactivation authorization | Denied, no admin route access |
| An owner tries to consume an authorization through an admin route | Denied |
| Activation without an unused authorization | Denied |
| Activation after consumption | Denied |
| Two concurrent activations consume one authorization | Exactly one succeeds |
| A rejected reversal is treated as a reversal | Denied, ban remains confirmed |
| A cancelled reversal is treated as a reversal | Denied, ban remains confirmed |
| A requester approves their own request | Denied with `self_approval_forbidden` |
| A second request is created while one is pending | Denied with `reversal_pending` |
| A decision is attempted on a terminal request | Denied with `invalid_transition` |
| A client forges a role, Discord ID, or permission | Ignored, no privilege change |
| A client supplies a confidence value that differs from the server | Denied with `confidence_not_verifiable` |
| A proposal is treated as an applied ban | No effect on validation or sessions |
| A moderator tries a ban review action | Denied |
| An admin missing `key.ban.read` reads evidence | Denied |
| A user reads ban evidence | Denied |

### 10.12 End-to-end journeys

1. User logs in, claims a free key, activates it, validates a script, and sees usage.
2. User resets HWID after cooldown, old session dies, and activation rebinds.
3. Admin proposes a ban, another admin confirms it, and the key is blocked immediately.
4. Owner requests reversal, a different admin approves it, and the key is suspended, not active.
5. Admin authorizes reactivation with a reason, and the owner activates and consumes it.
6. Owner cancels a pending request and the ban remains enforced.
7. Admin rejects a request and the ban remains enforced.
8. User pays through the provider sandbox, the webhook grants a subscription once, and the key validates.
9. User completes an offer in the provider sandbox, the callback issues one key, and a replay issues none.
10. A non-admin cannot reach any admin page or endpoint.

### 10.13 Test data and isolation

- Each integration run uses a dedicated test database or schema, migrated from zero.
- Tests seed only the rows they need and reset with truncation or transaction rollback.
- The clock is injectable so expiry and cooldown boundaries are deterministic.
- Provider mocks use fixed secrets and signed fixtures, never live credentials.
- Concurrency tests do not share a transaction.
- Test fixtures never include real Discord IDs, real keys, or real HWID values.
- Sensitive test data is synthetic and safe to delete.

### 10.14 CI gates

A merge is blocked unless all of these pass:

1. Type check.
2. Lint.
3. Unit tests.
4. Integration tests against a test Postgres.
5. Contract tests and OpenAPI drift check.
6. Database constraint tests.
7. Security regression tests.
8. Build and function-count check.
9. Secret scan and dependency audit.
10. End-to-end smoke on the preview deployment for changes that touch auth, keys, bans, payments, or offers.

### 10.15 Manual and operational testing

- Restore a production-like backup into a clean environment.
- Run a load check on public catalog and key validation.
- Perform an incident drill for a leaked secret and a mistaken ban.
- Review the admin UI against `DESIGN.md` and the AntiSlop delivery gate.
- Verify the deployed function list after configuration changes.
- Confirm that alerts reach a real owner.

---

## 11. Risk Register

Severity reflects impact if the risk occurs. Likelihood reflects the current plan and controls.

### 11.1 Technical risks

| Risk | Severity | Likelihood | Impact | Mitigation | Detection | Module |
|---|---|---|---|---|---|---|
| Reversal state machine accepts an invalid transition | High | Medium | A ban is wrongly reversed or a key state diverges | Single transition table, conditional updates, database CHECKs, exhaustive tests | Integration and property tests | Trust and safety |
| Two activations consume one authorization | High | Low | Unauthorized second device or duplicate audit | Key row lock plus conditional update on `consumed_at IS NULL` | Concurrency test and audit review | Keys |
| Schema drift between code and database | Medium | Medium | Runtime failures or silent data loss | Ordered migrations, review, CI migration check, typed schema | CI drift check and staging migration | DB |
| Extra API functions are created | Medium | Medium | Violates the one-API-function requirement and complicates limits | One catch-all route, no other `route.ts` under `app/api/`, build inspection | Post-deploy function list check | Deployment |
| Missing idempotency store | Medium | Medium | Duplicate bans, reversals, or activations on retry | Durable table with scoped unique key and request hash | Integration replay tests | Core |
| Key session lifetime is too short or too long | Medium | Low | User friction or prolonged stolen-session risk | Configurable constant, idle plus absolute expiry, metrics | User reports and session metrics | Keys |
| Bundle size approaches the 250 MB limit | Low | Low | Build failure or slow cold starts | Lean imports, no large SDKs on the server, bundle check | Build output | Deployment |
| Script content is rendered unsafely | High | Low | Stored XSS in the dashboard | Text-only rendering, sanitizer if HTML is added, CSP | Security test and code review | Catalog |
| Single-region latency | Low | Medium | Slower responses for distant users | Indexed queries, CDN for static content, region choice | Duration metrics | Deployment |

### 11.2 Security risks

| Risk | Severity | Likelihood | Impact | Mitigation | Detection | Module |
|---|---|---|---|---|---|---|
| Service role key leaks to the client | Critical | Low | Full database compromise | Server-only modules, bundle scan, no client import, secret rotation | Secret and bundle scan | Core |
| Evidence leaks to an owner or moderator | High | Medium | Privacy breach and loss of trust | Field projection, permission guard, response tests | Contract tests and audit review | Trust and safety |
| Self-approval bypass | High | Low | A requester lifts their own ban | Service check plus database CHECK | Negative test | Trust and safety |
| Payment webhook forgery | High | Medium | Free entitlement or fraud | Raw-body signature, timestamp, idempotency, reconciliation | Signature and replay tests | Billing |
| Offer callback replay | High | Medium | Unlimited free keys | Unique provider event, intent binding, one reward | Replay test and provider reconciliation | Offers |
| Owner identity spoofing | High | Low | Key theft or unauthorized access | Session-derived identity, immutable owner, ownership checks | Authorization tests | Keys |
| Session theft | High | Low | Account takeover | HTTP-only cookie, hashed token, rotation, short key sessions, revocation | Anomaly review and audit | Auth |
| Privilege escalation through role assignment | High | Low | Full admin compromise | Role assignment guard, self-escalation block, last-admin protection, audit | Authorization tests | Admin |
| Rate limit bypass across instances | Medium | Medium | Brute force or abuse | Shared-store counters, strict route classes | Load test and metrics | Core |
| HWID spoofing | Medium | High | Casual sharing is harder to detect | Soft-signal treatment, anomaly detection, review, single session | Anomaly review | Keys |
| Malicious or compromised admin | High | Low | Evidence misuse or wrongful ban | Separation of duties, audit, least privilege, review | Audit review | Trust and safety |
| Dependency compromise | High | Low | Supply-chain compromise | Minimal dependencies, lockfile, audit, review | Dependency scan | Core |

### 11.3 Operational risks

| Risk | Severity | Likelihood | Impact | Mitigation | Detection | Responsible area |
|---|---|---|---|---|---|---|
| Backup is never restored | High | Medium | Data loss cannot be recovered | Scheduled restore rehearsal, documented procedure | Restore test record | Operations |
| Runtime logs expire before investigation | Medium | High | Incident reconstruction is limited | Durable audit tables, optional error tracking | Audit coverage review | Operations |
| Reversal queue stalls | Medium | Medium | Owners wait indefinitely | TTL and queue-age alert (D12) | Queue age metric | Trust and safety |
| Preview receives production secrets | High | Low | Data exposure or accidental writes | Per-environment secret scoping | Environment audit | Deployment |
| Provider outage | Medium | Medium | Login, payment, or offer failures | Graceful errors, retries, reconciliation, status messaging | Health checks and provider status | Operations |
| Migration failure in production | High | Low | Downtime or data damage | Rehearsal, transaction where possible, rollback plan | Staging migration and backup | DB |
| Secret rotation mishandled | Medium | Low | Lockout or downtime | Rotation runbook and dual-key window | Rotation drill | Operations |
| Single concurrent deployment on the current plan | Low | Medium | Slow release cadence | Controlled deploy windows or a plan with more concurrency | Deployment logs | Deployment |

### 11.4 Third-party risks

| Risk | Severity | Likelihood | Impact | Mitigation | Detection | Responsible area |
|---|---|---|---|---|---|---|
| Discord OAuth change or outage | Medium | Medium | Login unavailable | Clear error state, status page, retry guidance | Login failure rate | Auth |
| Supabase plan or pooler limits | Medium | Medium | Connection failures under load | Pooled connections, one client per instance, query budgets | Connection metrics | DB |
| Payment provider policy or payout change | High | Medium | Revenue interruption | Provider adapter, documented migration path, no deep coupling | Provider notices and reconciliation | Billing |
| Offer provider signing change | Medium | Medium | Free-key issuance breaks | Adapter isolation, signature fixtures, monitoring | Callback failure alert | Offers |
| Vercel plan or limit change | Medium | Low | Deploy, cost, or runtime failure | Re-verify limits at implementation, monitor usage and spend, documented plan fallback | Platform notices, usage alerts, and build checks | Deployment |
| Commercial use on an ineligible plan | High | Low | Account suspension or forced migration | Approve D1a and deploy on Pro before launch; record the commercial-use finding | Plan and terms review | Operations |
| Provider data processing terms | Medium | Low | Compliance issue | Review terms before launch, document data flows | Legal review | Operations |

---

## 12. Production Readiness Checklist

This checklist is not a claim that any item is complete.

### Decisions and scope

- [x] D1 is recorded as FINAL — OWNER APPROVED (Model A).
- [ ] D1a hosting tier is approved and the deployment plan permits commercial use. (D1a is currently **UNAPPROVED — DEFERRED**; deferred closure satisfies planning only and this procurement item stays open.)
- [ ] D2 to D18 are recorded and approved before their owning phases.
- [ ] No executor, anti-cheat, or unauthorized game integration is in scope.
- [ ] Data retention and privacy approach is approved.
- [ ] Payment, tax, refund, and dispute policy is written.

### Build and deployment

- [ ] One API function under `/api` is deployed and listed correctly.
- [ ] No second `route.ts`, `vercel.json` API rewrite, or separate backend deployment exists.
- [ ] The API Route Handler runs on Node.js, not Edge, and Next.js middleware opens no database connection.
- [ ] `/api/health` returns 200 in production.
- [ ] Production, preview, and development variables are separate.
- [ ] The build is under the 250 MB bundle limit.
- [ ] The 4.5 MB body limit is respected by every upload path.
- [ ] The deployment rollback procedure has been tested.

### Security

- [ ] OAuth state, session cookie, CSRF, and redirect allowlist tests pass.
- [ ] Every admin route has a permission mapping and a denial test.
- [ ] The owner, moderator, and admin denial matrix passes.
- [ ] Evidence projection and `key.ban_evidence_viewed` audit pass.
- [ ] Ban, reversal, and reactivation negative cases pass.
- [ ] Webhook signature and replay tests pass for payments and offers.
- [ ] Rate limits are enforced through a shared store.
- [ ] Secrets are absent from the client bundle and logs.
- [ ] Service role access is server-only.
- [ ] Security review has no open critical or high finding.

### Data

- [ ] All migrations apply cleanly from zero.
- [ ] Every CHECK, foreign key, and partial unique index is tested.
- [ ] RLS is enabled with default deny.
- [ ] Backup schedule and retention are configured.
- [ ] A restore has been performed successfully.
- [ ] Audit and access-log retention is configured.

### Testing

- [ ] Unit, integration, contract, and database tests pass in CI.
- [ ] Concurrency tests pass repeatedly, not once.
- [ ] End-to-end journeys pass on staging.
- [ ] Load checks pass for public catalog and key validation.
- [ ] Provider sandbox tests pass for payment and offers.

### Operations

- [ ] Monitoring dashboards and alerts have an owner.
- [ ] The incident runbook covers secret rotation, provider outage, wrongful ban, and data incident.
- [ ] On-call contact and escalation path are defined.
- [ ] Log redaction is verified.
- [ ] Queue age and job failures are monitored.
- [ ] A post-launch review is scheduled.

### Frontend

- [ ] `DESIGN.md` tokens are used with no invented palette or radius.
- [ ] The AntiSlop delivery gate passes.
- [ ] Banned, suspended, expired, revoked, unused, and active key states are visually distinct.
- [ ] Empty, loading, and error states exist on every data page.
- [ ] The admin UI never exposes evidence to a caller who lacks permission.

---

## 13. Unresolved Questions

| ID | Question | Why it matters | Blocks | Recommended default |
|---|---|---|---|---|
| U1 | Model A or Model B? | Determines the entry point and whether a literal `api/index.js` exists | None | **Resolved: D1 FINAL - Model A.** No literal `api/index.js`. |
| U1a | Which hosting provider and plan, and on what commercial terms? | Hobby tiers are non-commercial only; cron, duration, and logs differ by plan. **D1a is UNAPPROVED — DEFERRED**, so no provider is selected. | Procurement, account registration, domain purchase, database subscription, deployment, and production launch. It does not block architecture, schema, or security work | **Deferred by owner (2026-11-10, reaffirmed 2026-11-11).** Budget target IDR 100,000/month all-in. Helipod VPS S Jakarta is an unapproved candidate; Vercel Pro is the retained research baseline. Owner approval required before any purchase |
| U2 | Custom OAuth or Supabase Auth? | Changes session storage, revocation, and audit design | Phase 2 | **Reviewed 2026-11-11 - custom OAuth with a `sessions` table recommended, NOT approved.** Option A remains a recommendation only. D2 is unapproved; Phase 2 cannot start on it. See Section 5.3 |
| U3 | Which payment provider? | Checkout, webhooks, fees, taxes, and payouts depend on it | Phase 6 | **Reviewed 2026-11-11 and updated by owner decision 2026-11-11, UNAPPROVED. Midtrans and Duitku are both candidates with eligibility pending; selection is pending a written, product-specific approval from one of them. The adapter is BLOCKED.** Stripe is unavailable to an Indonesian merchant; Xendit was dropped on its fee structure. See Section 5.4 |
| U4 | Free-key eligibility rules? | Affects abuse controls and offer design | Phase 7 | Offer completion required, plus per-user cap and rate limit |
| U5 | What is the HWID source and normalization? | The hash is meaningless without a stable input | Phase 4 | Per-platform trusted source, versioned canonical string |
| U6 | What may a moderator do? | The permission matrix must match the routes | Phase 8 | No ban, reversal, reactivation, or evidence permissions |
| U7 | What are the retention windows? | Affects storage, partitioning, and privacy | Phase 10 | Define per table before launch |
| U8 | Is there a `pending_approval` TTL? | Prevents an indefinite review queue | Phase 5 | 14 days, configurable, with a cleanup job |
| U9 | Where is a cancellation reason stored? | Owners may need to explain a cancellation | Phase 5 | Add a nullable column, otherwise audit metadata only |
| U10 | Does reactivation apply outside reversal? | `key_reactivations.ban_id` is scoped to a reversed ban | Phase 5 | Keep it scoped. Do not widen without a schema change |
| U11 | Keep `key.ban_reversal` as the approval event? | Renaming touches three sections and every audit query | None | Keep it |
| U12 | What is the idempotency storage design? | Required for replay safety on several routes | Phase 1 | Scoped table with request hash and expiry |
| U13 | What is the rate-limit store? | In-memory counters do not work across instances | Phase 1 | Postgres table, external Redis only if needed |
| U14 | Should reversal request reads emit an audit event? | They carry no evidence, but are sensitive workflow reads | Phase 5 | No evidence event. Log access only if required by policy |
| U15 | What are the Vercel scheduling limits? | The scheduler design depends on current platform terms | Phase 6 | Verified: legacy Cron on Hobby runs at most once per day and Pro once per minute; Schedules beta allows every 15 minutes on Hobby and every minute on Pro. D9 still needs approval. |
| U16 | What are the exact provider callback formats? | Signature and timestamp handling depend on them | Phase 7 | Verify against live provider documentation and sandbox |
| U17 | What are the refund, dispute, and tax rules? | Payment state and entitlement reversal are undefined; refund capability differs per provider and, for Duitku, per API surface | Phase 6 | Write a policy before launch. See Section 5.4.10 (Q17) |
| U18 | What happens to keys and bans on account deletion? | Legal retention and ownership conflict | Phase 10 | Keep audit and ban rows, anonymize display fields |
| U19 | What is the backup RPO and RTO? | Backup frequency and restore testing depend on it | Phase 10 | Daily backup, restore within one business day |
| U20 | What is the Roblox integration scope? | Credentials and per-place authorization must be explicit | Phase 4 | Only owned or authorized experiences, signed server requests |
| U21 | Which currency and rounding rules apply? | Money is stored in minor units but currency is open | Phase 6 | One currency per plan, integer minor units |
| U22 | Should unused reactivation authorizations expire? | An old authorization could be consumed much later | Phase 5 | Add an expiry only if the owner wants time-bounded approval |

### 13.1 Documentation follow-ups

1. Remove or update the stale note at Section 8, `key_ban_reversals`, which says Sections 9 and 10 still describe admin open and cancel with `key.ban.reversal`.
2. Add `key.ban_evidence_viewed` to the Section 8 audit action examples, or state explicitly that the list is non-exhaustive.
3. Add a note that reversal request reads are workflow-only and intentionally do not emit an evidence-view event.
4. Decide whether `pending_approval` needs a documented TTL.
5. Decide whether cancellation needs a stored reason.
6. Decide whether `key_reactivations` needs an expiry column.
7. Record the FINAL Model A entry point in `BACKEND.md` so the deployment model is unambiguous there as well. This requires owner approval to edit a protected file.

These are documentation tasks. They are not performed in this planning deliverable.

---

## Closing Note

This plan is a blueprint. It does not claim that any code, migration, test, or deployment exists. **D1 is FINAL**, so the deployment model no longer blocks Phase 1. **D1a**, session ownership, payment provider, data-access library, idempotency store, and rate-limit store still block a clean Phase 1 start.

Once those decisions are recorded, **Phase 1** should deliver one API function under `/api`, the complete schema with constraints and RLS, and a passing migration test from an empty database. That is the smallest foundation that proves the architecture before any domain workflow is built.

The highest-risk later work is Phase 5. The ban, reversal, and reactivation state machine must be implemented with the documented locks, conditional updates, permissions, and audit events exactly as specified. It should not start until the key lifecycle is stable and tested.

<!-- PLAN-END -->

