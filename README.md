<div align="center">

# 🥗 NutriDecide — Personalized Food Intelligence App

### *Beyond calories. Beyond macros. Built for YOU.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=for-the-badge)]()

<br/>

> A Flutter-based health intelligence app that scans packaged food products and delivers a **personalized suitability verdict** based on your unique health profile, goals, and medical conditions. Features **Offline-First Hive DB**, **Cloud Firestore** profile sync, **Admin-Approved Global Product Registry**, and **Manual Product Submission**.

<br/>

---

</div>

## 📄 Technical Documentation

For an in-depth deep dive into the system architecture, data flow, performance optimizations, and admin workflow, see **[LEARN.md](LEARN.md)**.

<br/>

## 🚀 Project Vision

Most nutrition apps just show you numbers. NutriDecide **reasons** about them.

- 📸 **1-Tap Scan:** Instant food analysis via barcode
- 🧠 **Inference Engine:** Cross-references nutrients with your personal health DNA
- 🎯 **Offline-First:** 20,000 foods indexed locally via Hive (O(1) lookup)
- ☁️ **Cloud Sync:** Profile persistence via Firebase Firestore
- 🔄 **Community-Driven Database:** Users submit unknown products → Admins approve → Available globally
- 🛡️ **Admin System:** Role-based admin panel for product review and user management

---

## 🔁 Core Product Flow

```
 Scan Barcode
      │
      ▼
 ┌──────────────────────────────────────────────┐
 │  1. Check user's custom_products/{barcode}   │
 │  2. Check global_products/{barcode}          │
 │  3. Check local Hive DB (20k foods)          │
 │  4. Check Open Food Facts API               │
 └──────────────────────────────────────────────┘
      │                        │
   Found                   Not Found
      │                        │
      ▼                        ▼
  Analyze &             ┌─────────────┐
  Show Verdict          │ Try Again   │
                        │ Add Manually│
                        └──────┬──────┘
                               │
                               ▼
                    Save to pending_products/{barcode}
                    Save to user custom_products/{barcode}
                               │
                               ▼
                     Admin Reviews & Approves
                               │
                               ▼
                    Moved to global_products/{barcode}
                               │
                               ▼
                    ✅ Available to ALL users forever
```

---

## ✨ Key Features

### 🔍 Smart Barcode Scanning
- Camera-based barcode detection with `mobile_scanner`
- 4-phase fallback data acquisition (Custom → Global → Hive → API)
- Automatic caching of API results for future offline use

### 🧠 Personalized Health Verdicts
- **Weighted Risk Algorithm** that factors in diabetes, hypertension, PCOS, allergies
- Specialized **Gym/Fitness Mode** with protein density scoring
- Vegan/Vegetarian dietary compliance checks
- Instant allergen detection with fail-safe blocking

### ✍️ Manual Product Entry (Barcode-Linked)
- When a scan finds no data, users can contribute product information
- Barcode is the **primary key** — no random UUIDs
- Saves to both `pending_products` (for admin review) and `custom_products` (for immediate user access)
- Duplicate barcode detection prevents duplicates
- Validation: Sugar (0–100g), required fields enforced

### 🛡️ Admin Panel
- **Role-based access** — visible only when `users/{uid}.role == "admin"`
- **Pending Products tab** — real-time stream with live count badge
- **Approve** → copies full document from `pending_products` to `global_products` (batch write)
- **Reject** → deletes from `pending_products`
- **Users tab** — list all users with health profiles and conditions
- Fresh Firestore read on approve to prevent data loss from stale snapshots

### 👤 User Profiles (Health DNA)
- Complete health profile: age, weight, height, conditions, allergies, diet type
- Synced to Cloud Firestore for multi-device access
- Role field (`user` | `admin`) for access control

### 📊 Scan History & Daily Logs
- Scan history persisted in `users/{uid}/history`
- Recent scans displayed on home screen
- Full history view with streak tracking

---

## 📦 Tech Stack

| Technology | Purpose |
|------------|---------|
| 💙 **Flutter** | Cross-platform UI framework |
| 🐝 **Hive** | High-performance offline food database (O(1) barcode lookup) |
| 🔥 **Firebase Auth** | User authentication |
| ☁️ **Cloud Firestore** | User profiles, pending/global products, scan history |
| 🟢 **Node.js** | Optional regional food API server |
| 🍃 **MongoDB** | Optional backend data store |
| 🛡️ **DotEnv** | Secure credentials management |

---

