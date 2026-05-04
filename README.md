# 🧮 RechnenSpiel

> **A fast-paced, multi-platform arithmetic training game built with Flutter.**

---

## 🚀 Overview

**RechnenSpiel** (German for *Calculation Game*) is an interactive math training app designed to sharpen arithmetic skills through progressive challenges. Players work through timed stages of addition, subtraction, multiplication, and division — with multiple choice answers, audio feedback, and personal best tracking.

Whether you're a student looking to improve mental math or just want a quick brain workout, RechnenSpiel makes it engaging and fun. The app is fully cross-platform, runs offline, and remembers your progress automatically.

---

## ✨ Features

- **Multiple Game Modes**
  - 🔢 *Normal Mode* — Answer arithmetic questions as fast as possible
  - 🔀 *Reverse Mode* — Given a result, identify the correct expression
  - 🔜 *Binary ↔ Decimal* — Coming soon

- **5 Operation Types** — Addition (`+`), Subtraction (`−`), Multiplication (`×`), Division (`÷`), and **Random** (surprise operation each round)

- **12 Progressive Difficulty Stages** — Starting from small numbers up to 1000, each stage raises the challenge

- **Timed Rounds** — Every stage is timed; complete it with 8 correct answers to win

- **Win & Fail Conditions** — Win on 8 correct answers; fail on 3 consecutive mistakes — keeps every round tense

- **Multiple Player Profiles** — Create, rename, or delete player profiles stored locally on-device

- **Personal Statistics** — Track your best completion times per operation and stage; only the top 3 times are kept per category

- **Global Stats View** — Compare all saved players' records at a glance

- **Audio Feedback** — Sounds play on correct answers, mistakes, and stage completions

- **Beautiful Dark UI** — Gold-on-dark theme with gradient backgrounds and smooth animations (shake on wrong answer, pulse on correct)

- **Cross-Platform** — Runs on Android, iOS, Windows, macOS, Linux, and Web

---

## 🧠 Why This Project Exists

Mental arithmetic is a skill that quietly fades without practice. Most math apps are either too simple (flashcards) or too complex (full courses). **RechnenSpiel fills the gap** — structured enough to build real skill, fast enough to play in a spare 5 minutes.

The app was built to be genuinely replayable: the timer, the fail condition, and the personal best system turn a simple quiz into a competitive loop that keeps players coming back.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| UI & Platform | [Flutter](https://flutter.dev/) |
| Language | [Dart](https://dart.dev/) |
| State Management | [Riverpod](https://riverpod.dev/) (`flutter_riverpod ^2.0.0`) |
| Local Persistence | [Hive](https://pub.dev/packages/hive_flutter) (`hive_flutter ^1.1.0`) |
| Audio | [audioplayers](https://pub.dev/packages/audioplayers) (`^1.1.1`) |
| ID Generation | [uuid](https://pub.dev/packages/uuid) (`^3.0.7`) |
| Linting | [flutter_lints](https://pub.dev/packages/flutter_lints) |

---

## 📱 Screenshots

> _Screenshots coming soon — contributions welcome!_

| Home / Profile Select | Game Mode Selection | Normal Game | Reverse Game |
|---|---|---|---|
| _(placeholder)_ | _(placeholder)_ | _(placeholder)_ | _(placeholder)_ |

---

## 📦 Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `>=2.18.6 <3.0.0`)
- A connected device or emulator

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/housnizalam/rechnen_spiel.git
cd rechnen_spiel

# 2. Install dependencies
flutter pub get

# 3. Run on your connected device or emulator
flutter run

# 4. (Optional) Build for Windows desktop
flutter build windows --debug
```

---

## 📥 Download

> _Release builds coming soon._

| Platform | Download |
|---|---|
| 🤖 Android APK | _(coming soon)_ |
| 🪟 Windows Installer | _(coming soon)_ |
| 🌐 Web App | _(coming soon)_ |

---

## 🧩 Project Structure

```
lib/
├── app/                      # App bootstrap, MaterialApp, shared providers
├── core/
│   ├── constants/            # Stage bounds, operation list, game mode keys
│   └── theme/                # Colors, gradients, text styles, decorations
└── features/
    ├── game/                 # Normal game mode
    │   ├── domain/           # GameEngine (question generation), models
    │   ├── state/            # GameNotifier (state machine), GameState
    │   └── presentation/     # GamePage, all game widgets
    ├── reverse_game/         # Reverse operation game mode
    │   ├── domain/           # ReverseGameEngine, models
    │   ├── state/            # ReverseGameNotifier, state
    │   └── presentation/     # ReverseGamePage, widgets
    ├── game_mode/            # Game mode selection screen
    └── user/                 # Player profiles
        ├── domain/           # UserProfile, GameRecord models
        ├── data/             # UserStorageService (Hive-backed)
        ├── state/            # User Riverpod providers
        └── presentation/     # StartPage (profile select/create/edit/delete)
```

---

## 🎯 Future Improvements

- [ ] Binary ↔ Decimal conversion game modes
- [ ] Dedicated full-screen statistics page with filtering and charts
- [ ] Achievement system and best-time badges / rank tiers
- [ ] Adaptive difficulty balancing based on collected performance data
- [ ] Richer animations and page transitions
- [ ] Mobile-specific UI polish and ergonomics improvements
- [ ] iOS / Android release builds and store listings

---

## 👨‍💻 About the Developer

This project was built by **[housnizalam](https://github.com/housnizalam)**, a developer who cares about clean architecture and polished user experience. RechnenSpiel demonstrates a solid command of Flutter best practices — feature-based project structure, Riverpod for reactive state management, Hive for local persistence without code generation, and a fully custom design system. The codebase is thoroughly documented and structured for long-term maintainability.

---

<p align="center">
  Built with ❤️ and Flutter
</p>
