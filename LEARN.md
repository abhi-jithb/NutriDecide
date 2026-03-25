# 🎓 Master Guide: NutriDecide Core Working & Architecture (v1.5)

This document is the definitive technical blueprint of the NutriDecide production system. It explains **exactly how the app thinks**, the logic behind each verdict, and the specific code implementation for every core feature.

---

## 🏛️ 1. Systems Overview & Workflow

NutriDecide translates complex biochemical data (Nutrition Facts + Ingredients) into a simple, personalized verdict (**GOOD / CAUTION / AVOID**). 

### **The Journey of a Scan (End-to-End)**
1.  **Scanner Phase:** `ScanScreen` captures a barcode using `mobile_scanner`.
2.  **Acquisition Phase:** `NutritionService` performs a **Hybrid Lookup** (Hive ➡️ OpenFoodFacts API).
3.  **Intelligence Phase:** 
    - `IngredientAnalyzer` parses raw strings for processing markers.
    - `ScoringEngine` calculates a **Personalized Risk Score**.
4.  **Verdict Phase:** `VerdictScreen` displays the result with reasons and **Safety Swaps**.

---

## 🧠 2. Deep Dive: Key Code Implementations

### **A. Intelligence Engine (The "Brain")**
Located in: `lib/features/scan/services/scoring_engine.dart`

> [!IMPORTANT]
> This is a **Weighted Risk Algorithm**. It doesn't just look at calories; it looks at how those calories interact with the user's specific medical conditions.

#### **Specific Code Explanations:**
- **Lines 15-20 (Nutrient Extraction):** We normalize raw data from various sources into a 100g standard.
- **Lines 23-28 (Condition-Based Weighting):** 
  - `if (profile.hasDiabetes) sugarBase *= 2.0;`
  - This line ensures that a product with 15g of sugar might be "CAUTION" for a normal user but an immediate "AVOID" for a diabetic.
- **Lines 77-81 (The Allergy Blocker):** 
  - `if (product.ingredients.any((ing) => ing.toLowerCase().contains(allergy.toLowerCase()))) { return 100.0; }`
  - This is a fail-safe. If an ingredient matches a user's allergy, the score is immediately set to 100 (Maximum Risk/Avoid).
- **Line 84-89 (Dietary Compliance):** Hard-coded animal-product check for Vegan profiles.

---

### **B. Hybrid Data Acquisition (Offline First)**
Located in: `lib/features/scan/services/nutrition_service.dart`

#### **How it works:**
1.  **Phase 1 (Local):** `fetchProductData` (Line 18) first checks `FoodDatabaseService` (Hive). This is $O(1)$ and works offline.
2.  **Phase 2 (Cloud Fallback):** If local records fail, it triggers a `http.get` to OpenFoodFacts (Line 27) with a **4-second strict timeout**.
3.  **Phase 3 (Active Caching):** If the API returns valid data, we automatically cross-validate it (`remoteData.isComplete` at Line 37) and save it to the local Hive database for future offline use.

---

### **C. Startup & Parallelization**
Located in: `lib/core/services/app_initializer.dart`

To ensure a "Premium" feel, the app must boot in under 2 seconds.
- **Line 28 (`Future.wait`):** We boot **Infrastructure** (DotEnv, Firebase, Hive) in parallel.
- **Line 35 (`initializeDatabase`):** We index the curated 20,000 product JSON dataset into Hive so that first-time scans are instantaneous.
- **Line 56 (`Firebase.initializeApp`):** Protected initialization to prevent crashes when Google Services are missing (e.g., development environments).

---

## 🛰️ 3. Backend Architecture (Node.js + MongoDB)

Located in: `backend/`
Hosted on: **Render.com** (Production)

### **Key Logic:**
- **Manual Regional Food Search:** Since barcodes don't exist for "Fresh Puttu" or "Homemade Dosa," the backend serves a fuzzy-search API.
- **Health Endpoint:** (Line 31 in `BackendService.dart`) Used for uptime monitoring and reporting connection health to the user.
- **MongoDB Atlas:** Stores regional food data and health benchmarks that are too large for the mobile binary.

---

## 🛡️ 4. Stability & Production Decisions

NutriDecide reached "Production Ready" state by **removing misleading or broken components**:

| Removed Feature | Rationale | Final Code Status |
|---|---|---|
| **Voice Logging** | High latency and poor accuracy on low-end devices. | Entirely removed from `lib/features/voice`. |
| **AI Coach** | Purely simulation-based; lacked true science backing. | References removed from `BottomNav` and UI. |
| **AR Overlay** | Misleading; suggested real-time visual analysis of ingredients. | Removed from `ScanScreen`. |

---

## 🎨 5. The Design System (Material 3)

The app uses an **Adaptive Theme System** defined in `lib/core/theme/app_theme.dart`.

> [!TIP]
> **Pointing a code line:** 
> In `lib/features/profile/profile_screen.dart`, line 38 used to be `Colors.white`. This broke Dark Mode. It was updated to `Theme.of(context).scaffoldBackgroundColor` to ensure that standard Material 3 color tokens are respected.

### **Typography**
- **Outfit:** Used for headings to give a modern, health-tech feel.
- **Inter:** Used for body text for maximum readability of ingredient lists.

---

## 🚀 6. Future-Proofing for Developers

1.  **Adding a New Rule:** Go to `ScoringEngine.calculateRiskScore` and add a new weight condition based on `profile.conditions`.
2.  **Expanding Local Database:** Add a new entry to `assets/data/foods_clean.json` and it will be indexed into Hive on the next app boot.
3.  **Testing Environment:** Point `BACKEND_URL` in `.env` to `http://localhost:5000` to test regional food additions locally.

---

*This guide ensures that any engineer can maintain, audit, and improve the NutriDecide ecosystem while maintaining its core mission of **Health Clarity.*** 🥤
