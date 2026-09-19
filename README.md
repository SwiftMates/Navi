<p align="center">
    <img width="350" alt="Navi_package_logo_cropped" src="https://github.com/user-attachments/assets/817f6e98-da67-4bf0-94eb-01448a7148a1" />
</p>

<p align="center">
    <a href="https://github.com/SwiftMates/Navi/actions/workflows/main.yml"><img src="https://github.com/SwiftMates/Navi/actions/workflows/main.yml/badge.svg?branch=main" alt="Main" /></a>
    <a href="https://swiftpackageindex.com/SwiftMates/Navi"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftMates%2FNavi%2Fbadge%3Ftype%3Dswift-versions" alt="Swift Version Compatibility" /></a>
    <a href="https://swiftpackageindex.com/SwiftMates/Navi"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftMates%2FNavi%2Fbadge%3Ftype%3Dplatforms" alt="Platform Compatibility" /></a>
    <a href="https://swiftpackageindex.com/SwiftMates/Navi"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen" alt="SPM" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue" alt="MIT" /></a>
</p>

# Navi

**Type-safe SwiftUI navigation** built on `NavigationStack`.

Navi is a lightweight navigation layer for SwiftUI. It adds programmatic routing, deep linking, pop-to-destination, and destination macros to Apple’s `NavigationStack` — without imposing an application architecture. Pure Swift 6, iOS 16+, zero external dependencies.

---

## What is Navi?

Navi is a type-safe navigation library for SwiftUI that builds on `NavigationStack`. It gives you compile-time safe routes, a clean programmatic API, multi-step deep linking, and pop-to-destination, while staying fully compatible with the native navigation model.

It does **not** replace `NavigationStack`. It is a thin typed layer on top of it.

**Who is it for?**  
Developers who want structured, type-safe routes without adopting coordinators, TCA, or a large routing framework.

---

## Why Navi instead of raw NavigationStack?

| Need                        | Native `NavigationStack`              | Navi                                   |
|-----------------------------|---------------------------------------|----------------------------------------|
| Type-safe routes            | Easy to lose with `NavigationPath`    | Enum + macro, compile-time checked     |
| Programmatic navigation     | Pass bindings or mutate path manually | `push(to:)` / `pop()`                  |
| Deep linking                | Manual path construction              | `deepLink(to:)`                        |
| Pop to a specific screen    | Manual path surgery                   | `@OriginKey` + `pop(to:)`              |
| Architecture required       | None                                  | None                                   |
| External dependencies       | None                                  | None                                   |

---

## Quick Start

### 1. Create a controller

**iOS 17+ / macOS 14+ (`@Observable`):**

```swift
@Observable
final class DemoController: NaviController {
    var properties = NaviControllerProperties()
}
```

**iOS 16 / macOS 13 (`ObservableObject`):**

```swift
@MainActor
final class DemoController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties()
}
```

### 2. Attach to NavigationStack

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

### 3. Define destinations

```swift
@DestinationRepresentable
enum HomeDestinations {
    case settings
    case profile
}
```

### 4. Register and navigate

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

// Navigate
controller.push(to: HomeDestinations.settings)
controller.pop()
```

---

## Deep linking

```swift
controller.deepLink(to: [
    HomeDestinations.settings,
    SettingsDestinations.notifications,
    NotificationsDestinations.emailNotifications
])
```

---

## Pop to a destination

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}

controller.pop(to: HomeDestinations.Origins.settings)
```

---

## Requirements

| Platform | Minimum          |
|----------|------------------|
| iOS      | 16.0+            |
| macOS    | 13.0+            |
| Swift    | 6.0+ (tools 6.3) |
| Xcode    | 16.0+            |

- iOS 17+ / macOS 14+ → prefer `@Observable` (`Examples/Basic`)
- iOS 16 / macOS 13 → use `ObservableObject` (`Examples/Basic-iOS16`)

---

## Installation

**Xcode:** File → Add Packages… → `https://github.com/SwiftMates/Navi`

**Package.swift:**

```swift
dependencies: [
    .package(url: "https://github.com/SwiftMates/Navi.git", from: "1.0.0")
]
```

---

## FAQ

**What is Navi?**  
A type-safe navigation layer for SwiftUI built on `NavigationStack`. It adds programmatic navigation, deep linking, and pop-to-destination without architecture lock-in.

**Does Navi replace NavigationStack?**  
No. It works with `NavigationStack`.

**Is Navi a SwiftUI router?**  
Yes — a lightweight, type-safe one. `NavigationStack` remains the underlying container.

**Does it require a specific architecture?**  
No. Works with MVVM, TCA, coordinators, or none.

**Does it support deep linking and programmatic navigation?**  
Yes. Use `deepLink(to:)`, `push(to:)`, `pop()`, and `pop(to:)`.

**How do I pop to a specific screen?**  
Mark the destination with `@OriginKey`, then call `controller.pop(to: Destination.Origins.yourCase)`.

**Does it support iOS 16 and Swift 6?**  
Yes. iOS 16+ / macOS 13+, designed for Swift 6.

---

## Examples

| Example                | Platform            | Status |
|------------------------|---------------------|:------:|
| `Examples/Basic`       | iOS 17+ / macOS 14+ | ✅     |
| `Examples/Basic-iOS16` | iOS 16 / macOS 13   | ✅     |
| `Examples/Coordinators`| iOS 16 / macOS 13   | ✅     |

---

## License

MIT. See [LICENSE](LICENSE).

Created by [SwiftMates](https://github.com/SwiftMates).
