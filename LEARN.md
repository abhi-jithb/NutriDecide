# 🎓 NutriDecide — In-Depth Technical Documentation

This document is the definitive technical blueprint of the NutriDecide production system. It explains **exactly how the app thinks**, the data architecture, the admin workflow, and the specific code implementation for every core feature.

---

## 🏛️ 1. Systems Overview

NutriDecide translates complex biochemical data (Nutrition Facts + Ingredients) into a simple, personalized verdict (**GOOD / CAUTION / AVOID**).

### **The Journey of a Scan (End-to-End)**

```
┌─────────────┐     ┌──────────────────┐     ┌────────────────┐     ┌──────────────┐
│  Scanner    │ ──▶ │  Data Acquisition │ ──▶ │  Intelligence  │ ──▶ │   Verdict    │
│  Phase      │     │  Phase (4-layer)  │     │  Phase         │     │   Phase      │
│             │     │                   │     │                │     │              │
│ ScanScreen  │     │ NutritionService  │     │ Ingredient     │     │ VerdictScreen│
│ captures    │     │ checks 4 sources  │     │ Analyzer +     │     │ displays     │
│ barcode     │     │ in priority order │     │ ScoringEngine  │     │ result       │
└─────────────┘     └──────────────────┘     └────────────────┘     └──────────────┘
```

---

## 🔗 2. The Barcode-First Architecture

> **CRITICAL DESIGN DECISION:** Every product in the system is identified by its barcode. There are no auto-generated UUIDs, no random document IDs. The barcode IS the document ID across all Firestore collections.

### Why This Matters
- **Deduplication is free:** `pending_products/8901234567890` can only exist once
- **Lookup is O(1):** Direct document ID lookup, no queries needed
- **Cross-collection consistency:** Same barcode maps to same product everywhere
- **Future scans work instantly:** Once approved, any user scanning that barcode gets the result

### Document ID Convention
```
pending_products/{barcode}    ← e.g., pending_products/8901234567890
global_products/{barcode}     ← e.g., global_products/8901234567890
users/{uid}/custom_products/{barcode}
```

---

## 🔁 3. The 4-Phase Data Acquisition Pipeline

**File:** `lib/features/scan/services/nutrition_service.dart`

When a user scans a barcode, `fetchProductData(String barcode)` executes a strict priority waterfall:

### Phase 1: User Custom Products (Firestore)
```dart
final customDoc = await _firestore
    .collection('users').doc(uid)
    .collection('custom_products').doc(barcode)
    .get();
```
- **Purpose:** Check if the current user has previously submitted this product
- **Why first?** Gives immediate feedback for products the user themselves added
- **Latency:** ~100-200ms (Firestore network call)
- **Skipped if:** User not logged in (`uid == null`)

### Phase 2: Global Products (Firestore)
```dart
final globalDoc = await _firestore
    .collection('global_products').doc(barcode)
    .get();
```
- **Purpose:** Check if ANY admin has previously approved this barcode
- **Why second?** This is the community-validated, trusted data source
- **Latency:** ~100-200ms
- **Data source:** Admin-approved products with full nutritional data

### Phase 3: Local Hive Database
```dart
final localData = _dbService.getFoodByBarcode(barcode);
```
- **Purpose:** O(1) binary lookup against 20,000 pre-loaded Indian food products
- **Why third?** Zero network dependency, instant response
- **Latency:** <1ms (in-memory cache) or <50ms (disk read)
- **Data source:** Curated `assets/data/foods_clean.json` indexed into Hive on first boot

### Phase 4: Open Food Facts API
```dart
final response = await http.get(
    Uri.parse('$_baseUrl/$barcode.json'),
).timeout(const Duration(seconds: 4));
```
- **Purpose:** Last resort — global crowd-sourced food database
- **Why last?** Requires internet, higher latency, data quality varies
- **Timeout:** Strict 4-second cap for UX
- **Caching:** Valid results are saved back to Hive for future offline use

