# AGENTS.md (Repository Agent Instructions)

This repository is an iOS app built with **Xcode** (`Khairk.xcodeproj`) and UIKit storyboards.
Primary source lives in `Khairk/`.

## Existing Agent Rules (Cursor / Copilot)

- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No Copilot rules found in `.github/copilot-instructions.md`.

If you add any of those rule files later, keep this section updated and treat those rules as higher priority.

---

## Quick Start

- Open the project: `open Khairk.xcodeproj`
- Main scheme/target: `Khairk`
- Deployment target (from project settings): iOS `18.5`

---

## Build / Test / Lint Commands

### Build (CLI)

Use `xcodebuild` for deterministic CI-like builds.

- List schemes:
  - `xcodebuild -list -project Khairk.xcodeproj`

- Debug build (recommended default):
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -configuration Debug build`

- Release build:
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -configuration Release build`

- Build for a simulator destination (useful if you later add tests):
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -destination 'platform=iOS Simulator,name=iPhone 15' build`

### Tests

This project currently does **not** appear to include an XCTest target (no `*Tests*` target in the project file).
If/when tests are added, prefer these patterns:

- Run all tests:
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -destination 'platform=iOS Simulator,name=iPhone 15' test`

- Run a single test target (example name):
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:KhairkTests`

- Run a single test class:
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:KhairkTests/MyTestClass`

- Run a single test method:
  - `xcodebuild -project Khairk.xcodeproj -scheme Khairk -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:KhairkTests/MyTestClass/testExample`

Notes:
- Adjust simulator name to whatever is installed on the machine (e.g. `iPhone 14`, `iPhone 15 Pro`).
- If you add multiple schemes/targets, ensure `-scheme` matches the test host.

### Lint / Formatting

No repo-managed linter/formatter config is currently present (e.g. no `.swiftlint.yml`, `.swiftformat`, etc.).

Recommended options if you introduce them later:
- **SwiftLint** for static rules.
- **SwiftFormat** for automated formatting.

Until then:
- Treat **Xcode warnings as errors-in-spirit**: address warnings introduced by your changes.
- Keep formatting consistent with surrounding files.

---

## Project Structure

The app is organized roughly as:
- `Khairk/Controller/` — view controllers grouped by role (Admin/Collector/Donor/Auth)
- `Khairk/Model/` — data + services (currently placeholder directories)
- `Khairk/View/` — storyboard-based views grouped by area

Prefer to keep new code in the existing structure rather than introducing a new architecture without an explicit request.

---

## Feature Notes

### NGO Case Creation & Management (Donor)

- Storyboard: `Khairk/View/DonorViews/NGOCases/DonorNGOCases.storyboard`
- Controllers: `Khairk/Controller/DonorControllers/NGOCases/MyCasesViewController.swift`, `Khairk/Controller/DonorControllers/NGOCases/CaseDetailsViewController.swift`, `Khairk/Controller/DonorControllers/NGOCases/CreateCaseViewController.swift`
- Model/service: `Khairk/Controller/DonorControllers/NGOCases/NgoCase.swift`, `Khairk/Controller/DonorControllers/NGOCases/CaseService.swift`
- Firestore path: `ngos/{uid}/cases`
- Stored fields: `title`, `foodType`, `goal`, `collected`, `startDate`, `endDate`, `description`, `imageURL`, `status`, `createdAt`
- Flow: My Cases list -> Case Details; My Cases list -> New Case; delete and success use standard iOS alerts
- UI target: match the "NGO Case Creation & Management" export exactly

---


## Swift / UIKit Code Style Guidelines

### Imports

- Group imports at the top of the file.
- Keep imports minimal; remove unused imports.
- Prefer the order:
  1. Apple frameworks (e.g. `UIKit`, `Foundation`)
  2. Third-party frameworks (e.g. `FirebaseAuth`, `FirebaseCore`)
  3. Project modules (if applicable)

### Formatting

- Indentation: 4 spaces (match current files).
- Use trailing commas in multiline parameter lists when it improves diffs.
- Prefer multiline `UIView.animate(...)` / `UIView.transition(...)` calls when parameters become long.
- Keep blank lines meaningful; avoid multiple consecutive blank lines.

### Types and Optionals

- Prefer explicit types when inference harms readability (esp. closures and public APIs).
- Use optionals intentionally:
  - Prefer `guard let` early-exit for required values.
  - Avoid force unwraps (`!`) except for outlets (`@IBOutlet`) where it is the standard pattern.

### Naming Conventions

- Types: `UpperCamelCase` (`LoginViewController`).
- Methods/vars: `lowerCamelCase` (`animateLogoBounce()`).
- Booleans: prefix with `is/has/can/should` (`isLoggedIn`).
- Prefer descriptive names over abbreviations.

### View Controllers & Storyboards

- Keep storyboard identifiers in sync with code.
- Avoid stringly-typed identifiers scattered everywhere:
  - Prefer a single `enum StoryboardID` / `enum StoryboardName` if identifiers multiply.
- Avoid doing network or heavy work in `viewDidLoad`; use dedicated services and async flows.

### Concurrency / Threading

- UI updates must happen on the main thread.
- Prefer `DispatchQueue.main.async` for UIKit UI updates when coming from background work.
- If you introduce Swift concurrency (`async/await`), keep it consistent across the file/feature.

### Error Handling

- Do not ignore errors silently.
- Prefer:
  - `do/catch` for throwing APIs.
  - Completion handlers with `Result<T, Error>` when designing new async APIs.
- Show actionable user-facing errors (alerts/toasts) and log developer detail separately.

Logging guidance:
- Avoid leaving `print(...)` statements in production flows. Prefer `os.Logger` if you add structured logging.

### Firebase Usage

- Centralize Firebase configuration in `AppDelegate` (already calls `FirebaseApp.configure()`).
- Avoid reading `Auth.auth().currentUser` from many places; prefer a small auth/session service.

### Architecture / Boundaries

- Keep controllers thin:
  - UI wiring + view state.
  - Move business logic to `Model/Services`.
- Avoid massive view controllers; split by feature when needed.

### Safety / Secrets

- Do not commit secrets.
- `GoogleService-Info.plist` is present; do not paste API keys or tokens into source.

---

## Agent Workflow Expectations

- Prefer small, focused changes.
- Run a CLI build (`xcodebuild ... build`) when making non-trivial Swift changes.
- Do not rename files / reorganize folders unless requested.
- Do not add new tooling (SwiftLint/SwiftFormat/CI) unless requested.
