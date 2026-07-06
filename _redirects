-- Drengr leads + SMS consent records
CREATE TABLE IF NOT EXISTS leads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  phone TEXT,
  property_address TEXT,
  claimant_type TEXT,
  message TEXT,
  source TEXT DEFAULT 'website-form'
);

CREATE TABLE IF NOT EXISTS sms_consent (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lead_id INTEGER REFERENCES leads(id),
  consented_marketing INTEGER NOT NULL DEFAULT 0,      -- 1 = yes, 0 = no
  consented_nonmarketing INTEGER NOT NULL DEFAULT 0,   -- 1 = yes, 0 = no
  consent_timestamp TEXT NOT NULL,       -- ISO8601, server-side
  phone TEXT,
  consent_text_marketing TEXT,           -- exact marketing disclosure shown at time of consent
  consent_text_nonmarketing TEXT,        -- exact non-marketing disclosure shown at time of consent
  ip_address TEXT,
  user_agent TEXT,
  page_url TEXT,
  revoked_at TEXT                        -- set when STOP received / manual revoke
);

CREATE INDEX IF NOT EXISTS idx_consent_phone ON sms_consent(phone);
CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_created ON leads(created_at);
