# Development & Hosting Guide

## How to Host This Application

NutriDecide encompasses a full-stack architecture. To launch it into a true production environment (usable outside of a local network), you must deploy both the frontend and the backend.

### 1. Database Hosting (MongoDB Atlas)
Currently, the app relies on a local MongoDB instance. For production:
1. Create a free cluster on [MongoDB Atlas](https://www.mongodb.com/cloud/atlas).
2. Create a database user and whitelist the IP `0.0.0.0/0` (allow all) so your backend can connect.
3. Retrieve your connection string (e.g., `mongodb+srv://<user>:<password>@cluster.mongodb.net/nutri_decide`).

### 2. Backend Hosting (Render / Heroku)
The Node.js backend needs to be hosted on a live server.
1. Sign up for [Render.com](https://render.com) (free tier is sufficient).
2. Create a "New Web Service" and link your GitHub repository.
3. Set the Root Directory to `backend/`.
4. Set the Build Command to `npm install`.
5. Set the Start Command to `npm start` (make sure you add `"start": "node server.js"` to your `package.json` scripts).
6. **Environment Variables**: Add your `MONGODB_URI` (from Atlas) and `PORT` (Render handles this automatically usually).
7. Once deployed, Render will give you a live URL (e.g., `https://nutridecide-api.onrender.com`).

### 3. Frontend Adjustments
Once the backend is live, you must tell the Flutter application where to find it.
1. Open `lib/features/regional/services/regional_food_service.dart`.
2. Find `_baseUrl` and update it from your local IP to the live API URL:
   ```dart
   static const String _baseUrl = 'https://nutridecide-api.onrender.com/api';
   ```

### 4. App Distribution
1. Build the production APK: `flutter build apk --release`.
2. Distribute via Google Play or standard APK sharing.

---

## Current Application Workflow
1. **User Scans/Speaks**: Input is captured via camera (`mobile_scanner`) or microphone (`speech_to_text`).
2. **Data Aggregation**: Standard barcodes hit the *OpenFoodFacts API*. Voice queries hit our custom *Node.js API* to search the MongoDB dataset, parse portions, and sum combination macros.
3. **Inference Engine**: `NutritionService` applies 0-100 risk scoring logic overlaid with condition-specific multipliers (Diabetes, Hypertension, PCOS) using the user's saved Health profile.
4. **Verdict Generation**: A final state (GOOD/CAUTION/AVOID) and an array of descriptive, medically-conservative reasons are generated and displayed on `VerdictScreen`.

---

## Future Implementations Needed (Next Priority)
*   **Firebase Authentication**: Replacing local profile storage to enable the "Family Sharing" feature natively.
*   **True AR Integration**: Connect Google ML Kit Text Recognition to the live camera feed to parse ingredient labels purely through OCR, migrating the current "Moonshot" Beta UI into functional reality