## 🏗️ Getting Started

### 1️⃣ Clone the Repository

```bash
git clone git@github.com:abhi-jithb/NutriDecide.git
cd NutriDecide
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Firebase
- Ensure `android/app/google-services.json` is present
- Create a `.env` file in root:
```text
BACKEND_URL=https://your-api.onrender.com/api
```

### 4️⃣ Run the App

```bash
flutter run
```

### 5️⃣ Make Yourself Admin
In **Firebase Console** → Firestore → `users/{your-uid}` → set field:
```json
{ "role": "admin" }
```

---

## 🏗️ Project Architecture

```
lib/
├── app.dart                          # MaterialApp with theme management
├── main.dart                         # Entry point
├── core/
│   ├── data/
│   │   ├── food_database_service.dart   # Hive-based offline food DB
│   │   └── admin_repository.dart        # Admin Firestore operations
│   ├── theme/app_theme.dart             # Material 3 design system
│   ├── services/
│   │   ├── app_initializer.dart         # Parallel boot sequence
│   │   └── global_error_handler.dart    # Production crash protection
│   └── presentation/splash_screen.dart
├── features/
│   ├── admin/
│   │   └── admin_panel_screen.dart      # Admin review panel (approve/reject)
│   ├── auth/
│   │   ├── services/auth_service.dart
│   │   └── presentation/               # Login, Signup, Profile Setup
│   ├── scan/
│   │   ├── scan_screen.dart             # Camera scanner
│   │   ├── models/
│   │   │   ├── nutrition_data.dart      # Product data model
│   │   │   └── scan_history_item.dart
│   │   ├── services/
│   │   │   ├── nutrition_service.dart   # 4-phase data lookup
│   │   │   ├── scoring_engine.dart      # Risk score calculator
│   │   │   └── ingredient_analyzer.dart # Additive detection
│   │   ├── data/scan_repository.dart    # Scan history persistence
│   │   └── presentation/
│   │       ├── verdict_screen.dart      # Results display
│   │       ├── manual_entry_screen.dart # Manual product form
│   │       └── history_screen.dart      # Scan history
│   ├── home/home_screen.dart            # Dashboard
│   ├── profile/                         # Health DNA profile
│   ├── settings/settings_screen.dart    # Preferences + admin access
│   └── navigation/bottom_nav_screen.dart
```

---

## 🔐 Firestore Collections

| Collection | Purpose | Access |
|------------|---------|--------|
| `users/{uid}` | User profile + role | Owner only (admin can read all) |
| `users/{uid}/history/{id}` | Scan history | Owner only |
| `users/{uid}/custom_products/{barcode}` | User's pending submissions | Owner only |
| `pending_products/{barcode}` | Products awaiting admin review | Auth create, Admin read/delete |
| `global_products/{barcode}` | Admin-approved products | Auth read, Admin write |

---

## 📜 Changelog

### **📅 2026-03-29: V3.0 — Admin System & Community Products**
* **Manual Product Entry:** Barcode-linked form with validation and duplicate detection
* **Admin Panel:** Two-tab admin interface with real-time pending count badges
* **Global Product Registry:** Admin approve/reject workflow with batch Firestore writes
* **Role Management:** `user`/`admin` roles via Firestore with conditional UI rendering
* **4-Phase Lookup:** custom_products → global_products → Hive → Open Food Facts API
* **Firestore Security Rules:** Full coverage for all new collections with admin guard functions
* **Safety Fixes:** Fresh Firestore read on approve, duplicate barcode guard on submit

### **📅 2026-03-24: V2.0 — Production Hardening**
* **Hive Migration:** Replaced JSON loading with binary-indexed Hive boxes for O(1) lookup
* **Cloud Architecture:** Firebase Auth + Cloud Firestore for multi-device profile sync
* **UX Optimization:** 1-Tap Scan logic with auto scanner restarts
* **Crash Protection:** GlobalErrorHandler and error boundaries
* **Legal Compliance:** Medical Disclaimer and Privacy Policy screens

### **📅 2026-03-11: V1.5 — Offline Architecture**
* **Offline Data System:** Native scan against local dataset
* **Ingredient Analyzer:** Advanced regex for red-line additives (MSG, E-numbers)
* **Gym Mode:** Specialized auditing for sweeteners and protein density

---

<div align="center">

**🥗 NutriDecide** · Community-Driven Health Intelligence · Built with Flutter & Firebase

*Preventive health, reimagined.*

</div>
