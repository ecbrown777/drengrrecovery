# Drengr Recovery Solutions - Project State (handoff)

Static single-page site + Cloudflare Worker/D1 consent backend. Deploy target: GitHub -> Cloudflare Pages, domain drengrrecoverysolutions.com.

## What's built and current
- `deploy/index.html` - full single-page site (HTML+CSS+JS inline). Sections: hero, how-it-works, why, government-&-legal (4 image cards), who-we-serve, celebration, faq, contact.
- Palette: dark slate (#15171C / #1C1F26 / #262A32) + amber-orange (#E68A2E) + yellow (#F5B942). Corporate/refined, restrained fire accents.
- Logo: fiery "DRENGR RECOVERY SOLUTIONS" wordmark in nav (38px) and footer (46px). Black bg knocked out to transparent. Source: user upload. Files: deploy/drengr-logo-nav.png, deploy/drengr-logo-footer.png.
- Favicon: DRS emblem. Letters-cropped for 16/32px (deploy/favicon.ico, favicon-32.png); full ornate for apple-touch/PWA (apple-touch-icon.png, icon-192.png, icon-512.png).
- Images (all AI-generated per client, compressed to web size): hero-cityscape.jpg (hero bg), img-courthouse/judicial/attorney/legal-docs.jpg (legal band), img-celebration.jpg (celebration band). img-government.jpg present but unused (5th legal option).
- A2P/SMS compliance: consent checkbox on form (not pre-checked, not required), privacy.html + terms.html with A2P 10DLC disclosures, footer links.
- Consent backend: deploy/worker/ - Cloudflare Worker (src/index.js) + D1 (schema.sql) + wrangler.toml. Form POSTs to /api/lead (writes consent record: timestamp, IP, UA, consent text), forwards to Web3Forms, falls back to Web3Forms direct if Worker down. Endpoints: /api/lead, /api/consent (admin), /api/revoke (STOP handling).
- SEO: sitemap.xml, robots.txt, JSON-LD LocalBusiness, canonical, OG/Twitter tags, Google Search Console verification meta.
- Cloudflare: _headers (security headers + caching), _redirects (302s /worker/* to homepage so Worker source isn't publicly downloadable from the Pages site).

## Keys/IDs
- Web3Forms access key: f139a1e8-dba5-4716-9ba8-87f4c90599d6
- Cloudflare account ID: 306caa6057cae387d67204f3dda8e7ab

## 2026-07-06 update: full-bleed image redesign
- Sections now use FULLY VISIBLE photo backgrounds (no dark wash) with translucent gray text panels (.panel, rgba(40,44,52,.80) + blur) for readability: hero (new cityscape, light top scrim for nav only), #how (bg-hallway.jpg, steps boxed as panels, timeline line removed), #why (bg-conference.jpg), #serve (img-attorney.jpg), #celebrate (bg-celebration.jpg, image-beside-text layout removed), #faq (bg-library.jpg). #contact and footer stay solid dark for form readability.
- Legal band cards: courthouse -> img-government.jpg ("Government & IRS Offices"), judicial -> new courtroom render, attorney -> img-workspace.jpg ("Dedicated Case Operations"), legal-docs -> new render.
- All new images recompressed to web weight; total deploy folder now 2.5MB. Deleted: 7.5MB unused logo (old TODO #1), img-courthouse.jpg, img-celebration.jpg.
- Fixed services@ -> info@ in contact section (old TODO #3). Added og:image/twitter:image (hero).
- img-attorney.jpg is only 900px wide - soft as a full-width background. Replace with a 2560px re-render when available.

## 2026-07-06 update #2: dual SMS consent (A2P strict separation)
- Contact form now has TWO consent checkboxes (were one): marketing + non-marketing, each with carrier-mandated exact language, STOP/HELP, msg&data rates. Privacy/ToS links below both. Phone field is OPTIONAL (not required), so the two-box rule doesn't strictly trigger, but split anyway for clean separation.
- ACTION REQUIRED before A2P submission: (1) non-marketing box text says "about my claim review status and related account updates" - this MUST match the USE_CASE in your registered A2P campaign description verbatim, or reject. (2) Confirm "Drengr Recovery Solutions LLC" matches your CP 575/147C exactly; if using a DBA, add "We are doing DBA as [name]" to campaign description AND make the DBA relationship explicit in terms.html.
- Wiring updated end-to-end: index.html JS captures both boxes + exact text; Web3Forms fallback reports both; Worker INSERT writes to new D1 columns; schema.sql sms_consent table split into consented_marketing/consented_nonmarketing + consent_text_marketing/consent_text_nonmarketing.
- D1 SCHEMA CHANGED: if you already ran the old schema, the table structure differs. Since Worker isn't confirmed deployed yet, just run the new schema.sql fresh. If old table exists, DROP TABLE sms_consent first (no live data to lose).

## 2026-07-06 update #3: A2P privacy.html + terms.html compliance (per carrier PDF)
- privacy.html: inserted the EXACT carrier-required non-sharing clause verbatim ("No mobile information will be shared with third parties/affiliates..."). Tightened Section 4 sharing list so it no longer lists "SMS delivery" as a third-party share (was muddying the non-sharing commitment).
- terms.html: rewrote SMS box to include all four required exact clauses: business identity + message types (marketing vs non-marketing), opt-out/support template naming the STOP number, carrier liability, message frequency template, and the privacy-policy cross-link sentence.
- ACTION REQUIRED: STOP number is set to (949) 331-8520 (your voice line) as placeholder. If your 10DLC texting number is DIFFERENT, replace "(949) 331-8520" in the terms.html opt-out clause AND the form checkboxes with the actual sending number, or STOP routing won't match.
- Still pending from update #2: non-marketing checkbox use-case must match registered campaign verbatim; confirm legal name matches CP 575/147C or declare DBA.

## KNOWN ISSUES / TODO
1. Worker not confirmed deployed. Setup steps in deploy/README.md (wrangler d1 create, run schema, set secrets, deploy).
2. Nav has no links to #legal or #celebrate sections (intentional - avoids crowding; reachable by scroll).
3. Fonts: Google Fonts (Playfair Display, Inter) load from CDN on live site. Preview renders in sandbox show fallback fonts because CDN is blocked there - not a real issue.
4. img-attorney.jpg background upscale (see above).

## Deploy
Push contents of deploy/ to repo root. Cloudflare Pages: no build command, output dir = root. Custom domain drengrrecoverysolutions.com + www.
