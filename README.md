# 🧪 Chromix (Bottle Sort Puzzle)

Chromix is a premium, offline water/bottle sort puzzle game built with Flutter. Tap bottles to pour colored liquids into matching ones until all bottles are sorted by color.

---

## 🎮 How to Play

1. **Select a Bottle:** Tap any non-empty bottle. It will lift and glow.
2. **Pour Liquid:** Tap another bottle. The top color layer will pour if:
   - The destination bottle is completely empty.
   - The top color layer matches the color you are pouring.
3. **Win Condition:** Sort all liquids so every non-empty bottle contains exactly one homogeneous color.

---

## ✨ Features

- **500 Levels:** Includes 50 handcrafted levels with increasing complexity and 450+ procedurally generated levels.
- **Daily Challenge:** A unique deterministic puzzle generated every day using your local date (no internet connection needed).
- **Smart Solver (BFS/A*):** Runs solving algorithms on a background thread (`Isolate`) to give you optimal move hints without freezing the screen.
- **Offline Storage:** Automatically saves your game progress, stats, settings, and unlocked achievements locally using Hive.
- **Sound & Haptics:** Custom soundtrack and sound effects with independent volume settings, plus haptic feedback support.

---

## 🧠 Algorithms & Technical Details

### 1. Hint Solver (BFS & A* Search)
To solve the bottle configurations efficiently without lagging the UI thread:
* **Background Isolation (`compute`):** The solver runs in a Dart `Isolate` to avoid dropping frames (60fps gameplay).
* **BFS (Breadth-First Search):** Used for smaller boards (≤ 7 bottles) to guarantee the shortest possible path of moves to solve the board.
* **A\* Search Algorithm:** Used for larger, complex boards (> 7 bottles). It uses a custom heuristic based on the number of mismatched/interrupted color layers in each bottle to guide search towards the fastest solution.
* **Transposition Table:** Implements game-state hashing and deduplication. Permutations of identical bottles are sorted (canonicalized) to collapse isomorphic states, reducing the search space by up to 90%.

### 2. Level Generation & Validation
* **Solvability Validation:** Every procedurally generated level (Level 51+) is generated backwards or shuffled randomly, then pre-solved by the internal BFS/A* engine. Only verified solvable boards are loaded.
* **Deterministic Daily Seed:** Daily challenges derive a seed hash from the current date string (`YYYY-MM-DD`). Every player gets the exact same solvable daily layout offline.

### 3. Rendering Optimization
* **Repaint Boundaries:** The gameplay board uses `RepaintBoundary` wrappers around individual bottles so static bottles are cached by the engine. Only the two bottles actively animating during a pour are redrawn.

---

## 🚀 Commands

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run the app locally
flutter run

# Build APK for Android
flutter build apk --release --split-per-abi
```
