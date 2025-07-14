# 🎓 Smart Event

Smart Event is a 2025 graduation‑project mobile app built with **Flutter** that lets people discover, book, and review events—all in one place.

---

## ✨ Key Features
| Area | What it does |
|------|--------------|
| Event Discovery | Browse or search events by city, date, or category based on user interests. |
| Detailed Pages   | View schedules and contact info. |
| One‑Tap Booking  | Reserve seats instantly; capacity is synced with the backend. |
| Ticket Wallet    | See upcoming and past bookings—even offline. |
| Reviews & Ratings| Leave feedback and read attendee opinions. |
| Personalization  | Lottie‑based onboarding, dark/light themes, saved preferences. |

---

## 🛠️ Tech Stack
| Layer          | Tools & Packages |
|----------------|------------------|
| **Frontend**   | Flutter 3.x, Dart, Material 3, Google Fonts |
| **State**      | Provider (planned migration to Riverpod) |
| **Networking** | `http`, RESTful API, JSON serialization |
| **Storage**    | `shared_preferences` for auth token & user data |
| **Animations** | Lottie |
| **CI/CD**      | GitHub Actions, Flutter Test, `flutter_lints` |

---

## 👩‍💻 My Contribution
- **End‑to‑end UI/UX**: designed every screen and built responsive layouts.
- **State management & navigation**: implemented Provider + `go_router`.
- **API integration**: consumed colleagues’ endpoints for auth, events, and reviews.
- **Local caching**: reduced network calls via SharedPreferences and in‑memory stores.
- **Accessibility**: color‑contrast checks, scalable text, and semantic widgets.
- **Testing**: wrote widget and integration tests for critical flows.

---

## 🚀 Getting Started

```bash
# 1 Prerequisites
Flutter >= 3.x • Dart >= 3.x • Android Studio or VS Code

# 2 Clone
git clone https://github.com/<your‑username>/SmartEvent.git
cd SmartEvent

# 3 Install packages
flutter pub get

# 4 Run on device or emulator
flutter run
