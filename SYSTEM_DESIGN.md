# NutriDecide: Personalized Food Intelligence System
## System Design & Technical Documentation

---

## 1. Synopsis of the Project
NutriDecide is a mobile application designed to provide personalized food intelligence. By simply scanning the barcode of a packaged food product, users receive an immediate, customized health verdict (GOOD, CAUTION, or AVOID). This verdict calculation dynamically cross-references the product’s nutritional data and ingredient list against the user's specific health profile (including conditions like diabetes or hypertension and specific dietary preferences). To ensure maximum coverage, the system incorporates a fallback chain of data queries and allows manual user contributions verified by an administrative review process.

---

## 2. Introduction
In today's fast-paced world, an increasing number of dietary choices must be made quickly in grocery aisles, where packaged goods often obscure critical health impacts behind complex ingredient lists and generic nutritional labels. NutriDecide is built to decode and contextualize this information instantaneously. By linking an individual's unique health markers directly to the biochemical breakdown of consumer products, the app acts as a vigilant, pocket-sized nutritionist. 

---

## 3. Problem Statement
The primary real-world problem is the opacity of packaged food labeling. Consumers with specific health conditions (such as diabetes, hypertension, or PCOS) or dietary restrictions often struggle to interpret nutritional panels and ingredient lists effectively. 
Existing nutrition apps are largely generic calorie counters or macro trackers. They provide the raw data (e.g., "15g of sugar") but fail to provide the context (e.g., "15g of sugar is dangerous given your diabetic profile"). Furthermore, many existing tools fail entirely when encountering local or regional market products not found in major international databases.

---

## 4. Literature Review
Currently available dietary applications (like MyFitnessPal or LoseIt) focus heavily on caloric deficit tracking and macro balancing. Other scanning applications provide generic traffic-light systems based on standardized daily values. 
These approaches are insufficient because they lack deep personalization. A "traffic light" app might rate a product green for an average healthy adult, missing the critical nuance that its sodium content makes it a high-risk item for a hypertensive user. Additionally, reliance on single, online-only databases leaves significant gaps in functionality and product coverage, especially in developing or regional markets.

---

## 5. Proposed System
The proposed system, NutriDecide, shifts the paradigm from generic data display to personalized inference. 
**Key Functionalities:**
- Instant barcode scanning for product identification.
- Real-time nutritional analysis and ingredient parsing.
- A health-based scoring engine calculating risk against a personal profile.
- A definitive verdict system (GOOD / CAUTION / AVOID) with generated explanations.
- A manual, barcode-linked product entry system for missing items.
- A comprehensive admin approval system feeding a global product registry.
- Persistent daily logs and scan history for the user.

---

## 6. System Architecture
NutriDecide employs a hybrid, multi-layered architecture focused on speed and data resilience. 
- **Presentation Layer (Flutter):** Manages UI state, camera interactions, and form inputs.
- **Logic / Intelligence Layer (Dart Services):** Houses the `ScoringEngine` and `IngredientAnalyzer`.
- **Primary Data Layer (Firebase):** Handles authentication (Firebase Auth) and primary persistent state (Cloud Firestore) for user profiles, histories, and the crowdsourced product pipeline.
- **Local Cache Layer (Hive):** An offline-first, embedded NoSQL database providing O(1) lookups for a curated set of baseline products.
- **Remote / Fallback Layer:** Includes the Open Food Facts API and a Node.js/MongoDB backend structure for extended product querying and regional data.

---

## 7. Block Diagram

```text
                  ┌─────────────────┐
                  │                 │
                  │   User Profile  │
                  │   (Firestore)   │
                  │                 │
                  └────────┬────────┘
                           │
┌──────────────┐  ┌────────▼────────┐  ┌───────────────────┐  ┌──────────────┐
│              │  │                 │  │ Hive (Local DB)   │  │              │
│ Flutter App  ├──▶ Analysis Engine ├──▶ Firestore (Global)├──▶  Node.js API │
│ (Scanner UI) │  │ (Local Device)  │  │ OpenFoodFacts API │  │  (MongoDB)   │
│              │  │                 │  └───────────────────┘  │              │
└──────────────┘  └────────┬────────┘                         └──────────────┘
                           │
                  ┌────────▼────────┐
                  │                 │
                  │ Verdict Display │
                  │                 │
                  └─────────────────┘

                  ┌─────────────────┐
Flutter App   ───▶│ Firestore       │───▶ Admin Panel
(Manual Entry)    │(Pending Products)     (Approve/Reject)
                  └────────┬────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │ Firestore       │
                  │(Global Products)│
                  └─────────────────┘
```

---

## 8. Data Flow Diagram (DFD)

**Scan Flow:**
1. User scans barcode via device camera.
2. System requests data sequentially: User's Custom DB → Global Registry → Local Hive DB → External API.
3. System fetches stored User Profile.
4. Data and Profile enter the Scoring Engine.
5. System displays Verdict and logs the scan to the User's History.

**Manual Entry Flow:**
1. Barcode fails all lookup layers.
2. User selects "Add Manually".
3. User inputs Name, Category, Sugar, Calories.
4. System validates duplicate barcodes against `pending_products` and `global_products`.
5. System writes atomically to both `pending_products` (for admin) and `users/{uid}/custom_products` (for immediate user use).

