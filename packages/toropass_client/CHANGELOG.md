## 0.2.0

- Require S256 PKCE for authorization-code exchange.
- Preserve PKCE verifiers inside authorization request objects for manual flows.
- Make scoped profile fields nullable when the user did not grant access.
- Document scope-to-profile mappings and secure manual code exchange.

## 0.1.1

- Refresh package metadata for the next published release.
- Align the installation documentation with the current package version.

## 0.1.0

- Add `ToroPassClient` core OAuth flow support for wallet launch, callback capture,
  code exchange, and profile fetch.
- Add `ToroPassClientConfig`, typed auth results, status helpers, and wallet launch
  request modeling.
- Add `ToroPassButton` for lightweight host-app integration.
- Add a runnable example app with native callback registration for simulator and
  device testing.
- Document platform setup, callback handling, and end-to-end verification flow.
