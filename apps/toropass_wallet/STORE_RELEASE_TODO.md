# ToroPass Wallet Store Release TODO

Use this checklist when ToroPass Wallet is ready for Google Play and Apple App
Store distribution. These items are intentionally deferred while the wallet is
distributed as a development or GitHub preview build.

## Security Blocker

Do not publish the current wallet build to either public store until the shared
issuer credentials are removed.

Current risks to remove:

- `.env` is bundled as a Flutter asset.
- `APP_API_KEY` and `APP_SECRET` can be extracted from the APK/IPA.
- The current HMAC signature does not prove that a request came from the
  official ToroPass Wallet.

Never replace these values with another static Dart constant, native resource,
`--dart-define`, or remotely downloaded global secret.

## 1. Create The Firebase Project

- [ ] Create a Firebase project owned by the ToroPass organization.
- [ ] Restrict production access to approved team members.
- [ ] Register the Android application:
  - package: `app.toropass.toropass_wallet`
  - release-signing SHA-256 certificate fingerprint
- [ ] Register the iOS application using the final bundle identifier.
- [ ] Decide whether Firebase configuration files are committed according to
  project policy.
- [ ] Never commit Firebase Admin service-account credentials or debug tokens.

Required client configuration:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- generated `lib/firebase_options.dart`

## 2. Configure Android Play Integrity

- [ ] Create the application in Google Play Console.
- [ ] Upload a release-signed build to an internal testing track or internal
  app sharing.
- [ ] Link the Play application to the Google Cloud/Firebase project.
- [ ] Enable the Play Integrity API.
- [ ] Register the release-signing certificate used by Google Play.
- [ ] Enable Firebase App Check with Play Integrity.
- [ ] Confirm internal-test installations receive recognized app and device
  verdicts.
- [ ] Define the minimum accepted device-integrity verdict.
- [ ] Test rooted, tampered, outdated, and unsupported-device behavior.

Important:

- A GitHub-sideloaded APK is normally unlicensed or unrecognized by Google
  Play. Do not use the GitHub APK to validate production Play Integrity.
- Emulators and local builds must use registered Firebase App Check debug
  tokens.
- Never distribute a debug-provider build publicly.

## 3. Configure Apple App Attest

- [ ] Enroll the final App ID in the Apple Developer portal.
- [ ] Add the App Attest capability to the Runner target.
- [ ] Add the App Attest environment entitlement.
- [ ] Enable Firebase App Check with App Attest.
- [ ] Decide whether to use DeviceCheck fallback for unsupported devices.
- [ ] Test the development/sandbox environment on physical devices.
- [ ] Test production behavior through TestFlight before App Store release.
- [ ] Confirm sandbox keys are never reused in production.
- [ ] Use Firebase debug tokens for iOS simulators only.
- [ ] Define recovery behavior when App Attest is temporarily unavailable.

## 4. Update The Flutter Wallet

- [ ] Add `firebase_core`.
- [ ] Add `firebase_app_check`.
- [ ] Initialize Firebase before `runApp`.
- [ ] Activate providers by build type:
  - debug Android: `AndroidProvider.debug`
  - release Android: `AndroidProvider.playIntegrity`
  - debug Apple: `AppleProvider.debug`
  - release Apple: App Attest, optionally with DeviceCheck fallback
- [ ] Create an App Check service that obtains and refreshes tokens.
- [ ] Attach the token to issuer requests:

  ```http
  X-Firebase-AppCheck: <token>
  ```

- [ ] Never log App Check tokens.
- [ ] Fail closed in release builds when required attestation is unavailable.
- [ ] Keep wallet JWTs and OAuth app tokens separate from App Check tokens.

## 5. Update The Issuer Backend

- [ ] Remove `APP_API_KEY`, `APP_SECRET`, `ApiGuard`, and `HmacAuthGuard`.
- [ ] Remove API-key/HMAC headers from the wallet interceptor.
- [ ] Remove `.env` from Flutter assets.
- [ ] Add Firebase Admin SDK to the NestJS issuer.
- [ ] Initialize Firebase Admin with workload identity or a server-only
  credential.
