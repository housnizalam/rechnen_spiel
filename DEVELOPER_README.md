# RechnenSpiel Developer README

## 1) Project Overview

RechnenSpiel is a Flutter arithmetic training game with persistent local user profiles.

The app combines:
- Multiple arithmetic operations (`+`, `-`, `*`, `/`)
- Stage-based difficulty progression
- Timed stage runs
- Win/fail conditions based on answer quality
- Persistent user progress and historical completion records

At runtime, a player picks or creates a profile, enters the game, chooses an operation and stage, answers generated questions, and accumulates records for completed stages.

## 2) Tech Stack

- Flutter (UI, navigation, platform integration)
- Dart (application language)
- Riverpod (`flutter_riverpod`) for app state management
- Hive / `hive_flutter` for local persistence
- UUID (`uuid`) for generating stable IDs
- Windows build support (`flutter build windows --debug`)

## 3) Architecture Overview

This codebase uses a feature-based structure with clear separation of responsibilities:

- `app/`: app bootstrap and top-level providers
- `core/`: global constants/shared cross-feature values
- `features/game/`: game domain logic, state, and game UI
- `features/user/`: user profile models, persistence, providers, and start flow UI

Inside features, responsibilities are split into:
- `domain/`: models and pure business logic
- `state/`: Riverpod notifiers and immutable state
- `data/`: storage/repository-like services
- `presentation/`: pages and widgets

## 4) Main Folders and Responsibilities

### `lib/app`
- App entry widget and shared providers used by multiple features.
- The `MaterialApp` starts on `StartPage`.

### `lib/core/constants`
- Global constants used by game logic (operations list, stage max values).
- Shared random/time compatibility fields retained from earlier iterations.

### `lib/features/game/domain`
- `game_engine.dart`: pure question generation and answer option generation.
- `game_models.dart`: runtime game models like `Player` and `CalcOperation`.

### `lib/features/game/state`
- `game_notifier.dart`: primary game state machine and workflow controller.
- Contains `GameState`, `GameStatus`, and `gameNotifierProvider`.

### `lib/features/game/presentation`
- `pages/`: full-screen game UI (currently `GamePage`).
- `widgets/`: modular UI blocks (exercise, timer, controls, statistics button, etc.).

### `lib/features/user/domain`
- `user_profile.dart`: persisted user identity + records aggregate.
- `game_record.dart`: immutable completed-stage record model.

### `lib/features/user/data`
- `user_storage_service.dart`: Hive-backed local profile persistence.
- Duplicate-name validation and CRUD operations live here.

### `lib/features/user/state`
- Riverpod providers for user loading/access (`userStorageServiceProvider`, saved users provider).

### `lib/features/user/presentation`
- `StartPage`: profile selection/create/edit/delete UI and game entry handoff.

## 5) Game Flow

1. App starts and opens `StartPage`.
2. User selects existing `UserProfile` or creates a new one.
3. App enters `GamePage` and injects selected profile data into `GameNotifier`.
4. Player selects operation (unless already playing; switching is locked during active play).
5. Player starts a stage run.
6. `GameEngine.generateQuestion(...)` generates one question for operation + stage.
7. Player submits answers from generated options.
8. `GameNotifier` updates `trueAnswers`, `allAnswers`, and evaluation state.
9. Win condition: 8 correct answers (`trueAnswers > 7`).
10. Fail condition: 3 mistakes (`allAnswers - trueAnswers > 2`).
11. On win, a `GameRecord` is created with operation, stage, and duration.
12. Record is appended to the current player profile and persisted via storage service.

## 6) State Management

### Core pieces
- `GameState`: immutable snapshot consumed by widgets.
- `GameNotifier`: all game workflow actions/mutations.
- `gameNotifierProvider`: Riverpod `StateNotifierProvider<GameNotifier, GameState>`.

### Why Riverpod is the only active state management
- UI widgets read state through providers and trigger notifier methods.
- Business logic is centralized in notifier/domain layers instead of widgets.
- This keeps behavior testable and predictable.

### BLoC note
- Legacy BLoC traces exist only as old commented references.
- BLoC is not active and should not be reintroduced unless a major architecture decision is made for the whole project.

## 7) GameEngine

`GameEngine` is a pure domain service responsible for question/option generation.

### Addition (`+`)
- Picks two random numbers up to the stage bound.
- Correct answer is their sum.

### Subtraction (`-`)
- Picks two random numbers up to the stage bound.
- Swaps operands when needed so result does not become negative.

