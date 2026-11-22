# Getting started

Create a controller, attach it to a `NavigationStack`, declare destinations, and navigate.

## Overview

### Add the dependency

```swift
dependencies: [
    .package(url: "https://github.com/SwiftMates/Navi.git", from: "1.0.0")
]
```

Navi requires iOS 16 / macOS 13 or later. `@Observable`-based controllers need iOS 17 / macOS 14;
see <doc:SupportingiOS16> for the older target.

### 1. Create a controller

On iOS 17+ / macOS 14+, use `@Observable`:

```swift
import Navi

@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}
```

`NaviController` has default implementations for every navigation method, so a conformance only has
to supply ``NaviControllerProperties``. Two details are not optional:

- `properties` must be a settable `var` — it is a value type, and `NavigationStack` binds to its `path`.
- The controller must be observable (`@Observable` or `ObservableObject`), otherwise the stack never
  re-renders when the path changes.

### 2. Attach it to a stack

```swift
@main
struct DemoApp: App {
    @State private var controller = AppController()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $controller.properties.path) {
                HomeView()
            }
            .environment(controller)
        }
    }
}
```

The binding is the same one you would write by hand; Navi only needs to be the single owner of the
mutations. Each `NavigationStack` gets exactly one controller — see
<doc:MigratingFromNavigationPath#One-controller-per-stack> for the multi-stack case.

### 3. Declare destinations

```swift
@DestinationRepresentable
enum HomeDestinations {
    case profile
}
```

`@DestinationRepresentable` is an enum-only macro. It generates the ``DestinationRepresentable``
conformance plus a `navigationOrigin` property, which stays `nil` until you mark cases with
``OriginKey()``:

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}
```

Marking a case also generates the nested `Origins` enum used by `pop(to:)` — covered in
<doc:PopToOrigin>.

### 4. Register the views

```swift
struct HomeView: View {
    @Environment(AppController.self) private var controller

    var body: some View {
        List {
            Button("Settings") { controller.push(to: HomeDestinations.settings) }
            Button("Profile") { controller.push(to: HomeDestinations.profile) }
        }
        .navigationDestination(for: HomeDestinations.self) { destination in
            switch destination {
            case .settings: SettingsView()
            case .profile: ProfileView()
            }
        }
    }
}
```

Navi does not generate view mapping. `.navigationDestination(for:)` stays yours, which is why
destination enums can live next to the views that own them.

### 5. Navigate

| Call | Effect |
|---|---|
| `controller.push(to:)` | Appends one destination |
| `controller.pop()` | Removes the top destination |
| `controller.popToRoot()` | Clears the whole stack |
| `controller.pop(to:)` | Pops back to a destination marked with `@OriginKey` |
| `controller.deepLink(to:)` | Replaces the stack with an ordered route |

```swift
controller.push(to: HomeDestinations.settings)
controller.pop()
controller.popToRoot()
```

Everything is `@MainActor`-isolated, matching the views that call it.

### Reading stack state

`properties.path` is the only public state; use `controller.properties.path.count` for depth. Tracked
origins are internal to the module and cannot be inspected from an app.

### Next

- <doc:DeepLinking> — replace the stack with a multi-step route.
- <doc:PopToOrigin> — pop back to a known screen instead of counting pops.
- <doc:MigratingFromNavigationPath> — adopt Navi in an existing app one feature at a time.
