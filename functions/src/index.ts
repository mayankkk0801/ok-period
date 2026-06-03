import * as crypto from "crypto";
import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as nodemailer from "nodemailer";

admin.initializeApp();

const OTP_COLLECTION = "email_otps";
const OTP_EXPIRY_MS = 10 * 60 * 1000;
const MAX_ATTEMPTS = 5;

function normalizeEmail(email: unknown): string {
  if (typeof email !== "string") {
    throw new HttpsError("invalid-argument", "A valid email is required.");
  }

  const normalized = email.trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
    throw new HttpsError("invalid-argument", "A valid email is required.");
  }

  return normalized;
}

function normalizeOTP(otp: unknown): string {
  if (typeof otp !== "string") {
    throw new HttpsError("invalid-argument", "A 6-digit verification code is required.");
  }

  const normalized = otp.trim();
  if (!/^\d{6}$/.test(normalized)) {
    throw new HttpsError("invalid-argument", "A 6-digit verification code is required.");
  }

  return normalized;
}

function emailDocId(email: string): string {
  return crypto.createHash("sha256").update(email).digest("hex");
}

function hashOTP(email: string, otp: string): string {
  return crypto.createHash("sha256").update(`${email}:${otp}`).digest("hex");
}

function generateOTP(): string {
  return crypto.randomInt(100000, 999999).toString();
}

async function sendOTPEmail(email: string, otp: string): Promise<void> {
  const apiKey = process.env.SENDGRID_API_KEY;
  const fromEmail = process.env.OTP_FROM_EMAIL || "noreply@okperiod.app";

  if (!apiKey) {
    console.warn(`SENDGRID_API_KEY is not set. OTP for ${email}: ${otp}`);
    return;
  }

  const transporter = nodemailer.createTransport({
    host: "smtp.sendgrid.net",
    port: 587,
    auth: {
      user: "apikey",
      pass: apiKey,
    },
  });

  await transporter.sendMail({
    from: `"Ok Period" <${fromEmail}>`,
    to: email,
    subject: "Your Ok Period verification code",
    text: `Your verification code is ${otp}. It expires in 10 minutes.`,
    html: `<p>Your verification code is <strong>${otp}</strong>.</p><p>It expires in 10 minutes.</p>`,
  });
}

const RUNTIME_SERVICE_ACCOUNT =
  "ok-period@appspot.gserviceaccount.com";

export const requestEmailOTP = onCall(
  {invoker: "public", serviceAccount: RUNTIME_SERVICE_ACCOUNT},
  async (request) => {
    const email = normalizeEmail(request.data?.email);
    const otp = generateOTP();
    const docId = emailDocId(email);

    await admin.firestore().collection(OTP_COLLECTION).doc(docId).set({
      email,
      otpHash: hashOTP(email, otp),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + OTP_EXPIRY_MS)
      ),
      attempts: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await sendOTPEmail(email, otp);
    return {success: true};
  }
);

export const verifyEmailOTP = onCall(
  {invoker: "public", serviceAccount: RUNTIME_SERVICE_ACCOUNT},
  async (request) => {
    try {
      const email = normalizeEmail(request.data?.email);
      const otp = normalizeOTP(request.data?.otp);
      const docId = emailDocId(email);
      const docRef = admin.firestore().collection(OTP_COLLECTION).doc(docId);
      const snapshot = await docRef.get();

      if (!snapshot.exists) {
        throw new HttpsError("not-found", "Verification code expired or not found.");
      }

      const data = snapshot.data()!;
      const expiresAt = data.expiresAt as admin.firestore.Timestamp;
      const attempts = (data.attempts as number) ?? 0;

      if (attempts >= MAX_ATTEMPTS) {
        await docRef.delete();
        throw new HttpsError("resource-exhausted", "Too many failed attempts. Request a new code.");
      }

      if (expiresAt.toDate().getTime() < Date.now()) {
        await docRef.delete();
        throw new HttpsError("deadline-exceeded", "Verification code has expired.");
      }

      if (data.otpHash !== hashOTP(email, otp)) {
        await docRef.update({attempts: attempts + 1});
        throw new HttpsError("invalid-argument", "Incorrect verification code.");
      }

      await docRef.delete();

      let userRecord: admin.auth.UserRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(email);
      } catch (error) {
        const authError = error as {code?: string};
        if (authError.code !== "auth/user-not-found") {
          throw error;
        }
        userRecord = await admin.auth().createUser({
          email,
          emailVerified: true,
        });
      }

      const customToken = await admin.auth().createCustomToken(userRecord.uid);
      return {customToken};
    } catch (error) {
      console.error("verifyEmailOTP failed:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      const message =
        error instanceof Error ? error.message : "Unknown verification error.";
      throw new HttpsError("internal", message);
    }
  }
);
