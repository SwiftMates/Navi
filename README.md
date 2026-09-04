<p align="center">
    <img width="350" alt="Navi_package_logo_cropped" src="https://github.com/user-attachments/assets/817f6e98-da67-4bf0-94eb-01448a7148a1" />
</p>

<p align="center">
    <a href="https://github.com/SwiftMates/Navi/actions/workflows/main.yml"><img src="https://github.com/SwiftMates/Navi/actions/workflows/main.yml/badge.svg?branch=main" alt="Main" /></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?logo=swift" alt="Swift 6.0+" /></a>
    <a href="Package.swift"><img src="https://img.shields.io/badge/Platforms-iOS%2016%2B%20%7C%20macOS%2013%2B-lightgrey" alt="Platforms" /></a>
    <a href="https://swiftpackageindex.com/SwiftMates/Navi"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen" alt="SPM" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue" alt="MIT" /></a>
</p>

A lightweight, Swift 6 native navigation package for SwiftUI's `NavigationStack`.

`Navi` is a simple, lightweight Swift package that makes working with SwiftUI's `NavigationStack` easier, cleaner, and more flexible — without imposing any architecture or heavy abstractions.

It provides a small set of utilities that help you handle more complex navigation flows out of the box, while staying pure SwiftUI, easy to understand, and safe to use in any environment.

---

## ✨ Features

- ✅ **Built on SwiftUI's `NavigationStack`**
- ✅ **Pure Swift 6**
- ✅ **Lightweight & minimal API**
- ✅ **No architecture enforcement**
- ✅ **Works with any app structure**
- ✅ **Easy to reason about and debug**
- ✅ **Production-ready**
- ✅ **MIT licensed**

---

## 🚀 Motivation

SwiftUI navigation has evolved significantly, but handling **non-trivial navigation flows** (deep links, programmatic navigation, pop back to specific screen, etc.) can still lead to:

- Scattered navigation logic
- Tight coupling between views
- Boilerplate-heavy `NavigationPath` handling

**Navi** exists to **simplify navigation logic** while staying **close to SwiftUI's mental model** — no magic, no hidden behavior, just helpful abstractions.

---

## 🤔 Why Navi vs. Native NavigationStack?

SwiftUI's `NavigationStack` is powerful, but as your app grows, you may encounter some friction:

| Challenge | Native NavigationStack | Navi |
|:----------|:---------------------:|:------:|
| **Boilerplate** | Requires manual `NavigationPath` management | Handles path management for you |
| **Programmatic navigation** | Verbose, requires passing bindings | Simple, centralized API |
| **Type safety** | Easy to lose type info with `NavigationPath` | Maintains type-safe navigation |
| **Deep linking** | Manual setup required | Easier to implement |
| **Multi-step flows** | Complex state management | Streamlined handling |
| **Decoupling views** | Views often know about destinations | Views stay focused on their content |
| **Testing** | Navigation logic embedded in views | Navigation logic can be isolated |

### In short:

**Navi** helps when your navigation logic grows beyond a few screens — without forcing you into a specific architecture.

---

## ✅ Requirements

| Platform | Minimum |
|:---------|:--------|
| iOS      | 16.0+   |
| macOS    | 13.0+   |
| Swift    | 6.0+ (tools 6.3) |
| Xcode    | 16.0+ |

Navi is a pure Swift 6 package. On iOS 17+ / macOS 14+ you can use the `@Observable`
controller pattern (see `Examples/Basic`); on iOS 16 / macOS 13 use the `ObservableObject`
pattern instead (see `Examples/Basic-iOS16`).

---

## 📦 Installation

### Swift Package Manager (SPM)

Add Navi to your project via Xcode:

1. Open your project in Xcode
2. Go to **File → Add Packages…**
3. Enter the repository URL: https://github.com/SwiftMates/Navi
4. Select the version you want (recommended: latest)

### Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwiftMates/Navi.git", from: "1.0.0")
]
```

---

## 🧩 Basic Usage

### 1. (Optional) Provide a logger

`NaviControllerProperties` works with or without a logger (`Sources/Core/Navigation/NaviControllerProperties.swift:27`). If you want navigation events, conform to `NaviLogging` (`Sources/Core/Logger/NaviLogging.swift:9`):

```swift
import OSLog

final class AppLogger: NaviLogging {
    private let logger = Logger(subsystem: "com.yourapp", category: "Navi")

    func logInfo(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    func logError(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
}
```

### 2. Create a controller

```swift
// iOS 17+ / macOS 14+ — @Observable
@Observable
final class DemoController: NaviController {
    var properties = NaviControllerProperties() // or NaviControllerProperties(logger: AppLogger())
}
```

On iOS 16 / macOS 13 use `ObservableObject` instead (see `Examples/Basic-iOS16/Basic-iOS16/BasicExampleController.swift:11`):

```swift
@MainActor
final class DemoController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties() // or with logger
}
```

### 3. Create the NavigationStack

```swift
@main
struct BasicApp: App {
    
