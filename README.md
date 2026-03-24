<div align="center">

# 🥗 Personalized Food Intelligence App

### *Beyond calories. Beyond macros. Built for YOU.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=for-the-badge)]()

<br/>

> A Flutter-based health app that analyzes packaged food products and delivers a **personalized suitability verdict** based on your unique health profile, goals, and conditions. Now with **Offline-First Hive DB** and **Cloud Firestore** sync.

<br/>

---

</div>

## 📄 Technical Documentation
For a deep dive into the system architecture, performance optimizations (O(1) lookup), and the core inference engines, please refer to the [Technical Documentation](.gemini/antigravity/brain/21f6820e-3455-4762-acd6-c32306178aa9/DOCUMENTATION.md).

<br/>

## 🚀 Project Vision

Most apps just show you numbers. This one **reasons** about them.

Instead of only showing calories and macros, it:

- 📸 **1-Tap Scan:** Instant food analysis via barcode
- 🎙️ **Voice AI:** Log regional street foods via Voice AI
- 🔬 **Inference Engine:** Cross-references with your personal health DNA
- 🎯 **Offline-First:** 20,000 foods indexed locally via Hive
- ✨ **Cloud Sync:** Profile persistence via Firebase Firestore

---

## 🏗️ Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/abhi-jithb/NutriDecide.git
cd NutriDecide
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
cd backend && npm install
```

### 3️⃣ Configure Secrets
Create a `.env` file in the root:
```text
BACKEND_URL=https://your-api.onrender.com/api
```

---

## 🧠 Core Concept

```
👤 Profile (Firestore)  +  📸 Scan (Hive)  ──▶  🧠 Inference Engine  ──▶  ✅ Verdict
```

### Verdict System

| Verdict | Meaning |
|---------|---------|
| ✅ **GOOD** | Aligns with your goals and conditions. Safe to consume. |
| ⚠️ **CAUTION** | Moderate concern. May not suit your current health targets. |
| 🚫 **AVOID** | Conflicts with your profile or contains flagged ingredients. |

---

## 📦 Tech Stack

| Technology | Purpose |
|------------|---------|
| 💙 **Flutter** | Cross-platform UI framework |
| 🐝 **Hive** | High-performance offline food database |
| 🔥 **Firebase / Firestore** | Global Auth and User Profile synchronization |
| 🟢 **Node.js** | Regional food API server |
| 🛡️ **DotEnv** | Secure credentials management |
| 🎭 **Lottie** | Premium animations and micro-interactions |

---

## 📜 Log of Changes

### **📅 2026-03-24: V2.0 Production Hardening**
*   **Hive Migration:** Replaced JSON loading with binary-indexed Hive boxes for $O(1)$ lookup performance.
*   **Cloud Architecture:** Integrated Firebase Auth and Cloud Firestore for multi-device profile sync.
*   **UX Optimization:** Implemented "1-Tap Scan" logic with automatic scanner restarts.
*   **Crash Protection:** Added `GlobalErrorHandler` and error boundaries for production stability.
*   **Legal Compliance:** Created mandatory Medical Disclaimer and Privacy Policy screens.

### **📅 2026-03-11: V1.5 Offline Architecture**
*   **Offline Data System:** Native scan against local dataset.
*   **Ingredient Analyzer:** Advanced regex for red-line additives (MSG, E-numbers).
*   **Gym Mode:** Specialized auditing for sweeteners and protein density.

---

## 🤖 AI Handoff Prompt

> "You are a senior Full-Stack Flutter architect. You are taking over **NutriDecide**, a production-ready food intelligence app.
> 
> **Architecture:** Clean Feature-First.
> **Engines:** ScoringEngine (inference), IngredientAnalyzer (additives).
> **Data Layer:** Hive (Offline Food DB), Firestore (User DNA Profile).
> 
> **Immediate Focus:**
> 1. Handle Apple Health / Google Fit background syncing.
> 2. Implement Family Mode for communal allergy tracking.
> 3. Refine OCR labels for ingredient scanning without barcodes."

---

<div align="center">

**🥗 NutriDecide** · Innovation-Driven Health · Built with Flutter & Firebase

*Preventive health, reimagined.*

</div>
