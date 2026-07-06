// Drengr lead intake Worker
// POST /api/lead  -> writes lead + consent record to D1, forwards to Web3Forms
// GET  /api/consent?phone=XXXXXXXXXX  -> consent status lookup (requires ADMIN_KEY)
// POST /api/revoke {phone}            -> mark consent revoked (requires ADMIN_KEY)

const ALLOWED_ORIGINS = [
  'https://www.drengrrecoverysolutions.com',
  'https://drengrrecoverysolutions.com',
];

function cors(origin) {
  const allowed = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allowed,
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}

function json(data, status, origin) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...cors(origin) },
  });
}

function normalizePhone(raw) {
  if (!raw) return null;
  const digits = raw.replace(/\D/g, '');
  if (digits.length === 10) return '+1' + digits;
  if (digits.length === 11 && digits.startsWith('1')) return '+' + digits;
  return digits ? '+' + digits : null;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin') || '';

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors(origin) });
    }

    // --- Lead intake ---
    if (url.pathname === '/api/lead' && request.method === 'POST') {
      let body;
      try { body = await request.json(); } catch { return json({ ok: false, error: 'Invalid JSON' }, 400, origin); }

      if (!body.first_name || !body.email) {
        return json({ ok: false, error: 'first_name and email required' }, 400, origin);
      }

      // Honeypot: bots fill hidden fields
      if (body.website) return json({ ok: true }, 200, origin);

      const phone = normalizePhone(body.phone);
      const ip = request.headers.get('CF-Connecting-IP') || '';
      const ua = request.headers.get('User-Agent') || '';
      const now = new Date().toISOString();

      try {
        const leadResult = await env.DB.prepare(
          `INSERT INTO leads (first_name, last_name, email, phone, property_address, claimant_type, message)
           VALUES (?, ?, ?, ?, ?, ?, ?)`
        ).bind(
          body.first_name || null,
          body.last_name || null,
          body.email || null,
          phone,
          body.property_address || null,
          body.claimant_type || null,
          body.message || null
        ).run();

        const leadId = leadResult.meta.last_row_id;

        await env.DB.prepare(
          `INSERT INTO sms_consent (lead_id, consented, consent_timestamp, phone, consent_text, ip_address, user_agent, page_url)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
        ).bind(
          leadId,
          body.sms_consent === true ? 1 : 0,
          now,
          phone,
          body.consent_text || null,
          ip,
          ua,
          body.page_url || null
        ).run();

        // Forward to Web3Forms for email notification (non-blocking failure)
        try {
          await fetch('https://api.web3forms.com/submit', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
            body: JSON.stringify({
              access_key: env.WEB3FORMS_KEY,
              subject: 'New Drengr Claim Review Request',
              first_name: body.first_name,
              last_name: body.last_name,
              email: body.email,
              phone: phone,
              property_address: body.property_address,
              claimant_type: body.claimant_type,
              message: body.message,
              sms_consent: body.sms_consent === true ? `YES - ${now}` : 'NO',
              lead_id: String(leadId),
            }),
          });
        } catch (e) { /* email failure must not lose the lead; it's in D1 */ }

        return json({ ok: true, lead_id: leadId }, 200, origin);
      } catch (e) {
        return json({ ok: false, error: 'Database error' }, 500, origin);
      }
    }

    // --- Consent lookup (admin) ---
    if (url.pathname === '/api/consent' && request.method === 'GET') {
      if (url.searchParams.get('key') !== env.ADMIN_KEY) return json({ ok: false }, 403, origin);
      const phone = normalizePhone(url.searchParams.get('phone'));
      if (!phone) return json({ ok: false, error: 'phone required' }, 400, origin);
      const rows = await env.DB.prepare(
        `SELECT * FROM sms_consent WHERE phone = ? ORDER BY consent_timestamp DESC`
      ).bind(phone).all();
      return json({ ok: true, records: rows.results }, 200, origin);
    }

    // --- Revoke consent (STOP handling / manual) ---
    if (url.pathname === '/api/revoke' && request.method === 'POST') {
      let body;
      try { body = await request.json(); } catch { return json({ ok: false }, 400, origin); }
      if (body.key !== env.ADMIN_KEY) return json({ ok: false }, 403, origin);
      const phone = normalizePhone(body.phone);
      await env.DB.prepare(
        `UPDATE sms_consent SET revoked_at = ? WHERE phone = ? AND revoked_at IS NULL`
      ).bind(new Date().toISOString(), phone).run();
      return json({ ok: true }, 200, origin);
    }

    return json({ ok: false, error: 'Not found' }, 404, origin);
  },
};
