# Drengr Recovery Solutions - Website

Static single-page site. Deploy via Cloudflare Pages.

## Deploy
1. Push this folder's contents to the GitHub repo root (drengrrecovery).
2. Cloudflare Pages > project > connected to repo > build command: none, output directory: / (root).
3. Custom domain: drengrrecoverysolutions.com (and www).

## Files
- index.html - entire site (HTML + CSS + JS inline)
- sitemap.xml / robots.txt - SEO
- _headers - Cloudflare Pages security headers
- favicon.ico, favicon-32.png, apple-touch-icon.png, icon-192.png, icon-512.png

## Worker + D1 consent backend (worker/ folder)

One-time setup from the worker/ folder (needs Node installed):

```
npx wrangler login
npx wrangler d1 create drengr-leads
# copy the database_id it prints into wrangler.toml
npx wrangler d1 execute drengr-leads --remote --file=schema.sql
npx wrangler secret put WEB3FORMS_KEY   # paste: f139a1e8-dba5-4716-9ba8-87f4c90599d6
npx wrangler secret put ADMIN_KEY       # make up a long random string, save it
npx wrangler deploy
```

The form on index.html posts to /api/lead first; if the Worker isn't
deployed yet it falls back to Web3Forms automatically, so the site works
either way.

### Useful queries
Export all consent records:
```
npx wrangler d1 execute drengr-leads --remote --command "SELECT * FROM sms_consent" --json > consent-export.json
```
Check one phone number:
```
npx wrangler d1 execute drengr-leads --remote --command "SELECT * FROM sms_consent WHERE phone='+19495551234'"
```
Mark STOP received (revoke):
```
npx wrangler d1 execute drengr-leads --remote --command "UPDATE sms_consent SET revoked_at=datetime('now') WHERE phone='+19495551234' AND revoked_at IS NULL"
```