### Multiplication (`*`)
- Picks two random numbers up to the stage bound.
- Correct answer is product.

### Division (`/`)
- Generates a non-zero divisor.
- Builds dividend as divisor × quotient.
- Ensures exact integer division with no remainder.

### Answer options
- `generateAnswerOptions` creates 4 unique options.
- Includes exact correct answer plus nearby alternatives.
- Final list is shuffled for display.

## 8) User Storage

### Models
- `UserProfile`: `id`, `name`, `createdAt`, `gameRecords`.
- `GameRecord`: `id`, `createdAt`, `stageNumber`, `operation`, `durationSeconds`.

### Storage service
- `UserStorageService` handles local read/write/update/delete.
- Hive box name: `user_profiles`.

### Map-based persistence
- Data is stored as plain `Map<String, dynamic>` payloads.
- No Hive type adapters / code generation currently required.
- Serialization is implemented in model `toMap/fromMap` methods.

### Duplicate user prevention
- Save/upsert checks are case-insensitive and trimmed.
- Duplicate names across different user IDs are rejected.
- Renaming also enforces duplicate checks.

## 9) Progress and Records

### Grouping rule
Records must be grouped by **operation + stageNumber**.

Examples:
- Compare `Addition Stage 1` only with `Addition Stage 1`.
- Never compare `Addition Stage 1` with `Subtraction Stage 1`.
- Never compare `Stage 1` with `Stage 2` within the same operation.

### Best 3 logic
- Sort records in a category by `durationSeconds` ascending.
- Keep the first 1, 2, or 3 entries depending on available data.
- If more than 3 entries exist, keep only top 3.

### Auto-resume stage per operation
- Stage resume is derived from completed records for each operation.
- Each operation has independent unlocked stage tracking.
- On user load, next playable stage index is computed from that operation’s record history.

## 10) UI Structure

### Pages
- `StartPage`: user selection/creation/edit/delete and game entry.
- `GamePage`: gameplay layout with header, exercise area, answer area, and controls.

### Main game widgets
- `ExerciseDisplay`
- `AnswerInput`
- `AnswerSheet`
- `GameController`
- `StageDisplay`
- `TimerDisplay`
- `Evaluation`
- `PlayerStatisticsButton`

## 11) Important Rules for Future Developers

1. Do not generate questions inside UI widgets.
2. UI should only read state and call notifier methods.
3. Game logic belongs in `GameNotifier` and `GameEngine`.
4. Storage logic belongs in `UserStorageService`.
5. Never compare records globally; always group by operation + stage.
6. Do not allow operation/stage changes while a stage is actively playing.

## 12) How to Run

From project root:

```bash
flutter pub get
dart analyze lib
flutter build windows --debug
flutter run
```

## 13) How to Add a Feature

### Example A: Add a new statistic
- Add pure helper logic in `GameNotifier` or a dedicated domain utility.
- Expose derived values through notifier/state.
- Render in presentation widgets without mutating persistence there.

### Example B: Add a new user field
- Add field to `UserProfile`.
- Update `copyWith`, `toMap`, and `fromMap`.
- Update storage service validation or migration behavior as needed.
- Ensure old map payloads still deserialize safely.

### Example C: Add a new operation
- Extend operation list/constants.
- Add generation logic in `GameEngine`.
- Extend `CalcOperation` handling and notifier stage/progression logic.
- Update UI selectors/labels and records grouping/mapping.

### Example D: Add new UI around GameRecords
- Read records from `GameState.player.gameRecords`.
- Group by operation + stage.
- Keep logic read-only in UI; persistence remains in service/notifier flows.

## 14) Known Design Decisions

- `GameRecord` exists to preserve immutable evidence of completed stage runs.
- `UserProfile` owns `gameRecords` so user progress/history remains localized.
- Hive adapters are not used yet to keep storage simple and explicit via map serialization.
- Stage progress is derived from records to avoid duplicated/probably divergent state.

## 15) Future Improvements

- Dedicated full-screen statistics page with filtering
- Achievement system
- Best-time badges/rank tiers
- Difficulty balancing per stage based on collected metrics
- Richer animations and transitions
- Additional mobile-specific UI polish and ergonomics

---

## Quick Maintenance Checklist

- Keep game rule changes in `game_notifier.dart` and `game_engine.dart` only.
- Keep persistence changes in `user_storage_service.dart` and user domain models.
- Run analyze/build after any state or storage changes.
- Verify operation-specific stage progression and record grouping after gameplay changes.
