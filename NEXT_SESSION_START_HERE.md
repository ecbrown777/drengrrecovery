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

## OPEN ITEMS — verify before A2P submission
1. [BLOCKER] Contact form posts to Cloudflare Worker -> Web3Forms (email + D1 log ONLY).
   It does NOT create GHL contacts or pass consent tags to GHL. The GHL chat widget is a
   SEPARATE lead path. Consent selections from the form never reach the system that sends SMS.
   FIX: point the form at GHL (inbound webhook or GHL form API) so marketing/non-marketing
   tags drive GHL sending. This is the next real task.
2. Non-marketing checkbox text ("about my claim review status and related account updates")
   MUST match the registered GHL A2P campaign use-case description verbatim.
3. Confirm "Drengr Recovery Solutions LLC" matches IRS CP 575/147C exactly. If a DBA is used,
   add "We are doing DBA as [name]" to campaign description + make DBA explicit in terms.html.
4. Confirm (949) 449-2708 is provisioned AND A2P-registered inside GHL (not just owned).
5. Cloudflare Worker not confirmed deployed. If deploying: run the NEW schema.sql (consent
   table was restructured into marketing/non-marketing columns). DROP old sms_consent table first.
6. GitHub web-upload leftovers: confirm img-courthouse.jpg, img-celebration.jpg, and the old
   7.5MB logo are deleted from the repo (web upload can't delete — must remove manually).
7. In GHL: tag contacts by consent choice and build workflows that only send marketing SMS to
   marketing-opted contacts. Website compliance ≠ sending compliance.

## Deploy reminder
Push CONTENTS of deploy/ to repo root. Cloudflare Pages: no build command, output dir = /.
Better than web upload: use git or GitHub Desktop so deletions commit cleanly.
