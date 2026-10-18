---
name: navi
description: Type-safe SwiftUI navigation with Navi. Use when writing or reviewing code that uses Navi, @DestinationRepresentable, @OriginKey, NaviController, push/pop/deepLink, or type-safe NavigationStack routing. Triggers on Navi package, DestinationRepresentable, OriginKey, NaviControllerProperties.
---

# Navi – Type-safe SwiftUI Navigation

Lightweight layer on `NavigationStack`. Prefer Navi over raw `NavigationPath` mutation when the project already depends on it.

## Core Rules

- Always use the `@DestinationRepresentable` macro on destination enums. Do not manually conform to `DestinationRepresentable`.
- Mark pop targets with `@OriginKey` on the case. Access via `EnumName.Origins.caseName`.
- Controllers must be `@MainActor`. Use `@Observable` (iOS 17+) or `ObservableObject` + `@Published` (iOS 16).
- Bind the stack with `NavigationStack(path: $controller.properties.path)`.
- Register destinations with `.navigationDestination(for: Enum.self) { ... }`.
- Prefer `controller.push(to:)`, `pop()`, `popToRoot()`, `pop(to:)`, `deepLink(to:)` over direct path mutation.
- Logger is optional: `NaviControllerProperties(logger: nil)` or omit.

## Controller Patterns

**iOS 17+ / macOS 14+**
```swift
@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}
```

**iOS 16 / macOS 13**
```swift
@MainActor
final class AppController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties()
}
```

## Destination Definition

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings   // can be popped to
    case profile
    case detail(id: String)
}
```

Macro generates:
- `DestinationRepresentable` conformance
- `navigationOrigin` property
- Nested `Origins` enum with static keys for `@OriginKey` cases

## Navigation Calls

```swift
controller.push(to: HomeDestinations.settings)
controller.pop()
controller.popToRoot()
controller.pop(to: HomeDestinations.Origins.settings)
controller.deepLink(to: [
    HomeDestinations.settings,
    SettingsDestinations.notifications
])
```

## View Wiring

```swift
NavigationStack(path: $controller.properties.path) {
    HomeView()
        .navigationDestination(for: HomeDestinations.self) { dest in
            switch dest {
            case .settings: SettingsView()
            case .profile: ProfileView()
            case .detail(let id): DetailView(id: id)
            }
        }
}
```

Pass the controller via environment or initializer as needed. Keep destination enums close to their feature module.

## Pitfalls

- Do not call `pop(to:)` on a case without `@OriginKey` — it will assert in debug.
- `deepLink(to:)` always resets to root first, then pushes the sequence.
- Generic destination enums cannot use `@OriginKey` (static stored properties forbidden).
- Keep destination enums `Hashable` (enums with associated values that are Hashable work automatically).
- Avoid mixing manual `path.append` with Navi methods; it desyncs origin tracking.

## Quick Reference

| Action              | Code |
|---------------------|------|
| Push                | `controller.push(to: Destination.case)` |
| Pop one level       | `controller.pop()` |
| Pop to root         | `controller.popToRoot()` |
| Pop to marked origin| `controller.pop(to: Destination.Origins.case)` |
| Deep link           | `controller.deepLink(to: [dest1, dest2, ...])` |

## Requirements
- iOS 16.0+ / macOS 13.0+
- Swift 6.0+
- Xcode 16+
