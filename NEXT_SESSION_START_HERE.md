# Drengr Recovery Solutions — Session Handoff (2026-07-06)

Read this first, then PROJECT_HANDOFF.md for full history.

## What this repo is
Static site (index.html + privacy.html + terms.html), deploys to Cloudflare Pages
(repo: ecbrown777/drengrrecovery, domain drengrrecoverysolutions.com).
No build step. Output dir = REPO ROOT (files at top level, not in a subfolder).
CRM: GoHighLevel / LeadConnector.

## Done today
- Full-bleed photo backgrounds w/ translucent gray text panels on hero/how/why/serve/celebrate/faq.
- Legal band card swaps (IRS building, courtroom, workspaces, docs).
- All images recompressed; deploy folder ~2.5MB.
- Dual SMS consent checkboxes (marketing + non-marketing), exact carrier language, not pre-checked, optional.
- privacy.html: exact non-sharing clause verbatim. terms.html: all required A2P clauses.
- Single number (949) 449-2708 for voice+SMS across all pages.
- GHL chat widget before </body> on all 3 pages.
- _redirects blocks /worker/* from public download.
- **Cloudflare Worker deployed and verified end-to-end** (see below).

## Worker deployment status — DONE (2026-07-06)
- D1 database `drengr-leads` created (id `c3755621-7fac-448d-be48-5b5557e09d2b`), set in `deploy/worker/wrangler.toml`.
- `schema.sql` applied to the remote DB (leads + sms_consent tables, marketing/non-marketing columns).
- Secrets set on the Worker: `WEB3FORMS_KEY`, `ADMIN_KEY` (random 64-char hex; given to user once at
  set time, not stored in this repo — if lost, rotate with `wrangler secret put ADMIN_KEY`).
- `GHL_WEBHOOK_URL` intentionally NOT set — form does not post to GHL yet (see open item 1 below).
- `wrangler deploy` succeeded; routes live at `www.drengrrecoverysolutions.com/api/*` and
  `drengrrecoverysolutions.com/api/*`.
- Verified with a real POST to `/api/lead`: response `{"ok":true,"lead_id":1}`, row confirmed in
  both `leads` and `sms_consent` tables via `wrangler d1 execute --remote`. This test row
  (lead_id 1, test-dummy@example.com) is intentionally still in production D1 — user chose to
  leave it rather than delete it.
- Local note: on this machine, `wrangler deploy`/`d1 execute` intermittently threw a generic
  "fetch failed" until DNS resolution was forced to IPv4 first
  (`NODE_OPTIONS=--dns-result-order=ipv4first`). Looked like an IPv6 connectivity issue on this
  network, not a Cloudflare-side problem — reuse that env var if it recurs.

## OPEN ITEMS — verify before A2P submission
1. [BLOCKER] Contact form posts to Cloudflare Worker -> Web3Forms (email + D1 log ONLY).
   It does NOT create GHL contacts or pass consent tags to GHL. The GHL chat widget is a
   SEPARATE lead path. Consent selections from the form never reach the system that sends SMS.
   FIX: point the form at GHL (inbound webhook or GHL form API) so marketing/non-marketing
   tags drive GHL sending. This is the next real task. (Worker is deployed and ready to add a
   GHL forward step once GHL_WEBHOOK_URL is decided.)
2. Non-marketing checkbox text ("about my claim review status and related account updates")
   MUST match the registered GHL A2P campaign use-case description verbatim.
3. Confirm "Drengr Recovery Solutions LLC" matches IRS CP 575/147C exactly. If a DBA is used,
   add "We are doing DBA as [name]" to campaign description + make DBA explicit in terms.html.
4. Confirm (949) 449-2708 is provisioned AND A2P-registered inside GHL (not just owned).
5. ~~Cloudflare Worker not confirmed deployed.~~ DONE — deployed and verified 2026-07-06 (see above).
6. GitHub web-upload leftovers: confirm img-courthouse.jpg, img-celebration.jpg, and the old
   7.5MB logo are deleted from the repo (web upload can't delete — must remove manually).
7. In GHL: tag contacts by consent choice and build workflows that only send marketing SMS to
   marketing-opted contacts. Website compliance ≠ sending compliance.

## Deploy reminder
Push CONTENTS of deploy/ to repo root. Cloudflare Pages: no build command, output dir = /.
Better than web upload: use git or GitHub Desktop so deletions commit cleanly.
