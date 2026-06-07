# PROJECT CONTEXT: ToroPass (Web3 Identity-as-a-Service)

## 1. THE VISION (Why, What, Who, & Future)
**What it is:** ToroPass is a Hybrid Decentralized Identity (DID) platform and Identity-as-a-Service (IDaaS) provider built natively for the Toronet blockchain. It acts as the "Sign In with Google" or "Sign In with Apple" for the Toronet ecosystem.
**Why it exists:** Currently, Toronet developers building Real World Asset (RWA) or DeFi protocols face massive friction: they must build custom, secure, and legally compliant KYC data-collection pipelines to use native features like `depositFunds`. ToroPass removes this friction entirely by separating identity verification from application logic.
**Who it is for:** * **Users:** Complete KYC once in a secure, non-custodial wallet and never upload sensitive documents to random dApps again.
* **Developers:** Verify a user's KYC status with two lines of code without ever touching Personally Identifiable Information (PII), drastically reducing legal liability.
**Future Expansion:** As Toronet expands, ToroPass is architected to scale from basic KYC/BVN verification into full Verifiable Credentials (VCs), Zero-Knowledge Proofs (ZKPs) for age/accreditation, and acting as the premier fiat on-ramp gateway for the ecosystem.

---

## 2. THE ARCHITECTURE (The Monorepo)
The project is a unified monorepo managed by **Melos** (for Dart) and **pnpm** (for Node), containing four interconnected components:

### A. The Holder: ToroPass Wallet (`apps/toropass_wallet`)
* **What it is:** A production-grade, non-custodial Flutter mobile application.
* **Who it is for:** Everyday users and Toronet ecosystem developers.
* **How it works:** Uses the `toronet` Flutter SDK. It generates keys locally, claims a `.toro` TNS name, and securely collects KYC data (BVN/DOB). It stores private keys via `flutter_secure_storage`. 
* **Key Features:** Acts as an OAuth authenticator. Includes a "Connected Apps" privacy manager for users, and a hidden "Developer Dashboard" (accessed via 7-taps on the version number) for third-party devs to generate API keys.

### B. The Authority: ToroPass Issuer (`backend/toropass_issuer`)
* **What it is:** A highly secure NestJS backend operating as the trusted KYC authority.
* **Who it is for:** Internal infrastructure (managed by the ToroPass team).
* **How it works:** Uses the `torosdk` TypeScript package. It receives encrypted PII from the Wallet, validates it, and uses whitelisted Admin credentials to execute `kycService.performKYCForCustomer()`, permanently anchoring the "Verified" state on-chain. It also maintains an off-chain PostgreSQL database tracking OAuth-style developer apps and user consent permissions.

### C. The Ecosystem Backend: ToroPass Verifier (`packages/toropass_verifier`) _(Future)_
* **What it is:** An open-source NPM package (NestJS Dynamic Module) middleware.
* **Who it is for:** Third-party Toronet developers building Node.js backends (e.g., a Real Estate dApp).
* **How it works:** Developers install this in their backend. It takes a user's TNS name, resolves the `0x` address, and calls `isAddressKYCVerified` on-chain. It cross-references this with the ToroPass Issuer API to ensure the user actually granted permission to this specific app. It returns a definitive "Verified" or "Unauthorized" status to protect high-value backend routes.

### D. The Ecosystem Frontend: ToroPass Client (`packages/toropass_client`)
* **What it is:** A lightweight, drop-in Flutter package (`toroid_client`) for third-party mobile apps.
* **Who it is for:** Third-party Toronet developers building Flutter frontends.
* **How it works:** Abstracting deep-linking complexity. It provides a standard `ToroIdButton` and a `ToroIdClient.verifyIdentity()` method. It securely redirects the user to the ToroPass Wallet app for consent, captures the return deep-link, and delivers the authenticated TNS name and wallet address back to the third-party app.
