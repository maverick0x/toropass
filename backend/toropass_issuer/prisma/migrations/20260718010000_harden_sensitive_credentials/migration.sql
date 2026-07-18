-- Existing bearer and refresh tokens are stored in plaintext and cannot be
-- converted without preserving a plaintext compatibility path. Force clients
-- to authenticate again after deployment.
DELETE FROM "oauth_tokens";
DELETE FROM "user_sessions";

ALTER TABLE "oauth_tokens"
RENAME COLUMN "access_token" TO "token_hash";

ALTER INDEX "oauth_tokens_access_token_key"
RENAME TO "oauth_tokens_token_hash_key";

ALTER TABLE "user_sessions"
RENAME COLUMN "refresh_token" TO "token_hash";

ALTER INDEX "user_sessions_refresh_token_key"
RENAME TO "user_sessions_token_hash_key";

ALTER TABLE "user_sessions"
ADD COLUMN "family_id" TEXT NOT NULL,
ADD COLUMN "expires_at" TIMESTAMP(3) NOT NULL,
ADD COLUMN "revoked_at" TIMESTAMP(3),
ADD COLUMN "replaced_by_id" TEXT,
ADD COLUMN "reuse_detected_at" TIMESTAMP(3);

CREATE INDEX "user_sessions_family_id_idx" ON "user_sessions"("family_id");

-- Raw SHA-256 BVN hashes cannot be converted without the original BVN. Tag
-- legacy values so new verification can detect duplicates while new records
-- use versioned keyed HMAC values.
UPDATE "users"
SET "bvn_hash" = 'legacy-sha256:' || "bvn_hash"
WHERE "kyc_verified" = true
  AND "bvn_hash" ~ '^[a-f0-9]{64}$';