### If All 4 Fail
Returns `null` → triggers the "Product Not Found" bottom sheet with:
- **Try Again** — restarts scanner
- **Add Manually** — opens `ManualFoodEntryScreen` with the scanned barcode pre-populated

---

## 🧠 4. Intelligence Engine Deep Dive

### A. Ingredient Analyzer
**File:** `lib/features/scan/services/ingredient_analyzer.dart`

Parses raw ingredient strings for:
- **Harmful additives:** MSG, sodium nitrate, TBHQ, BHA/BHT
- **Refined sugars:** High fructose corn syrup, maltodextrin, dextrose
- **Artificial sweeteners:** Aspartame, sucralose, acesulfame
- **Processing markers:** E-numbers (E621, E211, etc.)

Returns an `IngredientAnalysisResult` with boolean flags and warning messages.

### B. Scoring Engine
**File:** `lib/features/scan/services/scoring_engine.dart`

Calculates a **Personalized Risk Score (0–100)** using weighted factors:

| Factor | Weight | Condition Multiplier |
|--------|--------|---------------------|
| Sugar >15g/100g | 1.5× per gram over | 2.5× for Diabetics |
| Sodium >400mg/100g | 2.5× per 100mg | 3.5× for Hypertension |
| Saturated Fat >5g/100g | 2.5× per gram over | 2.0× for PCOS |
| Calories >500kcal | +30 (weight loss) / +15 (others) | — |
| Harmful Additives | +20 fixed | — |
| Refined Sugars | +15 fixed | — |
| Artificial Sweeteners | +10 (+25 for Gym Mode) | — |
| Low Protein + High Cal | +20 (Gym Mode only) | — |
| High Fiber | -15 bonus (max) | — |
| High Protein (Gym) | -15 bonus (max) | — |
| Allergen Match | **→ 100 immediately** | — |
| Vegan Violation | **→ 100 immediately** | — |

#### Verdict Mapping
```
Risk 0–25   → ✅ GOOD
Risk 26–60  → ⚠️ CAUTION
Risk 61–100 → 🚫 AVOID
```

#### Confidence Correction
If `ConfidenceLevel == medium`, GOOD is demoted to CAUTION with explanation:
> "Some data is missing. Verdict is conservative."

### C. Confidence Level System
**File:** `lib/features/scan/models/nutrition_data.dart`

Products from different sources have different data completeness:

| Level | Criteria | Verdict Impact |
|-------|----------|---------------|
| **HIGH** | Name + Ingredients + Nutrients + Brand | Full analysis |
| **MEDIUM** | Name + Ingredients + Nutrients (no brand) | GOOD→CAUTION demotion |
| **LOW** | Name + (Ingredients OR Nutrients) | Auto-AVOID |
| **NONE** | Insufficient data | Auto-AVOID + "Safety cannot be verified" |

---

## ✍️ 5. Manual Product Entry System

**File:** `lib/features/scan/presentation/manual_entry_screen.dart`

### Entry Flow
1. User scans barcode → not found in any source
2. Bottom sheet offers "Add Manually"
3. `ManualFoodEntryScreen` receives the scanned `barcode` as constructor parameter
4. User fills form: Product Name*, Category*, Sugar* (0-100g), Calories (optional)

### Pre-Save Validation (Duplicate Guard)
```dart
// Check 1: Already pending?
final pendingDoc = await firestore.collection('pending_products').doc(barcode).get();
if (pendingDoc.exists) → "This product has already been submitted and is awaiting review."

// Check 2: Already globally approved?
final globalDoc = await firestore.collection('global_products').doc(barcode).get();
if (globalDoc.exists) → "This product already exists in the global database."
```

### Save Strategy (Batch Write)
Both writes happen atomically in a single Firestore batch:

```dart
final batch = firestore.batch();

// 1. For admin review
batch.set(firestore.collection('pending_products').doc(barcode), productData);

// 2. For user's immediate re-scan
batch.set(firestore.collection('users').doc(uid)
    .collection('custom_products').doc(barcode), productData);

await batch.commit();
```

