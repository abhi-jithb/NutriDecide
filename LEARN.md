# 🎓 Learning NutriDecide: Technical Blueprint & Evolution

Welcome to the **NutriDecide** knowledge base. This document is a comprehensive guide for developers and stakeholders to understand the technical architecture, design philosophy, and evolutionary path of the application.

---

## 🏛️ Architectural Framework
NutriDecide is built using a **Feature-First Clean Architecture**, now expanded with a robust **Node.js/Express** backend and MongoDB integration.

### **Core Layers**
- **Inference Engine:** Located in the Domain/Services layer (`nutrition_service.dart`), it cross-references scanned/logged food data with the user's **Health DNA** profile.
- **Regional AI Service:** The `RegionalFoodService` handles communication with the Node.js backend, providing fuzzy search and combination detection for Kerala dishes.

---

## 🔍 Deep Dive: File & Module Architecture

### **1. Frontend (Flutter / Dart)**
Located in the `lib/` directory, organized by features:
- **`lib/features/scan/`**:
    - `scan_screen.dart`: Uses `mobile_scanner` with a manual `MobileScannerController` to fix memory/buffer issues.
    - `services/nutrition_service.dart`: The core logic that calculates verdicts based on health conditions (Diabetes, PCOS, Hypertension).
- **`lib/features/regional/`**:
    - `regional_food_service.dart`: The voice search brain. It handles spelling variants (e.g., "wada" -> "vada") and splits combined queries like "Appam and Chicken Curry".
- **`lib/features/home/`**:
    - `voice_log_screen.dart`: The UI for natural language input, featuring Lottie animations for a premium feel.
    - `home_screen.dart`: Dashboard with `fl_chart` for calorie/risk trends.

### **2. Backend (Node.js / Express)**
Located in the `backend/` directory:
- **`server.js`**: The entry point.
    - **Seeding Logic**: Automatically populates the database with traditional Kerala foods (Puttu, Fish Curry, Upma, etc.) on the first run.
    - **Search API**: Uses flexible regex searches to find foods by name, even if the user speaks partial words.
- **`.env`**: Stores the `PORT` and `MONGODB_URI`. Note: Use your local IP (e.g., `192.168.29.159`) for cross-device connectivity.

### **3. Database (MongoDB)**
- **Collection: `regionalfoods`**:
    - Stores structured nutrient data (`sugars_100g`, etc.), ingredients, and categories.
    - Enables the app to "know" about foods that aren't in the global **OpenFoodFacts** database.

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

### **V1.4: Branding & Vision Refinement (March 10, 2026)**
- **Dynamic Theming:** Deeply integrated true black/white adaptive brand assets (`logo_black_bg.png`, `logo_white_bg.png`).
- **Premium Initialization:** Engineered a smooth, `easeIn` animated Splash Screen.
- **Moonshot Upgrade:** Transformed the AR toggle into an animated, node-based overlay mimicking real-time OCR label processing.
- **NLU Precision:** Elevated the NLP engine logic to interpret natural human portioning ("half") and multi-dish combinations cleanly.

### **V1.5: Offline Architecture & Advanced Inference Engine (March 11, 2026)**
- **Offline Dataset System:** Migrated barcode scanning away from the OpenFoodFacts API to natively scan against `FoodDatabase` (`foods_clean.json`), operating completely offline.
- **Ingredient Analyzer Engine:** Added deep regex scanning for processing agents & additives (e.g. Sucralose, Aspartame, E102, Hydrogenated Oils, MSG).
- **Gym & Fitness Logic Module:** Built a specialized logical pathway triggering custom penalizations (anti-sugar/anti-artificial bounds) when the user profile explicitly operates under a 'Fitness / Gym' framework.
- **Micro-Optimization:** Removed intermediate 'Product Found' UI overlay, streamlining the 'One-Tap Scan' architectural flow.

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
