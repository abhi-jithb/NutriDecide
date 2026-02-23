<div align="center">

# 🥗 Personalized Food Intelligence App

### *Beyond calories. Beyond macros. Built for YOU.*

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Active%20Dev-brightgreen?style=for-the-badge)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-ff69b4?style=for-the-badge)](CONTRIBUTING.md)

<br/>

> A preventive health-focused **food intelligence system** that evaluates packaged food suitability using **personalized** health profiles.
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

## 📁 Project Structure

```
lib/
│
├── main.dart
├── app.dart
│
├── core/
│   └── theme/
│       └── app_theme.dart
│
├── features/
│   │
│   ├── auth/
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── profile_setup_screen.dart
│   │
│   ├── home/
│   │   └── home_screen.dart
│   │
│   ├── scan/
│   │   └── scan_screen.dart
│   │
│   ├── profile/
│   │   └── profile_screen.dart
│   │
│   ├── settings/
│   │   └── settings_screen.dart
│   │
│   └── navigation/
│       └── bottom_nav_screen.dart
```

**Architecture principles:**
- ✅ Feature-first folder structure
- ✅ Clean separation of UI and logic
- ✅ Scalable for full backend integration

---

## ⚙️ Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code
- An emulator or physical device

Verify your setup:

```bash
flutter doctor
```

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/abhi-jithb/NutriDecide.git
cd NutriDecide
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Run the App

```bash
flutter run
```

---

## ✅ Current Features

| Feature | Status |
|---------|--------|
| Login & Signup UI | ✅ Live |
| Full Health Profile Setup | ✅ Live |
| Bottom Navigation | ✅ Live |
| Profile Screen | ✅ Live |
| Settings Screen | ✅ Live |
| Dark Mode Toggle | ✅ Live |
| Barcode Scanner | 🔧 In Progress |
| Open Food Facts API | 🔧 In Progress |
| Inference Engine (Backend) | 📋 Planned |
| Daily Food Logs | 📋 Planned |
| Data Export | 📋 Planned |
| Subscription Model | 📋 Planned |

---

## 🚧 Roadmap

```
Phase 1 (Now)     ──▶   Auth + Profile + Settings + Dark Mode
Phase 2           ──▶   Barcode Scan + Food API + Verdict Engine
Phase 3           ──▶   Risk Patterns + Trend Tracking + Logs
Phase 4           ──▶   Wearables + Dietary AI + Multi-language
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

```bash
# 1. Fork the repo
# 2. Create your feature branch
git checkout -b feature/your-feature-name

# 3. Commit your changes
git commit -m "Add: your feature description"

# 4. Push to your branch
git push origin feature/your-feature-name

# 5. Open a Pull Request 🎉
```

**Development Guidelines:**
- Follow the feature-based folder structure
- Keep UI and business logic separated
- Never hardcode sensitive keys or tokens
- Use clean, descriptive naming conventions
- Write scalable, reusable components

---

## 🛡️ Privacy & Disclaimer

> ⚕️ This app provides food analysis suggestions based on user-provided information.
> It does **not** provide medical diagnosis or professional medical advice.
> Always consult a qualified healthcare professional for medical decisions.

---

## 🌟 Future Vision

Evolving into a **preventive health assistant** that:

- 📈 Detects long-term risk patterns
- 📅 Tracks dietary trends over time
- 🥦 Provides intelligent dietary guidance
- ⌚ Integrates wearable health data
- 🌍 Supports multiple languages and regions

---

## 👥 Maintainers

Built as a personalized nutrition intelligence system.

For collaboration, discussion, or feedback — open an **Issue** or **Pull Request**. Contributions of all kinds are welcome.

---

<div align="center">

**🥗 Food Intelligence App** · Built with Flutter · Open to contributions

*Preventive health, reimagined.*

</div>