**Admin Approval Flow:**
1. Admin opens Admin Panel.
2. System streams `pending_products`.
3. Admin selects "Approve". 
4. System fetches the fresh document from `pending_products`.
5. System executes a batch write: copy data to `global_products`, delete from `pending_products`.

---

## 9. Use Case Diagram

**Actors:** User, Admin

**Use Cases:**
- **User:**
  - Create Account / Login
  - Setup/Edit Health Profile (Age, Conditions, Allergies)
  - Scan Barcode
  - View Product Verdict and Explanation
  - Submit Unknown Product Manually
  - View Scan History
- **Admin (inherits User, plus):**
  - Access Admin Panel
  - View Streaming List of Pending Products
  - Approve Pending Food Items
  - Reject Pending Food Items
  - View List of All Registered Users and Roles

---

## 10. Database Design

The primary database is Cloud Firestore, structured via collections and subcollections.

**Collections:**
- `users`: Contains documents keyed by Firebase Auth UID. Stores profile data (role, health conditions).
  - Subcollection `history`: Stores lightweight log items (barcode, product name, verdict, timestamp).
  - Subcollection `custom_products`: Stores products manually submitted by this specific user.
- `pending_products`: Documents keyed by product Barcode. Awaiting administrative review.
- `global_products`: Documents keyed by product Barcode. Admin-approved items available to all users.

**Schema Example (pending_products / global_products):**
```json
{
  "barcode": "8901030776514",
  "name": "Maggi 2-Minute Noodles",
  "category": "Snacks",
  "sugar": 1.2,
  "calories": 427,
  "createdBy": "uid_string_123",
  "status": "pending_or_approved",
  "timestamp": "Firestore_Server_Timestamp"
}
```

---

## 11. ER Diagram

```text
      ┌───────────────┐
      │ USER PROFILE  │
      ├───────────────┤
      │ PK: uid       │
      │ role          │
      │ hasDiabetes   │
      │ ...           │
      └──────┬────────┘
             │ 1
             │
             │ M
      ┌──────▼────────┐
      │  SCAN HISTORY │
      ├───────────────┤
      │ PK: logId     │
      │ barcode       │
      │ verdict       │
      │ timestamp     │
      └───────────────┘

      ┌───────────────┐
      │   PRODUCT     │ (Abstract structure across pending/global/custom)
      ├───────────────┤
      │ PK: barcode   │
      │ name          │
      │ sugar         │
      │ createdBy (FK)│
      └───────────────┘
```
*(A User has many Scan History items. A User creates many Products. A Product is identified primarily by its Barcode).*

---

## 12. Core Algorithms

### A. Scan & Lookup Algorithm
Executed upon barcode detection. Strict priority waterfall:
1. `users/{uid}/custom_products/{barcode}` (Fastest remote, personalized).
2. `global_products/{barcode}` (Globally trusted remote).
3. Local Hive Database `getFoodByBarcode()` (O(1) offline cache).
4. External `http.get` to OpenFoodFacts (with a strict 4-second timeout).
Returns `NutritionData` object or triggers manual entry workflow.

### B. Decision Engine Algorithm
Calculates a cumulative risk score:
1. Establish base values for sugar, sodium, fat, calories.
2. Apply profile multipliers: e.g., `if (profile.hasDiabetes) sugarRisk = baseSugar * 2.5`.
3. Check for specific additives (e.g., MSG) or allergens (immediate score override to 100).
4. Output specific strings based on triggered thresholds.
5. Map score to Verdict: `<= 25` is GOOD, `<= 60` is CAUTION, `> 60` is AVOID.

### C. Manual Entry Algorithm
1. Receive input from UI form.
2. Query Firestore: `isDuplicate = pendingRef.exists || globalRef.exists`.
3. If duplicate, abort and alert user.
4. If unique, initiate a Firestore Batch Write.
5. Set document at `/pending_products/{barcode}`.
6. Set document at `/users/{uid}/custom_products/{barcode}`.
7. Commit Batch.

### D. Admin Approval Algorithm
1. Admin triggers approval for `{barcode}`.
2. Read *fresh* document from `/pending_products/{barcode}` to prevent data staleness.
3. Update specific fields (`status = approved`, `approvedBy = adminId`).
4. Initiate Firestore Batch Write.
5. Write full document to `/global_products/{barcode}`.
6. Delete document from `/pending_products/{barcode}`.
7. Commit Batch.

### E. Daily Logs Algorithm
1. Upon successful analysis completion, build a lightweight `ScanHistoryItem`.
2. Push object to the `users/{uid}/history` subcollection in Firestore with a server timestamp.

---

## 13. Proposed Methodology
1. **User Onboarding:** User registers and inputs health data (allergies, chronic conditions). Data secures in Firestore.
2. **Scanning Activity:** User points camera at a barcode. 
3. **Data Fetching:** The Multi-layer query executes immediately.
4. **Calculations:** Internal engine calculates the personalized risk. 
5. **Consumption/Contribution:** User views the final verdict. If no data was found, the app shifts the user smoothly into the contribution flow (Manual Entry).
6. **Community Curation:** Admins review incoming contribution streams, ensuring quality before deploying to the global dataset.

