<div align="center">

# 🥗 Personalized Food Intelligence App

### *Beyond calories. Beyond macros. Built for YOU.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active%20Dev-brightgreen?style=for-the-badge)]()

<br/>

> A Flutter-based health app that analyzes packaged food products and delivers a **personalized suitability verdict** based on your unique health profile, goals, and conditions. Now with **Voice AI** for regional food logging.

<br/>

---

</div>

## 📄 Technical Documentation
For a deep dive into the system architecture, performance optimizations (O(1) lookup), and the core inference engines, please refer to the [Technical Documentation](.gemini/antigravity/brain/21f6820e-3455-4762-acd6-c32306178aa9/DOCUMENTATION.md).

<br/>

## 🚀 Project Vision

Most apps just show you numbers. This one **reasons** about them.

Instead of only showing calories and macros, it:

- 📸 Scans food labels or barcodes
- 🎙️ **New:** Log regional street foods via Voice AI
- 🔬 **Regional Analysis:** Backend-driven tracking for foods that lack universal barcodes.
- 🔗 Cross-references with your personal health profile
- 🎯 Delivers an instant verdict → **Good / Caution / Avoid**

> **Goal:** Help users make smarter food decisions — instantly.

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

### 3️⃣ Run the App (Fedora Instructions)

#### **Step A: Start MongoDB**
Fedora uses `systemctl`. Ensure the service is running:
```bash
sudo systemctl start mongod
sudo systemctl enable mongod
# Check status: sudo systemctl status mongod
```

#### **Step B: Start Backend**
```bash
cd backend
npm run dev
# Confirm "✅ Connected to MongoDB" appears
```

