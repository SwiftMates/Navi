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

# Navi

**Type-safe SwiftUI navigation** built on `NavigationStack`.

Navi is a lightweight, native-first navigation layer for SwiftUI. It adds programmatic routing, deep linking, pop-to-destination, and destination macros to Apple’s `NavigationStack` — without imposing an application architecture. Pure Swift 6, iOS 16+, zero external dependencies.

> **Navi is type-safe SwiftUI navigation** for developers who want structured routes while staying on the native navigation system.

---

## What is Navi?

Navi is a type-safe navigation library for SwiftUI that builds directly on `NavigationStack`. It provides:

- Compile-time safe routes via macros
- Programmatic navigation (`push`, `pop`, `deepLink`, `pop(to:)`)
- Multi-step deep linking
- Pop-to-destination with `@OriginKey`
- No architecture requirements

Navi does **not** replace `NavigationStack`. It is a thin typed layer that makes the native stack easier to use in production apps.

**Who is Navi for?**  
SwiftUI developers who need type-safe routes and cleaner navigation logic without adopting coordinators, TCA, or a large routing framework.

---

## Why use Navi if SwiftUI already has NavigationStack?

`NavigationStack` is the foundation. Navi exists for the friction points that appear as apps grow:

| Need                        | Native `NavigationStack`              | With Navi                              |
|-----------------------------|---------------------------------------|----------------------------------------|
| Type-safe routes            | Easy to lose with `NavigationPath`    | Enum + macro, compile-time checked     |
| Programmatic navigation     | Pass bindings or mutate path manually | `controller.push(to:)` / `pop()`       |
| Deep linking                | Manual path construction              | `deepLink(to: [destinations…])`        |
| Pop to a specific screen    | Manual index / path surgery           | `@OriginKey` + `pop(to:)`              |
| Architecture                | None required                         | None required                          |
| Dependencies                | None                                  | None                                   |

You keep the native stack. Navi removes the friction.

---

## What problem does Navi solve?

In real SwiftUI apps, navigation often turns into:

- Boilerplate-heavy `NavigationPath` management
- Navigation logic scattered across views
- Tight coupling between screens
- Awkward multi-step deep links
- Navigation state that is hard to test

Navi solves these problems with a small, type-safe API that stays close to SwiftUI’s mental model — no magic, no forced architecture, no lock-in.

---

## Type-safe SwiftUI navigation

The core of Navi is type-safe routing. Define destinations as enums and let the macro do the rest:

```swift
@DestinationRepresentable
enum HomeDestinations {
    case settings
    case profile
}
```

Routes are checked at compile time. Invalid destinations do not compile. This is what **type-safe SwiftUI navigation** looks like with Navi.

---

## Programmatic navigation in SwiftUI

Drive navigation from anywhere without threading `NavigationPath` bindings through the view tree:

```swift
controller.push(to: HomeDestinations.settings)
controller.pop()
```

Centralized, typed, and easy to reason about and test.

---

## Deep linking in SwiftUI

Construct multi-step paths in a single call:

```swift
controller.deepLink(to: [
    HomeDestinations.settings,
    SettingsDestinations.notifications,
    NotificationsDestinations.emailNotifications
])
```

Works well for universal links, notification payloads, and internal multi-screen flows.

---

## Pop to a destination

Mark any destination as a pop-back anchor:

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}

controller.pop(to: HomeDestinations.Origins.settings)
```

No counting screens. No manual path editing. Just pop to the destination you marked.

---

## Architecture: zero lock-in

Navi does **not** require:

- MVVM
- The Composable Architecture (TCA)
- Coordinators
- A global router

Use it with any app structure. The controller is a thin layer over `NavigationStack` and lives wherever it fits your project.

---

## Quick Start

### 1. Optional logger

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

**iOS 17+ / macOS 14+ (`@Observable`):**

```swift
@Observable
final class DemoController: NaviController {
    var properties = NaviControllerProperties() // or with logger
}
```

**iOS 16 / macOS 13 (`ObservableObject`):**

```swift
@MainActor
final class DemoController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties()
}
```

### 3. Attach to NavigationStack

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

### 4. Define destinations

```swift
@DestinationRepresentable
enum HomeDestinations {
    case settings
    case profile
}
```

### 5. Register destinations

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

### 6. Navigate

```swift
controller.push(to: HomeDestinations.settings)
controller.pop()
```

---

## Advanced Usage

### Pop to a specific screen

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}

controller.pop(to: HomeDestinations.Origins.settings)
```

### Deep linking

```swift
controller.deepLink(to: [
    HomeDestinations.settings,
    SettingsDestinations.notifications,
    NotificationsDestinations.emailNotifications
])
```

---

## Navi vs NavigationStack