### Saved Document Structure
```json
{
  "barcode": "8901234567890",
  "name": "Maggi Noodles",
  "category": "Snacks",
  "sugar": 4.5,
  "calories": 390,
  "createdBy": "user_uid_abc123",
  "status": "pending",
  "timestamp": "<server_timestamp>"
}
```

---

## 🛡️ 6. Admin System

### A. Role Management
**Collection:** `users/{uid}`

The `role` field in the user profile controls access:
```dart
class UserProfile {
  final String role; // "user" | "admin"
  // ... other fields
}
```

Admin check is performed when the Settings screen loads:
```dart
Future<bool> isAdmin(String uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  return doc.data()?['role'] == 'admin';
}
```

The Admin Panel tile in Settings is conditionally rendered:
```dart
if (_isAdmin)
  _settingsActionTile(
    title: "Admin Panel",
    icon: Icons.admin_panel_settings_outlined,
    onTap: () => Navigator.push(context, MaterialPageRoute(
      builder: (_) => const AdminPanelScreen(),
    )),
  ),
```

### B. Admin Panel UI
**File:** `lib/features/admin/admin_panel_screen.dart`

Two-tab interface:

**Tab 1: Pending Products**
- Real-time `StreamBuilder` listening to `pending_products` collection
- Live count badge on tab: `"Pending (3)"` powered by Material 3 `Badge` widget
- Each card shows: barcode, product name, category, sugar, calories
- Two actions: **Approve** (green) and **Reject** (red outline)

**Tab 2: Users**
- Streams all documents from `users` collection
- Shows: name, role (with amber highlight for admins), health conditions

### C. Approve Workflow (Critical Path)
```dart
Future<void> approveProduct(Map<String, dynamic> productData, String adminId) async {
  final barcode = productData['barcode'];
  
  // SAFETY: Read fresh data from Firestore (not stale stream snapshot)
  final pendingRef = _firestore.collection('pending_products').doc(barcode);
  final pendingSnap = await pendingRef.get();
  if (!pendingSnap.exists) throw Exception('Pending product no longer exists');

  final freshData = pendingSnap.data()!;
  freshData['status'] = 'approved';
  freshData['approvedBy'] = adminId;
  freshData['approvedAt'] = FieldValue.serverTimestamp();

  // Atomic batch: write to global + delete from pending
  final batch = _firestore.batch();
  batch.set(_firestore.collection('global_products').doc(barcode), freshData);
  batch.delete(pendingRef);
  await batch.commit();
}
```

**Why fresh read?** The `productData` from the StreamBuilder might be stale if another admin acted on it. Reading the document fresh ensures we copy ALL fields without data loss.

### D. Reject Workflow
Simple delete — removes the document from `pending_products`:
```dart
await _firestore.collection('pending_products').doc(barcode).delete();
```

---

## 🔐 7. Firestore Security Rules

**File:** `firestore.rules`

