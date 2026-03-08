<div align="center">

# 🥗 Personalized Food Intelligence App

### *Beyond calories. Beyond macros. Built for YOU.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active%20Dev-brightgreen?style=for-the-badge)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-ff69b4?style=for-the-badge)](CONTRIBUTING.md)

<br/>

> A Flutter-based health app that analyzes packaged food products and delivers a **personalized suitability verdict** based on your unique health profile, goals, and conditions.

<br/>

---

</div>

## 🚀 Project Vision

Most apps just show you numbers. This one **reasons** about them.

Instead of only showing calories and macros, it:

- 📸 Scans food labels or barcodes
- 🔬 Analyzes nutritional data in real-time
- 🔗 Cross-references with your personal health profile
- 🎯 Delivers an instant verdict → **Good / Caution / Avoid**

> **Goal:** Help users make smarter food decisions — instantly.

---

## 🧠 Core Concept

```
👤 Your Profile  +  📸 Food Scan  ──▶  🧠 Inference Engine  ──▶  ✅ Verdict
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
| 🎯 **Dart** | Typed, compiled language |
| 🏗️ **Feature-First Architecture** | Modular, scalable structure |
| 🌗 **Dynamic Theming** | Runtime Light / Dark mode switching |
| 🔌 **API-Ready Layer** | Pluggable backend integration |

---

## 📁 Project Mapping

A detailed breakdown of the codebase and its responsibilities:

| Folder / File | Responsibility |
|---------------|----------------|
| **`lib/core/theme/`** | Material 3 design system, curated color palettes, and global component styles. |
| **`lib/features/home/`** | The "Pulse" of the app. Dashboard, weekly analytics, and real-time alerts. |
| **`lib/features/home/services/meal_suggestion_service.dart`** | Generates personalized dietary advice based on today's scans and user profile. |
| **`lib/features/home/widgets/health_trend_chart.dart`** | Premium 7-day trend visualization using `fl_chart`. |
| **`lib/features/profile/`** | Handles user identity, health metrics, and conditions. |
| **`lib/features/profile/data/profile_repository.dart`** | Manages local persistence for user data using `shared_preferences`. |
| **`lib/features/profile/models/user_profile.dart`** | Definition of the user's biological and health profile. |
| **`lib/features/scan/`** | The core intelligence module (Scanning + Verdict Engine). |
| **`lib/features/scan/services/nutrition_service.dart`** | Connects to Open Food Facts API and runs the **Inference Engine** for verdicts. |
| **`lib/features/scan/services/risk_analysis_service.dart`** | Calculates safety trends and weekly health scores. |
| **`lib/features/scan/data/scan_repository.dart`** | Persists recent scan history for analytics. |
| **`lib/features/scan/presentation/verdict_screen.dart`** | Displays the suitability result with ingredient chips. |
| **`lib/features/navigation/`** | Material 3 Bottom Navigation implementation. |
| **`lib/app.dart`** | Global app state, including **theme persistence**. |

---

## 📜 Log of Changes

### **📅 2026-03-08: The Intelligence Upgrade**
*   **Health Trends:** Integrated `fl_chart` to visualize a **7-Day Risk Pattern Graph**.
*   **Decision Support:** Created `MealSuggestionService` for context-aware health advice.
*   **Proactive Alerts:** Added **Smart Warnings** on the dashboard for high-risk consumption today.
*   **Verdict Logic:** Expanded the engine to flag **Ultra-Processed Additives** and explain their impact.
*   **UI Overhaul:** 
    *   `ProfileScreen`: Upgraded to a premium Sliver-based scroll layout.
    *   `VerdictScreen`: Added interactive ingredient chips for better scannability.
    *   `HomeScreen`: Unified trends, alerts, and recent history into a single dashboard.
*   **Persistence:** Added support for **Theme Memory** (app remembers Dark/Light mode).

### **📅 Pre-2026-03-08: Core Foundation**
*   Automated Health Profile Onboarding.
*   Barcode Scanner implementation with premium overlays.
*   Open Food Facts API integration.
*   Feature-first architecture setup.

---

## 🤖 AI Handoff Prompt

*If you wish to continue building this app using another AI model, use the following prompt to give it perfect context:*

> "You are a senior Flutter developer. You are taking over a project called **NutriDecide**, a personalized nutrition intelligence app.
> 
> **Tech Stack:** Flutter (Material 3), Feature-First Architecture, `shared_preferences` (persistence), `mobile_scanner` (barcode tech), `fl_chart` (analytics), and Open Food Facts API.
> 
> **Current State:**
> - User Onboarding & Health Profile setup are complete.
> - **Inference Engine:** Located in `nutrition_service.dart`. It cross-references product ingredients with user conditions (Diabetes, Hypertension, Vegan, etc.).
> - **Dashboard:** Features real-time Health Trend Graphs, Smart Recommendations, and Scan History.
> - **Persistence:** Profile, Scan History, and Theme settings are all locally saved.
> 
> **Architecture Goal:** Keep it 'Better Product' ready. Prioritize premium aesthetics (Slivers, micro-animations) and maintain clean separation between services (data fetching/logic) and UI.
> 
> **Immediate Tasks to Continue Building:**
> 1.  **Safety Swaps:** In the `VerdictScreen`, suggest a 'Better Alternative' if the scanned item is marked as AVOID.
> 2.  **Nutrient Logs:** Add a dedicated screen to track protein/fiber/sugar intake over time.
> 3.  **Meal Planner:** Expand the current `MealSuggestionService` into a full daily meal generator."

---

## ✅ Current Features

| Feature | Status |
|---------|--------|
| Login & Signup UI | ✅ Live |
| Full Health Profile Setup | ✅ Live |
| Bottom Navigation | ✅ Live |
| Profile Screen (Sliver UI) | ✅ Live |
| Settings Screen | ✅ Live |
| Dark Mode Toggle & Persistence | ✅ Live |
| Barcode Scanner | ✅ Live |
| Open Food Facts API | ✅ Live |
| Verdict Engine (Inference) | ✅ Live |
| 7-Day Health Trend Graph | ✅ Live |
| Smart Health Suggestions | ✅ Live |
| Smart Alert Banner | ✅ Live |
| Actionable Product Feedback | ✅ Live |

---

## 🚧 Roadmap

```
Phase 1 (Complete)   ──▶   Auth + Profile + Settings + Dark Mode
Phase 2 (Complete)   ──▶   Barcode Scan + Food API + Verdict Engine
Phase 3 (Current)    ──▶   Risk Patterns + Trend Tracking + Guidance
Phase 4 (Next)       ──▶   Dietary AI + Alternative Swaps + Logs
```

---

## 🛡️ Privacy & Disclaimer

> ⚕️ This app provides food analysis suggestions based on user-provided information.
> It does **not** provide medical diagnosis or professional medical advice.
> Always consult a qualified healthcare professional for medical decisions.

---

<div align="center">

**🥗 NutriDecide** · Analytics-Driven Health · Built with Flutter

*Preventive health, reimagined.*

</div>