- [ ] Add an `AppCheckGuard` that verifies:
  - `X-Firebase-AppCheck` is present
  - token signature and expiration are valid
  - token belongs to the expected Firebase project/application
- [ ] Never log the raw App Check token.
- [ ] Keep wallet JWT authentication on user-specific endpoints.
- [ ] Keep rotating refresh-token validation on session refresh.
- [ ] Keep PKCE and OAuth access-token validation on third-party endpoints.

## 6. Define Route Enforcement

Require App Check on wallet-originated routes:

- [ ] `GET /api/v1/wallets/tns`
- [ ] `POST /api/v1/wallets/create`
- [ ] `POST /api/v1/wallets/validate`
- [ ] `GET /api/v1/wallets`
- [ ] `POST /api/v1/wallets/change-password`
- [ ] `POST /api/v1/wallets/refresh`
- [ ] `POST /api/v1/kyc/verify`
- [ ] consent-management routes
- [ ] developer-app management routes
- [ ] wallet-side OAuth authorization

Do not require wallet App Check on third-party SDK routes:

- `POST /api/v1/oauth/token`
- `GET /api/v1/oauth/profile`

Those routes must continue using PKCE, OAuth tokens, consent checks, and rate
limits.

## 7. Add Abuse And Replay Protection

- [ ] Keep a global issuer rate limit.
- [ ] Add stricter limits to wallet creation, validation, refresh, KYC, and
  OAuth exchange.
- [ ] Use shared rate-limit storage such as Redis when running multiple issuer
  instances.
- [ ] Confirm the reverse proxy forwards trustworthy client IP information.
- [ ] Consider limited-use App Check tokens for high-risk operations.
- [ ] Add request-body size limits.
- [ ] Add monitoring for repeated failed attestation and authentication.

## 8. Roll Out Safely

- [ ] Deploy token verification in monitor-only mode first.
- [ ] Measure missing/invalid token rates without rejecting users.
- [ ] Verify Android internal-track builds.
- [ ] Verify Apple physical-device sandbox builds.
- [ ] Verify TestFlight production behavior.
- [ ] Enable enforcement on wallet creation and validation first.
- [ ] Enable enforcement on refresh and authenticated wallet routes.
- [ ] Remove temporary monitoring bypasses before public release.
- [ ] Maintain a documented emergency rollback procedure.

## 9. Store Submission And Privacy

- [ ] Update the privacy policy for integrity/device signals.
- [ ] Complete Google Play Data safety disclosures.
- [ ] Complete Apple App Privacy disclosures.
- [ ] Document supported Android and iOS versions.
- [ ] Document behavior for unsupported or compromised devices.
- [ ] Verify production signing certificates and provisioning profiles.
- [ ] Confirm release builds contain no debug tokens, service credentials, or
  development issuer URLs.

## Acceptance Criteria

- [ ] APK/IPA extraction reveals no reusable issuer credential.
- [ ] A request without valid App Check fails on enforced wallet routes.
- [ ] A token from another Firebase application is rejected.
- [ ] Expired, malformed, and debug tokens are rejected in production.
- [ ] Wallet JWT authentication still protects user-specific data.
- [ ] Third-party OAuth SDK routes work without wallet attestation.
- [ ] Rate limits remain active as defense in depth.
- [ ] Android internal-track and Apple TestFlight end-to-end flows pass.

## Official References

- Firebase App Check for Flutter:
  https://firebase.google.com/docs/app-check/flutter/default-providers
- Firebase App Check debug provider:
  https://firebase.google.com/docs/app-check/flutter/debug-provider
- Firebase App Check for custom backends:
  https://firebase.google.com/docs/app-check/flutter/custom-resource
- Google Play Integrity setup:
  https://developer.android.com/google/play/integrity/setup
- Apple App Attest preparation:
  https://developer.apple.com/documentation/devicecheck/preparing-to-use-the-app-attest-service
- Apple App Attest server validation:
  https://developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server
