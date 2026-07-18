-- Legacy authorization codes and app tokens were not bound to PKCE or a
-- trustworthy scope snapshot. Invalidate them so clients re-authorize safely.
DELETE FROM "oauth_codes";
DELETE FROM "oauth_tokens";

-- Give existing consent grants the same 30-day lifetime as new grants.
UPDATE "oauth_consents"
SET "expires_at" = "granted_at" + INTERVAL '30 days'
WHERE "expires_at" IS NULL;

ALTER TABLE "oauth_codes"
ADD COLUMN "scopes" TEXT[] NOT NULL,
ADD COLUMN "code_challenge" TEXT NOT NULL,
ADD COLUMN "code_challenge_method" TEXT NOT NULL DEFAULT 'S256';

ALTER TABLE "oauth_tokens"
ADD COLUMN "scopes" TEXT[] NOT NULL;
