# 🎓 Learning NutriDecide: Technical Blueprint & Evolution

Welcome to the **NutriDecide** knowledge base. This document is a comprehensive guide for developers and stakeholders to understand the technical architecture, design philosophy, and evolutionary path of the application.

---

## 🏛️ Architectural Framework
NutriDecide is built using a **Feature-First Clean Architecture**, now expanded with a robust **Node.js/Express** backend and MongoDB integration.

### **Core Layers**
- **Presentation:** UI widgets and state management (StatefulWidgets). Focuses on high-fidelity user experience (Slivers, micro-animations, and custom graphics).
- **Data (Repository):** Manages local persistence using `shared_preferences`. Abstracts data source complexity from the UI.
- **Backend (API):** A flexible Node.js environment to handle regional food data that is not available in global databases like Open Food Facts.
- **Inference Engine:** Located in the Domain/Services layer, it cross-references scanned/logged food data with the user's **Health DNA** profile.

---

## 🛠️ Technical Stack & Dependencies

| Library / Tech | Role in NutriDecide |
|---------|--------------------|
| **`mobile_scanner`** | High-performance, low-latency live barcode detection. |
| **`Node.js & MongoDB`** | Live backend to serve regional dishes (Puttu, Appam, etc.). |
| **`speech_to_text`** | Core engine for **Voice Food Logging** for street foods. |
| **`fl_chart`** | Dynamic, GPU-accelerated visualization of health trends and risk scores. |
| **`google_fonts`** | Implements the premium **Outfit** typography. |
| **`lottie`** | Rich, performant vector animations for voice feedback and success screens. |
| **`shared_preferences`** | Lightweight cross-platform persistence for user profiles and settings. |

---

## 🎙️ The Innovation Engine: Voice & Backend
The project's latest evolution focuses on **Regional AI**. Many foods in India (like traditional Kerala dishes) lack barcodes and global database entries.

1.  **Node.js Service:** A dedicated API serving a curated MongoDB database of regional foods.
2.  **Voice Recognition:** Integrated `speech_to_text` with specialized portion-parsing logic (e.g., "2 parotta and fish curry").
3.  **Automatic Estimation:** The `RegionalFoodService` estimates calorie/nutrient loads based on standard portions if the user speaks natural language.

---

## 📈 Evolutionary Milestones

### **V1.0: Foundation**
- Implementation of the **Health DNA** onboarding flow.
- Structured the feature-first directory layout.

### **V1.1: Live Intelligence**
- Integrated barcode identification and connected to **Open Food Facts API**.
- Built the first production version of the **Verdict Screen**.

### **V1.2: Premium Analytics & Guidance**
- **Health Trends:** Weekly risk visualization and contextual guidance using `MealSuggestionService`.
- **UI Refinement:** Full Material 3 overhaul with theme persistence.

### **V1.3: The Innovation Leap (Current)**
- **Backend Integration:** Connected to a live Node.js/MongoDB cluster for regional data.
- **Voice Food Logging:** Users talk to the app to log traditional meals.
- **AI Coaching:** The `PatternCoachService` provides deep behavioral insights (e.g., "Sunday Sodium Spike").
- **Swap Engine:** Proactive suggestions for "Better Alternatives" using category-based API searches.

---

## 🗺️ Information Mapping

If you want to understand a specific feature, look here:

- **"Where is the backend source?"** → `/backend/` directory (Express/MongoDB).
- **"How does the swap engine work?"** → `lib/features/scan/services/nutrition_service.dart` (`fetchAlternatives`).
- **"Where do I find the voice AI logic?"** → `lib/features/home/voice_log_screen.dart`.
- **"How are behavioral patterns analyzed?"** → `lib/features/home/services/pattern_coach_service.dart`.
- **"Where is the premium theme defined?"** → `lib/core/theme/app_theme.dart`.

---

## 🚀 Vision for the Future
The project is architected for expansion into:
- **Family Hub:** Multi-profile management to track kids' allergy risks in one dashboard.
- **Festival Modes:** Dedicated UI modules for high-calorie festive seasons (Onam, Diwali, Christmas).
- **AR Label Vision:** Transitioning the "Moonshot" placeholder into a full functional ARCore reality screen.

---

*Built with precision. Designed for health. 🥗*