    @State private var controller = DemoController()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $controller.properties.path) {
                HomeView()
            }
        }
    }
}
```

### 4. Conform your destinations to DestinationRepresentable

```swift
@DestinationRepresentable
enum HomeDestinations {
    case settings
    case profile
}
```

### 5. Wire it up in SwiftUI

```swift
struct HomeView: View {
    var body: some View {
        content
            .navigationDestination(
                for: HomeDestinations.self,
                destination: destinationView
            )
    }

    @ViewBuilder
    private func destinationView(for destination: HomeDestinations) -> some View {
        switch destination {
        case .settings: SettingsView()
        case .profile: ProfileView()
        }
    }
}
```

### 6. Trigger navigation

```swift
func navigateToSettings() {
    controller.push(to: HomeDestinations.settings)
}

func navigateBack() {
    controller.pop()
}
```

## 🛠 Advanced Navigation

### ⏪ Pop to a specific screen in the stack

Use @OriginKey to mark a destination as a pop-back anchor.

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}
```

```swift
func popBackToSettings() {
    controller.pop(to: HomeDestinations.Origins.settings)
}
```

### 🔗 Deep Linking

```swift
func deepLinkToEmailSettings() {
    controller.deepLink(to: [
        HomeDestinations.settings,
        SettingsDestinations.notifications,
        NotificationsDestinations.emailNotifications
    ])
}
```

---

## 📖 Examples

> Check out our examples to see Navi in action.

| Example | Status |
|:--------|:------:|
| Simple (iOS 17+) — `Examples/Basic` | ✅ |
| Simple (iOS 16 / macOS 13) — `Examples/Basic-iOS16` | ✅ |

## 🧠 Design Philosophy

Navi follows a few simple principles:
- Minimal API surface — Learn it in minutes
- No forced architecture — Use it in any project, regardless of its architecture
- Composable & flexible — Use only what you need
- Easy to remove or replace — No lock-in
- No runtime magic — Predictable behavior

If you understand SwiftUI navigation, you already understand Navi.

## 📚 Documentation

- Inline documentation throughout the source (`Sources/Core/Navigation/NaviController.swift:14`, `Sources/Core/Navigation/DestinationRepresentable.swift:13`, `Sources/Core/Logger/NaviLogging.swift:9`)
- Public API is intentionally small — explore `NaviController`, `DestinationRepresentable`, `@DestinationRepresentable` / `@OriginKey`
- See `Examples/Basic` and `Examples/Basic-iOS16` for runnable setups

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) and [GitHub Releases](https://github.com/SwiftMates/Navi/releases).

## 🤝 Contributing

### Contributions are welcome!

1. Fork the repository
2. Create a branch from `develop` (`develop` is the integration branch, PRs target `develop`):
   ```sh
   git checkout develop
   git checkout -b feature/amazing-feature
   ```
3. Make your changes
4. Run `swift test` and, if you touched examples, `bundle exec fastlane build_basic` / `build_basic_ios16` (see `.github/workflows/pr-validation.yml:12`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request against `develop`

Bug reports, feature suggestions, and improvements are all appreciated.

### Code Formatting

This project uses [swift-format](https://github.com/swiftlang/swift-format) (matching `swift-syntax` 603) with configuration in `.swift-format` at the repository root.

```bash
# Install (once)
brew install swift-format
# or: swiftly install swift-format

# Format all files (package + examples)
make format
# or: swift-format format -i --recursive --configuration .swift-format Sources Tests Examples

# Check formatting (CI runs this)
make lint
# or: swift-format lint --recursive --configuration .swift-format Sources Tests Examples

# Or use the SwiftPM plugin (no separate install, uses Package.swift dependency)
swift package plugin --allow-writing-to-package-directory format-source-code
swift package plugin --allow-writing-to-package-directory lint-source-code
```

CI will fail if files are not formatted. Please run `make format` before committing. The `Examples/Basic` Xcode project also lints on build (warnings in Issue Navigator) when `swift-format` is installed.

## 📄 License

Navi is available under the MIT License.
You are free to use it in personal, open-source, and commercial projects.
See the LICENSE file for more details.

## ⭐ Show Your Support

If you find Navi helpful, please consider:
- Giving it a ⭐ on GitHub
- Sharing it with fellow developers
- Contributing to its development

## ❤️ Acknowledgements

Created and maintained by SwiftMates

Built with love for the SwiftUI community 💙

Made with ☕ and Swift