### Admin Detection Function
```javascript
function isAdmin() {
  return request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### Rule Summary

| Collection | Read | Write |
|------------|------|-------|
| `users/{uid}` | Owner + Admin | Owner only |
| `users/{uid}/history/*` | Owner only | Owner only |
| `users/{uid}/custom_products/*` | Owner only | Owner only |
| `pending_products/{barcode}` | Admin only | Any authenticated (create only) |
| `global_products/{barcode}` | Any authenticated | Admin only |

---

## 🐝 8. Hive Offline Database

**File:** `lib/core/data/food_database_service.dart`

### Architecture
- **Singleton pattern** with lazy initialization
- **One-time import:** On first boot, parses `foods_clean.json` (20k records) into Hive using `compute()` isolate to avoid jank
- **LRU Memory Cache:** Last 100 lookups cached in-memory for sub-millisecond access
- **Hybrid lookup chain:** Memory → Hive Disk → null

### Performance Characteristics
| Operation | Latency |
|-----------|---------|
| Memory cache hit | <1ms |
| Hive disk lookup | <50ms |
| Initial import (one-time) | ~2-4s |
| On-disk size | ~4.4 MB |

---

## ⚡ 9. Startup Sequence

**File:** `lib/core/services/app_initializer.dart`

```
main()
  └── Firebase.initializeApp()
        └── AppInitializer.initialize()
              ├── DotEnv.load()          ─┐
              ├── Hive.initFlutter()      ├── Future.wait() (Parallel)
              └── FoodDB.initialize()    ─┘
                    └── SplashScreen → AuthWrapper → BottomNavScreen
```

Target cold boot time: **<2 seconds** on mid-range devices.

---

## 🎨 10. Design System

**File:** `lib/core/theme/app_theme.dart`

- **Framework:** Material 3 with adaptive light/dark themes
- **Typography:** Outfit (headings) + Inter (body text)
- **Persistence:** Theme preference saved via `SharedPreferences`
- **Toggle:** Settings screen switch → `MyApp.of(context)?.toggleTheme(value)`

### Card Design Language
- Border radius: 16-24px
- Dark mode: subtle white borders at 5% opacity
- Light mode: grey borders + soft drop shadows
- Icon containers: circular with 10% opacity tinted backgrounds

---

## 📊 11. Data Models

### NutritionData
Core product data model with multiple factory constructors for different data sources:

| Factory | Source | Use Case |
|---------|--------|----------|
| `fromJson()` | Open Food Facts API response | Phase 4 lookup |
| `fromLocalMap()` | Hive stored data | Phase 3 lookup |
| `fromFirestore()` | Firestore documents | Phase 1 & 2 lookup |
| `toMap()` | Serialization | Saving to Hive |

### UserProfile
User health DNA with role-based access:
- Health metrics: age, height, weight, BMI goal
- Medical conditions: diabetes, hypertension, PCOS
- Dietary preferences: Vegan, Vegetarian, Fitness/Gym
- Access control: `role` field (`"user"` | `"admin"`)

### ScanHistoryItem
Lightweight scan record: barcode, product name, verdict, timestamp.

---

## 🚀 12. Future-Proofing

### Adding a New Scoring Rule
1. Open `scoring_engine.dart`
2. Add a new condition block in `calculateRiskScore()`
3. Add corresponding explanation in `generateReasons()`

### Expanding the Local Database
1. Add entries to `assets/data/foods_clean.json`
2. Increment `_dbVersionKey` in `food_database_service.dart` to trigger re-import

### Adding a New Admin Action
1. Add method to `AdminRepository`
2. Add UI trigger in `AdminPanelScreen`
3. Update `firestore.rules` if new collection access is needed

## 🛠 13. Scanner State Resilience & Bug Fixes

A critical architectural challenge involved intermittent "Try Again" scenarios where previously scanned products failed to load on the second application start. This was resolved through three key adjustments:
1. **AppInitializer Profile Caching:** Rather than forcing `ProfileRepository` to execute an asynchronous Firestore query on every scan (which fails on micro network-drops during Phase 4 lookup timeouts), the app instantly accesses the local `AppInitializer().currentUserProfile`.
2. **Hive Type Safe Casting:** Since `_foodBox.get()` returns complex nested structures as `Map<dynamic, dynamic>`, `NutritionData.fromLocalMap` was occasionally throwing silent cast exceptions. A top-level `try/catch` wrapper in `FoodDatabaseService` isolates offline storage errors from taking down the scanner.
3. **Optimized API Timeout:** OpenFoodFacts querying was extended from `4s` to `8s` to accommodate mobile data latency before executing the "Not Found" dialog gracefully.

---

## 📦 14. Creating & Distributing the APK

To manually build the standalone Android file for user testing outside of Google Play:
1. Ensure flutter dependencies are clean: `flutter clean && flutter pub get`
2. Run the release build pipeline: `flutter build apk --release`
3. The distributable file is generated at:
   👉 `build/app/outputs/flutter-apk/app-release.apk`
4. **Sharing:** It can be securely distributed directly via Google Drive, WhatsApp, or email attachments. Users will need to grant "Install Unknown Apps" permissions on their Android devices when opening it.

---

*This document ensures that any engineer can maintain, audit, and extend the NutriDecide ecosystem while understanding its complete data flow and architectural decisions.* 🥗