| Capability                | Native NavigationStack               | Navi                                   |
|---------------------------|--------------------------------------|----------------------------------------|
| Type-safe routes          | Easy to lose with `NavigationPath`   | Enum + macro, compile-time safe        |
| Programmatic navigation   | Manual path / binding management     | Typed `push` / `pop` API               |
| Deep linking              | Manual path construction             | `deepLink(to:)`                        |
| Pop to destination        | Manual path surgery                  | `@OriginKey` + `pop(to:)`              |
| Architecture required     | None                                 | None                                   |
| External dependencies     | None                                 | None                                   |
| Swift 6                   | Supported                            | Designed for Swift 6                   |
| Minimum platform          | iOS 16+                              | iOS 16+ / macOS 13+                    |

**Summary:** Navi is a thin type-safe layer *on top of* `NavigationStack`. It does not replace it.

---

## Navi vs other SwiftUI navigation approaches

| Approach                      | Type safety | Architecture lock-in | Built on NavigationStack | Best when you want…              |
|-------------------------------|-------------|----------------------|---------------------------|----------------------------------|
| Raw `NavigationStack`         | Partial     | None                 | Yes                       | Maximum control, accept boilerplate |
| **Navi**                      | Strong      | None                 | Yes                       | Type safety + minimal API        |
| Coordinator pattern           | Varies      | High                 | Optional                  | Explicit flow ownership          |
| Larger routing frameworks     | Strong      | Medium–High          | Often                     | Feature-rich routing system      |
| Enum-driven / Point-Free style| Strong      | Medium               | Yes                       | State-driven navigation model    |

Choose Navi when you want **type-safe SwiftUI navigation** and programmatic control without adopting a full navigation architecture.

---

## Requirements

| Platform | Minimum          |
|----------|------------------|
| iOS      | 16.0+            |
| macOS    | 13.0+            |
| Swift    | 6.0+ (tools 6.3) |
| Xcode    | 16.0+            |

- iOS 17+ / macOS 14+ → prefer `@Observable` controller (`Examples/Basic`)
- iOS 16 / macOS 13 → use `ObservableObject` (`Examples/Basic-iOS16`)

---

## Installation

### Xcode

1. **File → Add Packages…**
2. Enter: `https://github.com/SwiftMates/Navi`
3. Choose the latest version

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/SwiftMates/Navi.git", from: "1.0.0")
]
```

---

## FAQ

**What is Navi for SwiftUI?**  
Navi is a lightweight, type-safe navigation library for SwiftUI that builds on `NavigationStack`. It adds programmatic navigation, deep linking, destination macros, and pop-to-destination without imposing an architecture.

**Does Navi replace NavigationStack?**  
No. Navi works *with* `NavigationStack`. The native container remains the source of truth.

**Is Navi a SwiftUI router?**  
Yes. It is a lightweight, type-safe routing layer while `NavigationStack` stays the underlying navigation container.

**Does Navi require a specific architecture?**  
No. It works with MVVM, TCA, coordinators, or no formal architecture.

**Does Navi support deep linking?**  
Yes. Use `deepLink(to:)` to build multi-step paths to destinations.

**Does Navi support programmatic navigation?**  
Yes. The primary API is typed: `push`, `pop`, `deepLink`, and `pop(to:)`.

**How do I pop to a specific screen in SwiftUI?**  
Mark the destination with `@OriginKey`, then call `controller.pop(to: Destination.Origins.yourCase)`.

**Does Navi support iOS 16?**  
Yes. Minimum deployment is iOS 16.0 and macOS 13.0.

**Does Navi support Swift 6?**  
Yes. Navi is designed and tested for Swift 6.

**Is Navi lightweight?**  
Yes. Small public API, no third-party dependencies, no architecture requirements.

**How is Navi different from other SwiftUI navigation libraries?**  
Navi focuses on being a minimal, native-first layer: type-safe destinations via macros, first-class pop-to-destination, deep linking, and zero architecture lock-in — while always using Apple’s `NavigationStack`.

---

## Examples

| Example                  | Platform              | Status |
|--------------------------|-----------------------|:------:|
| `Examples/Basic`         | iOS 17+ / macOS 14+   | ✅     |
| `Examples/Basic-iOS16`   | iOS 16 / macOS 13     | ✅     |
| `Examples/Coordinators`   | iOS 16 / macOS 13    | ✅     |

---

## Documentation

- Inline documentation throughout the source
- Intentionally small public API: `NaviController`, `DestinationRepresentable`, `@DestinationRepresentable`, `@OriginKey`
- Runnable examples included in the repository

---

## Contributing

1. Fork the repository
2. Create a branch from `develop`:
   ```sh
   git checkout develop
   git checkout -b feature/your-feature
   ```
3. Make your changes
4. Run `swift test` (and example builds if relevant)
5. Open a Pull Request against `develop`

---

## License

Navi is available under the [MIT License](LICENSE).

---

## Acknowledgements

Created and maintained by [SwiftMates](https://github.com/SwiftMates).  
Built for the SwiftUI community.
```
