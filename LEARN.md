# 🎓 Learning NutriDecide: Technical Blueprint & Evolution

Welcome to the **NutriDecide** knowledge base. This document is a guide for developers to understand the technical architecture and the production-ready state of the application.

---

## 🏛️ Architectural Framework
NutriDecide is built using a **Feature-First Clean Architecture**. It is designed for maximum performance, minimal binary size, and data transparency.

### **Core Layers**
- **Inference Engine:** Located in `lib/features/scan/services/nutrition_service.dart`, it cross-references scanned food data with the user's **Biometric Profile** and health conditions.
- **Offline Intelligence:** The `FoodDatabaseService` manages a high-speed Hive database for offline product lookup using a 20k indexed dataset.

---

## 🔍 Deep Dive: File & Module Architecture

### **1. Frontend (Flutter / Dart)**
Located in the `lib/` directory:
- **`lib/features/scan/`**:
    - `scan_screen.dart`: Focused, one-tap barcode detection using `mobile_scanner`.
    - `nutrition_service.dart`: The brain that calculates health verdicts (GOOD / CAUTION / AVOID).
    - `scoring_engine.dart`: Advanced ruleset for artificial additives and nutrient density.
- **`lib/features/profile/`**:
    - `profile_screen.dart`: Simple, biometric dashboard showing age, height, and medical conditions.
- **`lib/features/home/`**:
    - `home_screen.dart`: Minimalist "Scan First" dashboard.

### **2. Backend (Node.js / Express)**
Located in the `backend/` directory:
- **`server.js`**: A production-grade API for serving supplemental food data. Currently optimized for cloud deployment (Render/Atlas) with health monitoring and security headers.

---

## 🛠️ Technical Stack & Dependencies

| Library / Tech | Role in NutriDecide |
|---------|--------------------|
| **`mobile_scanner`** | High-performance, low-latency live barcode detection. |
| **`hive`** | Parallel, persistent offline storage for 20k+ food items. |
| **`firebase_auth`** | Secure user authentication and session management. |
| **`google_fonts`** | Implements the premium **Outfit** typography. |
| **`shared_preferences`** | User preference persistence (Dark Mode, Alerts). |

---

## 🎙️ The One-Tap Flow
The project's latest evolution focuses on **Product Honesty** and **Extreme Simplification**.
1. **No-Guesswork Verdicts:** Uses a confidence layer to tell you when data is partial or uncertain.
2. **Medical Guard:** All users must accept a medical disclaimer before accessing health verdicts.
3. **Biometric Alignment:** Every verdict is weighted against the user's age, weight, and specific medical conditions (Diabetes, PCOS, Hypertension).

---

## 🌎 3. Production Deployment Guide

### **🛰️ Step A: Database & Backend**
1. **MongoDB Atlas:** 
   - Deploy a cluster and get your `MONGO_URI`.
2. **Render.com (Backend API):**
   - Push the `backend/` folder and link it to [Render](https://render.com).
   - Set Build: `npm install` | Start: `npm start`.
   - Add Env Variables: `MONGO_URI` and `PORT`.

### **🔑 Step B: Firebase Integration**
1. Initialize a **Firebase Project** at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password Auth** and **Cloud Firestore**.
3. Create a **Firestore Database** in "Production Mode".
4. Download and add `google-services.json` (Android) to `android/app/`.

### **🛡️ Step C: Build the App Bundle**
1. Run the optimized build for the Google Play Store:
   ```bash
   flutter build appbundle --release
   ```

---

## 📈 Evolutionary Milestones

### **V1.0 - V1.4: Feature Exploration**
Initial versions explored Voice Search, Behavioral Coaching, and complex dashboard analytics.

### **V1.5: Production Hardening (Current)**
- **Feature Pruning:** Removed non-functioning Voice and AI components to ensure 100% stable performance.
- **Biometric Precision:** Added Age and localized health condition logic to the profile.
- **Backend Optimization:** Migrated from a local-only setup to a cloud-ready Express/MongoDB architecture.
- **Offline Migration:** Transitioned the core scanner to use a 20k Hive-indexed database, reducing API dependency.

---

## 🚀 Vision for the Future
The project is architected for expansion into:
- **Family Hub:** Multi-profile management to track kids' allergy risks.
- **Festival Modes:** Dedicated UI modules for high-calorie festive seasons.
- **AR Core Integration:** Transitioning the scanner into a full functional AR reality screen.

---

*Built with precision. Designed for health. 🥗*
