---
description: how to run the NutriDecide application
---

To run NutriDecide correctly, follow these steps to ensure both the backend and frontend are synchronized.

### 1. Start the Backend
The backend handles regional food data and search.
```bash
cd backend
npm install
npm run dev
```
*Note: Ensure you have `MONGODB_URI` set in `backend/.env` if you want persistence.*

### 2. Configure Environment
Before launching Flutter, verify your IP address.
1. Open `.env` in the root directory.
2. Set `BACKEND_URL`:
   - **For Android Emulator**: `http://10.0.2.2:5000/api`
   - **For Real Device**: `http://YOUR_LOCAL_IP:5000/api` (e.g., `192.168.1.x`)
   - **For iOS Simulator**: `http://localhost:5000/api`

### 3. Launch the Flutter App
```bash
flutter pub get
flutter run
```

### 🆘 Common Issues
- **Firebase Error**: If you see `[core/no-app]`, ensure `google-services.json` is present and valid.
- **Connection Refused**: Your `BACKEND_URL` in `.env` must point to the machine where the Node.js server is running.
- **Hive Error**: If the database doesn't load, try `flutter clean` then `flutter run`.