---

## 13A. Technology Responsibility Mapping

### Flutter
Responsible for the entire application frontend, user interactions, local state management, and interfacing directly with the device hardware (camera for barcodes).

### Firebase Authentication
Handles the creation, validation, and session management of users. Provides the immutable `uid` used to link records securely in the database.

### Firestore
The **Primary System Database**. Handles:
- All user profiles and preferences.
- The lifecycle of crowdsourced product data (`pending_products` and `global_products`).
- The persistent logging of scan histories.

### Hive
The **Local Offline Cache**. A lightweight NoSQL database running directly on the mobile device, providing high-speed baseline lookups for a pre-bundled curated dataset without network latency.

### Node.js Backend & MongoDB
The **Backend Support Layer**. Hosted externally, this provides an API layout for complex fuzzy searching, regional food specific calculations, and fallback data storage not suitable for mobile distribution.

*(Note: Firestore acts as the primary synchronization layer for all mobile data; MongoDB acts as the deep backend store for specific API services).*

---

## 14. Tools and Technology Used
- **Flutter / Dart:** Mobile application framework and language.
- **Firebase Auth / Cloud Firestore:** Cloud synchronization and identity management.
- **Hive:** Embedded device-level NoSQL storage.
- **mobile_scanner:** Flutter library for camera/barcode hardware parsing.
- **Node.js / Express:** Backend API server generation.
- **MongoDB:** Backend dataset cataloging.
- **http:** Dart library for external network API requests.

---

## 15. System Requirements

### Software Requirements
- **Mobile Environment:** Android 8.0+ / iOS 14.0+
- **Backend Environment:** Node.js v16+
- **Development Tools:** Flutter SDK ^3.10.4, Dart ^3.0

### Hardware Requirements
- **Mobile Device:** Functioning camera with autofocus capability, active internet connection (for cloud sync), roughly 100MB of free storage.
- **Backend Host:** Standard continuous hosting environment (e.g., Render, Heroku) with minimal RAM requirements.

---

## 16. Coding Synopsis
The project features a **Clean Feature-First** folder structure:
- `core/`: Contains fundamental logic, theme definitions, app initialization sequences, and the `admin_repository` and `food_database_service`.
- `features/`: The bulk of the application is isolated into feature packages:
  - `admin/`: UI specific to the Admin Panel.
  - `auth/`: Login, registration, profile building.
  - `home/`: Primary dashboard and high-level health metrics.
  - `profile/`: Model definitions and edit interfaces for the User configuration.
  - `scan/`: The core scanning infrastructure, analytical engines, parsing services, and history handling.
- **Key Modules:** The heaviest technical lifting occurs in `features/scan/services/` where the `scoring_engine.dart` translates data arrays into numeric risk vectors.

---

## 17. Output Synopsis
- **Scan Output:** A parsed structured object detailing protein, sugar, calories, and raw ingredients text.
- **Verdict Display:** A visual card prominently featuring a color-coded status (Green/Amber/Red), accompanied by distinct generated strings explaining *why* the verdict was reached (e.g., "Contains high sodium which conflicts with your Hypertension").
- **Admin Approval Result:** Quiet movement of a product document between Firestore collections, visible instantly in the UI via stream builder badge updates.
- **Logs Display:** A reverse-chronological list showing past scanned items and their resulting verdicts.

---

## 18. Advantages of the System
- **Deep Personalization:** Moves beyond static "healthy" labels by factoring in individual medical conditions.
- **Robust Data Pipeline:** Fails gracefully through 4 distinct fallback layers to ensure users always have a path forward.
- **Community Scalability:** Manual entry combined with an administrative checkpoint allows the database to grow safely according to user demand.
- **High Performance:** Hive caching ensures base scans evaluate in low milliseconds.

---

## 19. Limitations
- **Data Quality Reliance:** The system is only as good as the data source; OpenFoodFacts API responses or user-entered manual data can be incomplete or subtly inaccurate.
- **Barcode Dependency:** The strict architecture fails automatically when encountering unbarcoded regional or street foods.
- **Medical Disclaimer:** The algorithm is a guidance system, not a certified medical tool. 

---

## 20. Future Enhancements
- **OCR Integration:** The ability to photograph product ingredient lists and nutrition squares directly, bypassing the need for a barcode registry entirely.
- **AI Recommendation Engine:** Leveraging LLMs to suggest specific grocery alternatives based on historical scan patterns.
- **Wearable Integration:** Pulling continuous health metrics (like real-time glucose) to temporarily modify multiplier weights within the scoring engine.

---

## 21. Conclusion
NutriDecide demonstrates a functional, resilient architecture tackling an issue of modern consumer health opacity. By utilizing a hybrid lookup approach that bridges local High-speed local databases with robust, administrable Cloud solutions, the system ensures high data availability. Above all, the platform's core scoring engine succeeds in synthesizing complex macro-nutritional and ingredient data into highly personalized, immediately actionable insights for the user.
