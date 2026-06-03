# Ok Period

UIKit iOS app with Firebase Authentication supporting **Google Sign-In** and **Email OTP** verification.

## Architecture

```
OkPeriod/
├── App/                 AppDelegate, SceneDelegate (auth state routing)
├── Authentication/      AuthService (Firebase Auth + Cloud Functions)
├── Screens/             Login, Email entry, OTP verification, Home
├── Utilities/           Shared UI theme and helpers
└── Resources/           Info.plist, GoogleService-Info.plist, assets

functions/               Firebase Cloud Functions for email OTP
```

## Firebase Project

- **Project ID:** `ok-period`
- **Bundle ID:** `com.okperiod.app`
- **Console:** https://console.firebase.google.com/project/ok-period/overview

Auth providers enabled: Google Sign-In, Email/Password (for custom-token email OTP flow).

## Getting Started

### 1. Open in Xcode

Open `OkPeriod.xcodeproj`. Xcode resolves Swift Package Manager dependencies automatically:

- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) (Auth, Functions)
- [Google SignIn iOS](https://github.com/google/GoogleSignIn-iOS)

Select your development team under **Signing & Capabilities** to run on a device or simulator.

### 2. Deploy Cloud Functions

Email OTP is handled by callable Cloud Functions (`requestEmailOTP`, `verifyEmailOTP`).

**Note:** Cloud Functions require the Firebase **Blaze (pay-as-you-go)** plan. Upgrade at:
https://console.firebase.google.com/project/ok-period/usage/details

```bash
cd functions
npm install
cd ..
npx firebase-tools@latest deploy --only functions,firestore:rules --project ok-period
```

#### Email delivery (SendGrid)

Set secrets for production email delivery:

```bash
npx firebase-tools@latest functions:secrets:set SENDGRID_API_KEY --project ok-period
npx firebase-tools@latest functions:secrets:set OTP_FROM_EMAIL --project ok-period
```

Without `SENDGRID_API_KEY`, the OTP is logged to Cloud Functions logs for development:

```bash
npx firebase-tools@latest functions:log --project ok-period
```

### 3. Google Sign-In on device

For Google Sign-In on a physical device, add your app's **iOS URL scheme** (already configured from `REVERSED_CLIENT_ID` in `GoogleService-Info.plist`) and ensure the bundle ID matches `com.okperiod.app` in the Firebase console.

## Authentication Flows

### Google Sign-In

1. User taps **Sign in with Google** on the login screen.
2. `AuthService` presents the Google Sign-In sheet and exchanges the ID token for a Firebase credential.
3. On success, `SceneDelegate` routes to `HomeViewController`.

### Email OTP

1. User taps **Sign in with Email** and enters their email.
2. App calls `requestEmailOTP` — a 6-digit code is stored (hashed) in Firestore and emailed.
3. User enters the code on the OTP screen.
4. App calls `verifyEmailOTP` — on success, receives a Firebase custom token and signs in.

## Local Emulator (optional)

```bash
cd functions && npm run serve
```

Point the iOS app at emulators by uncommenting emulator configuration in `AuthService` if needed during development.
