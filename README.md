# Ok Period

A UIKit iOS app with Firebase Authentication — **Google Sign-In** and **Email OTP** verification.

## Requirements

- Xcode 16+ (iOS 26 deployment target)
- Apple Developer account (for running on a physical device)
- Firebase project: `ok-period` (already configured via `GoogleService-Info.plist`)

## Run the App

1. **Clone the repo**
   ```bash
   git clone https://github.com/mayankkk0801/ok-period.git
   cd ok-period
   ```

2. **Open in Xcode**
   ```bash
   open OkPeriod.xcodeproj
   ```

3. **Wait for Swift packages to resolve**  
   Xcode automatically downloads Firebase and Google Sign-In dependencies.

4. **Set your signing team**  
   Select the **OkPeriod** target → **Signing & Capabilities** → choose your **Team**.

5. **Run**  
   Pick a simulator or connected iPhone → press **⌘R**.

### Sign in options

| Method | Works out of the box? |
|--------|----------------------|
| **Google Sign-In** | Yes (simulator or device) |
| **Email OTP** | Requires Cloud Functions (see below) |

---

## Email OTP Setup (optional)

Email sign-in uses Firebase Cloud Functions. These must be deployed before the OTP flow works.

**Prerequisites:** Firebase Blaze plan + Firebase CLI (`npm install -g firebase-tools`)

```bash
firebase login
cd functions && npm install && cd ..
firebase deploy --only functions,firestore:rules --project ok-period
```

**Cloud Run permissions (one-time):**  
In [Google Cloud Console → Cloud Run](https://console.cloud.google.com/run?project=ok-period), add **Cloud Run Invoker** for `allUsers` on both `requestemailotp` and `verifyemailotp`.

**IAM for sign-in token (one-time):**  
In [Google Cloud IAM](https://console.cloud.google.com/iam-admin/iam?project=ok-period), add **Service Account Token Creator** to `ok-period@appspot.gserviceaccount.com`.

**Without SendGrid:** OTP codes appear in [Firebase Functions logs](https://console.firebase.google.com/project/ok-period/functions/logs), not in email.

---

## Project Structure

```
OkPeriod/          iOS app (UIKit)
functions/         Firebase Cloud Functions (email OTP)
firebase.json      Firebase configuration
```

## Firebase Console

https://console.firebase.google.com/project/ok-period/overview
