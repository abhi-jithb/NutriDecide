# NutriDecide: Production Deployment & Development Guide

NutriDecide has transitioned from a local prototype to a **Production-Ready Architecture**. This guide details the high-performance systems and the deployment steps for a live release on the Google Play Store.

---

## 🏗️ 1. Production Architecture (Current State)

### 🚀 High-Performance Boot System
We use a **Parallel AppInitializer** (`lib/core/services/app_initializer.dart`) to ensure the app starts in **< 2 seconds**.
- **Phase 1 (Infrastructure):** Parallel load of `.env`, Firebase, and Hive.
- **Phase 2 (Heavy Assets):** Indexing the 20,000-food dataset into Hive (Isolate-based).
- **Phase 3 (User Logic):** Real-time sync of user Health DNA from Cloud Firestore.

### 📦 Optimized Data Layer (Hive Migration)
- **O(1) Lookup:** Standard JSON parsing is replaced by **Hive binary indexing**. 20k foods are indexed locally, ensuring zero-latency barcode scans.
- **Memory Efficiency:** Hive's lazy-loading prevents high RAM usage even with massive datasets.

### 🧱 🛡️ Secure Navigation Guard (AuthWrapper)
- The app uses an `AuthWrapper` (`lib/features/auth/presentation/auth_wrapper.dart`) to enforce a dual-gate:
  1. **User Authentication:** Verified via Firebase Auth.
  2. **Health DNA Check:** Verifies if the user has completed their profile in Firestore.

### 🛑 Global Error Handling & Stability
- **GlobalErrorHandler:** A centralized system (`lib/core/services/global_error_handler.dart`) catches unhandled exceptions across the app.
- **Error Boundaries:** Prevents white-screen crashes by showing a user-friendly "Something went wrong" fallback UI.
- **Robust Scanning:** The scan engine handles unknown products with non-blocking feedback, automatically resetting the camera for the next attempt.

---

## 🌎 2. How to Host This Application

### 🛰️ Step A: Database & Backend (The Global Intelligence)
1. **MongoDB Atlas:** 
   - Create a cluster on [MongoDB Atlas](https://www.mongodb.com/cloud/atlas).
   - Get your `MONGODB_URI`.
2. **Render.com (Backend API):**
   - Push the `backend/` folder to GitHub and link it to [Render](https://render.com).
   - Set Build: `npm install` | Start: `npm start`.
   - Add Env Variables: `MONGODB_URI` and `PORT`.
   - Result: A live URL (e.g., `https://api.nutridecide.io`).

### 🔑 Step B: Firebase (User Sync & Auth)
1. Initialize a **Firebase Project** at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password Auth** and **Cloud Firestore**.
3. Create a **Firestore Database** in "Production Mode" but set rules to:
   ```js
   allow read, write: if request.auth != null;
   ```
4. Download and add `google-services.json` (Android) to `android/app/`.

### 🛡️ Step C: Secret Management (.env)
1. Update your local `.env` file with the Production values:
   ```text
   BACKEND_URL=https://your-api.onrender.com/api
   FIREBASE_PROJECT_ID=nutridecide-prod
   ```

---

## 📱 3. Google Play Store Deployment (Android)

### 🎨 Step 1: Branding & Compliance
- **Icons:** Generate icons using `flutter_launcher_icons`.
- **Compliance:** Ensure the **Medical Disclaimer** (`lib/features/legal/presentation/medical_disclaimer_screen.dart`) is visible during onboarding.
- **Privacy:** Document all health data usage (Oauth/Health DNA) in your Privacy Policy.

### 📦 Step 2: Build the App Bundle (AAB)
1. Create a `keystore.jks` in `android/app/`.
2. Update `android/key.properties` with your signing credentials.
3. Run the optimized build:
   ```bash
   flutter build appbundle --release
   ```

### 📤 Step 3: Play Console Upload
- Upload `build/app/outputs/bundle/release/app-release.aab` to the **Internal Testing** or **Production** track.
- Provide the required medical app declarations (confirming NutriDecide is a nutritional guidance tool, not a diagnostic medical device).

---

## 🧪 4. Testing Protocols
1. **The "Clean" Boot:** Delete app data and ensure the 20k-food Hive import completes in the background without UI lag.
2. **The "New User" Flow:** Login -> Verify missing profile -> Automatic redirect to `ProfileSetupScreen`.
3. **The "Inference" Test:** Set "Diabetes" in profile -> Scan high-sugar item -> Verify risk score multipliers.

---

*NutriDecide: Beyond calories. Built for YOUR health DNA.*