#### **Step C: Configure Firewall (Optional)**
If your phone cannot connect to the backend, Fedora's firewall might be blocking port 5000:
```bash
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

#### **Step D: Launch Flutter**
Ensure your device/emulator is connected:
```bash
flutter run
```

---

## 🧠 Core Concept

```
👤 Profile  +  📸 Scan / 🎙️ Voice  ──▶  🧠 Inference Engine  ──▶  ✅ Verdict
```

The app collects relevant health data:

| Field | Examples |
|-------|----------|
| 🧍 Personal | Age, Height, Weight, Gender |
| 🏃 Lifestyle | Activity Level, Goals (Loss / Maintain / Gain) |
| 🏥 Conditions | Diabetes, Hypertension, Thyroid, etc. |
| ⚠️ Allergies | Gluten, Lactose, Nuts, etc. |

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
| 🟢 **Node.js** | Backend API server |
| 🍃 **MongoDB** | Regional food database |
| 🎯 **Dart** | Typed, compiled language |
| 🏗️ **Feature Architecture** | Modular, scalable structure |
| 🎙️ **Speech-to-Text** | AI-driven voice input |
| 🌗 **Dynamic Theming** | Premium Emerald & Amber theme |

---

## 📁 Project Mapping

A detailed breakdown of the codebase and its responsibilities:

| Folder / File | Responsibility |
|---------------|----------------|
| **`backend/`** | Node.js/Express server with MongoDB for regional food data. |
| **`lib/core/theme/`** | Premium Emerald & Amber design system with Outfit typography. |
| **`lib/features/home/`** | Dashboard, health trends, and **AI Pattern Coach**. |
| **`lib/features/home/voice_log_screen.dart`** | Implementation of **Voice Food Logging** for regional dishes. |
| **`lib/features/home/services/pattern_coach_service.dart`** | AI-driven behavioral behavioral insights and coaching. |
| **`lib/features/regional/`** | Logic for identifying and analyzing local/street foods. |
| **`lib/features/scan/`** | The core intelligence module (Scanning + Verdict Engine). |
| **`lib/features/scan/services/nutrition_service.dart`** | Connects to Open Food Facts API and runs the **Inference Engine**. |
| **`lib/features/scan/presentation/verdict_screen.dart`** | Displays product results and **Healthier Alternatives**. |
| **`lib/app.dart`** | Global app state and feature management. |

---

## 📜 Log of Changes

### **📅 2026-03-11: V1.5 Offline Architecture & Ingredient Intelligence**
*   **Offline Data System:** Converted barcode product queries to scan natively against a local JSON dataset, eliminating external API usage and enabling app use without Wi-Fi.
*   **Ingredient Analyzer:** Integrated advanced regex logic to detect red-line food additives and processing methods (E102, MSG, Sucralose, Hydrogenated oils).
*   **Gym / Fitness Mode:** Rewrote inference engine logic to intelligently apply stricter sugar thresholds and anti-artificial-sweetener rules if a user is operating on a 'Fitness / Gym' plan.
*   **Flow Optimization:** Streamlined UI from a 2-tap to a highly responsive 1-tap "Scan to Verdict" system.

### **📅 2026-03-10: Branding & Vision Refinement**
*   **Dynamic Theme Logos:** Implemented theme-aware logo assets (`logo_black_bg.png`, `logo_white_bg.png`) that adapt to the user's system preferences.
*   **Animated Splash Screen:** Engineered a premium entry experience with an `easeIn` fade transition and unified branding.
*   **Moonshot AR Overlay:** Upgraded the Beta AR toggle to display real-time animated data nodes (Calorie Est, Allergy Warnings) layered over the live camera feed.
*   **Voice AI Engine:** Refactored natural language processing to handle portion multipliers (e.g., "half"), complex combinations (e.g., "idli and fish curry"), and phonetic typos.

### **📅 2026-03-08: The Innovation Leap (Phase 4 & 5)**
*   **Backend Integration:** Launched a Node.js/MongoDB backend to serve real-time regional food data.
*   **Voice Regional AI:** Implemented voice logging for local dishes (e.g., Puttu, Appam) with automatic portion estimation.
*   **AI Pattern Coach:** A new dashboard section providing behavioral insights like *"Sunday Sodium Spike"* warnings.
*   **Swap Engine:** Integrated a recommendation engine to suggest healthier alternatives for "Caution" or "Avoid" items.
*   **Safety Swaps Network:** Added an "Upvote" system to simulate community-driven healthy food discovery.
*   **Theme Refinement:** Migrated to a much more premium **Emerald and Amber** aesthetic with Google Fonts (Outfit).

### **📅 2026-03-08: The Intelligence Upgrade**
*   **Health Trends:** Integrated `fl_chart` to visualize a **7-Day Risk Pattern Graph**.
*   **Decision Support:** Created `MealSuggestionService` for context-aware health advice.
*   **Verdict Logic:** Expanded the engine to flag **Ultra-Processed Additives**.

---

## 🤖 AI Handoff Prompt

*If you wish to continue building this app using another AI model, use the following prompt to give it perfect context:*

> "You are a senior Full-Stack Flutter developer. You are taking over **NutriDecide**, a personalized nutrition intelligence app.
> 
> **Tech Stack:** Flutter (Premium Theme), Node.js/Express Backend, MongoDB, `speech_to_text`, `mobile_scanner`, and Open Food Facts API.
> 
>### **V1.3: The Innovation Leap (Current)**
- **Backend Integration:** Connected to a live Node.js/MongoDB cluster for regional data.
- **Voice Food Logging:** Users talk to the app to log traditional meals.
- **AI Coaching:** The `PatternCoachService` provides deep behavioral insights (e.g., "Sunday Sodium Spike").
- **Swap Engine:** Proactive suggestions for "Better Alternatives" using category-based API searches.
- **Moonshot AR (Conceptual):** A UI-driven simulation of real-time label analysis, demonstrating the vision for barcode-free scanning in future releases.

> **Current State:**
> - **Inference Engine:** Fully functional in `nutrition_service.dart`.
> - **Voice Logging:** Users can log regional foods via voice; data is fetched from the MongoDB backend.
> - **Safety Swaps:** Suggests healthier alternatives using category-based search from the API.
> - **Pattern Coach:** Analyzes history for behavioral insights (e.g., Sugar Risks).
> 
> **Immediate Tasks:**
> 1.  **Family Sharing:** Implement a 'Family Mode' where parents can track kids' allergy risks.
> 2.  **Festival Foods:** Create a specific module for high-calorie festive seasons (like Onam/Diwali) with healthy preparation tips.
> 3.  **Real AR:** Transition the "Moonshot" AR button into a functional overlay using ARCore/ARKit."

---

## ✅ Current Features

| Feature | Status |
|---------|--------|
| Premium Login & Signup | ✅ Live |
| Full Health DNA Profile | ✅ Live |
| Barcode Scanner + AR Toggle | ✅ Live |
| **Voice Regional AI Logging**| ✅ Live |
| **Node.js/MongoDB Backend** | ✅ Live |
| **AI Pattern Coach** | ✅ Live |
| **Healthier Swap Engine** | ✅ Live |
| 7-Day Health Trend Graph | ✅ Live |
| Smart Alert Banner | ✅ Live |
| Community Upvote Swaps | ✅ Live |

---

## 🚧 Roadmap

```
Phase 1 (Complete)   ──▶   Auth + Profile + Settings + Dark Mode
Phase 2 (Complete)   ──▶   Barcode Scan + Food API + Verdict Engine
Phase 3 (Complete)   ──▶   Risk Patterns + Trend Tracking + Guidance
Phase 4 (Complete)   ──▶   Voice AI + Swap Engine + Backend Integration
Phase 5 (Current)    ──▶   AI Coaching + Family Sharing + Festival Mode
```

---

## 🛡️ Privacy & Disclaimer

> ⚕️ This app provides food analysis suggestions based on user-provided information.
> It does **not** provide medical diagnosis or professional medical advice.
> Always consult a qualified healthcare professional for medical decisions.

---

<div align="center">

**🥗 NutriDecide** · Innovation-Driven Health · Built with Flutter & Node.js

*Preventive health, reimagined.*

</div>
