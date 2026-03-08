# 🎓 Learning NutriDecide: Technical Blueprint & Evolution

Welcome to the **NutriDecide** knowledge base. This document is a comprehensive guide for developers and stakeholders to understand the technical architecture, design philosophy, and evolutionary path of the application.

---

## 🏛️ Architectural Framework
NutriDecide is built using a **Feature-First Clean Architecture**. This approach ensures modularity, high testability, and a clear separation of concerns.

### **Core Layers**
- **Presentation:** UI widgets and state management (StatefulWidgets). Focuses on high-fidelity user experience and micro-animations.
- **Data (Repository):** Manages local persistence using `shared_preferences`. Abstracts data source complexity from the UI.
- **Domain (Services):** The "Brain" of the app. Handles business logic, API communication, and the **Nutritional Inference Engine**.

---

## 🛠️ Technical Stack & Dependencies

| Library | Role in NutriDecide |
|---------|--------------------|
| **`mobile_scanner`** | High-performance, low-latency live barcode detection. |
| **`http`** | Robust REST API communication with the **Open Food Facts** global database. |
| **`fl_chart`** | Dynamic, GPU-accelerated visualization of health trends and risk scores. |
| **`shared_preferences`** | Lightweight, cross-platform persistence for user profiles, history, and theme settings. |
| **`permission_handler`** | Seamless management of sensitive system permissions (Camera). |

---

## 🔬 The Inference Engine (`nutrition_service.dart`)
The heart of NutriDecide is its ability to **reason** about food data. Unlike apps that only show raw numbers, NutriDecide executes a multi-stage logic check:

1.  **Allergy Guard:** Constant-time lookup of user allergens against the product's ingredient list.
2.  **Condition Filtering:** Analyzes specific nutrient concentrations (e.g., sodium for Hypertension, sugars for Diabetes) to adjust risk points.
3.  **Dietary Compliance:** Validates ingredients against lifestyle types (e.g., Vegan, Vegetarian).
4.  **Additive Analysis:** Flags ultra-processed additives (artificial colors, high fructose corn syrup) for a balanced health verdict.

---

## 📈 Evolutionary Milestones

### **V1.0: Foundation**
- Implementation of the **Health DNA** onboarding flow.
- Structured the feature-first directory layout.
- Initial auth UI and navigation setup.

### **V1.1: Live Intelligence**
- Integrated `mobile_scanner` for near-instant product identification.
- Connected to **Open Food Facts API** for global coverage.
- Built the first production version of the **Verdict Screen**.

### **V1.2: Premium Analytics & Guidance (Current)**
- **Health Trends:** Weekly risk visualization using `fl_chart`.
- **Smart Alerts:** Real-time dashboard warnings for high-risk consumption patterns.
- **Contextual Guidance:** The `MealSuggestionService` provides bio-individual meal advice.
- **UI Refinement:** Full Material 3 overhaul with persistent Dark/Light mode support.

---

## 🗺️ Information Mapping

If you want to understand a specific feature, look here:

- **"Where is the logic for the health score?"** → `lib/features/scan/services/risk_analysis_service.dart`
- **"How does the app suggest meals?"** → `lib/features/home/services/meal_suggestion_service.dart`
- **"Where do I change the app's colors?"** → `lib/core/theme/app_theme.dart`
- **"How is the product analyzed?"** → `lib/features/scan/services/nutrition_service.dart`

---

## 🚀 Vision for the Future
The project is architected for expansion into:
- **Safety Swaps:** AI-generated healthy alternatives for "AVOID" rated products.
- **Precision Logging:** Full daily nutrient tracking.
- **Wearable Integration:** Real-time heart rate and activity correlation with food impact.

---

*Built with precision. Designed for health. 🥗*
