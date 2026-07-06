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
- Cloudflare: _headers (security headers + caching).

## Keys/IDs
- Web3Forms access key: f139a1e8-dba5-4716-9ba8-87f4c90599d6
- Cloudflare account ID: 306caa6057cae387d67204f3dda8e7ab

## 2026-07-06 update: full-bleed image redesign
- Sections now use FULLY VISIBLE photo backgrounds (no dark wash) with translucent gray text panels (.panel, rgba(40,44,52,.80) + blur) for readability: hero (new cityscape, light top scrim for nav only), #how (bg-hallway.jpg, steps boxed as panels, timeline line removed), #why (bg-conference.jpg), #serve (img-attorney.jpg), #celebrate (bg-celebration.jpg, image-beside-text layout removed), #faq (bg-library.jpg). #contact and footer stay solid dark for form readability.
- Legal band cards: courthouse -> img-government.jpg ("Government & IRS Offices"), judicial -> new courtroom render, attorney -> img-workspace.jpg ("Dedicated Case Operations"), legal-docs -> new render.
- All new images recompressed to web weight; total deploy folder now 2.5MB. Deleted: 7.5MB unused logo (old TODO #1), img-courthouse.jpg, img-celebration.jpg.
- Fixed services@ -> info@ in contact section (old TODO #3). Added og:image/twitter:image (hero).
- img-attorney.jpg is only 900px wide - soft as a full-width background. Replace with a 2560px re-render when available.

## KNOWN ISSUES / TODO
1. Worker not confirmed deployed. Setup steps in deploy/README.md (wrangler d1 create, run schema, set secrets, deploy).
2. Nav has no links to #legal or #celebrate sections (intentional - avoids crowding; reachable by scroll).
3. Fonts: Google Fonts (Playfair Display, Inter) load from CDN on live site. Preview renders in sandbox show fallback fonts because CDN is blocked there - not a real issue.
4. img-attorney.jpg background upscale (see above).

## Deploy
Push contents of deploy/ to repo root. Cloudflare Pages: no build command, output dir = root. Custom domain drengrrecoverysolutions.com + www.
