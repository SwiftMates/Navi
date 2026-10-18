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
- Never mutate `properties.path` yourself (`append`, `removeLast`, reassignment) — origin tracking desyncs.
- Exactly one `NaviController` per `NavigationStack`. Never share one controller between two stacks.
- Logger is optional: `NaviControllerProperties(logger: nil)` or omit. `NaviLogging` requires `logInfo`/`logError`.
- One destination enum per feature/screen is fine — there is no global route enum requirement.

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
- `DestinationRepresentable` conformance (skipped if you already declare it)
- `navigationOrigin` property switching over the cases
- Nested `enum Origins: OriginRepresentable` — **only** when at least one case is `@OriginKey`; pop targets are
  `Enum.Origins.caseName` (the generated `…OriginKey` statics are private)

Macro constraints:
- `@OriginKey case a, b` marks **both** cases of that declaration.
- Enums with associated values are fine; non-`@OriginKey` cases return `nil`. Keyword case names work via backticks.
- Generic enums are supported **without** `@OriginKey` (`extension` adds `where T: Hashable`); `@OriginKey` inside a
  generic enum is a compile error (static stored property), as is `@OriginKey` on a raw-identifier case.
- Generated members have no access modifier, so a `public` enum gets internal `Origins`/conformance — cross-module
  `pop(to:)` will not compile. Keep destination enums internal.
- Non-enum targets and caseless enums are compile errors.

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

`deepLink(to:)` takes `[any DestinationRepresentable]`, so a route may mix feature enums — reset to root, then push
in order. `pop(to:)` leaves the origin screen on the stack and removes only what was pushed after it.
`push`/`pop(to:)` are generic in the destination/origin type; pass concrete cases (`any` array elements also work via
implicit existential opening).

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

- `pop(to:)` for an origin that was never pushed (or for a case without `@OriginKey`) logs an error and
  `assertionFailure`s — a debug crash, a silent no-op in release.
- A swipe-back / system back mutates the bound path directly: origins are only reconciled on the next `pop()`
  (prune) or `push` (overwrite). Don't `pop(to:)` right after a user-driven back.
- Origins are keyed per **case**, so two pushes of the same case with different payloads share one key — the last
  push wins. Don't rely on `@OriginKey` to return to a specific value.
- `deepLink(to:)` always resets to root first, then pushes the sequence.
- Keep destination enums `Hashable` (enums with Hashable associated values work automatically).
- Avoid mixing manual `path.append` with Navi methods; it desyncs origin tracking.
- `properties.path` is the only public state — `naviStackOrigins` is internal to the Navi module.
- Origins live in memory only (`NavigationOriginKey` is not `Codable`); rebuild state by pushing, not by assigning a path.

## References

Load these only when the short rules above are not enough:

- Full API surface, macro expansion, diagnostics, and origin semantics → `references/api.md`
- Complete working examples (iOS 16/17, tabs, coordinators, deep links, logging) → `references/examples.md`
- Migration from raw `NavigationPath`, typed path arrays, and classic coordinators → `references/migration.md`

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
- Swift 6.0+ (tools 6.0–6.4)
- Xcode 16+
- No runtime dependencies (swift-syntax is a build-time dependency of the macro plugin only)
