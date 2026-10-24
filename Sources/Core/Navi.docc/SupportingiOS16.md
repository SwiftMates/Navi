# Supporting iOS 16 and macOS 13

`NavigationStack` is available from iOS 16 / macOS 13, but `@Observable` is not. Use a
`@MainActor` `ObservableObject` controller instead.

## Overview

### The controller

```swift
import Combine
import Navi

@MainActor
final class AppController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties(logger: AppLogger())
}
```

Both annotations are required:

- `@MainActor` — ``NaviController`` is main-actor isolated, and `ObservableObject` does not inherit
  that isolation, so the conformance has to be annotated explicitly.
- `@Published` — `NaviControllerProperties` is a value type; SwiftUI only observes changes to
  `properties` if the property publishes them.

### The stack

```swift
@main
struct DemoApp: App {
    @StateObject private var controller = AppController()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $controller.properties.path) {
                HomeView()
            }
            .environmentObject(controller)
        }
    }
}
```

`@StateObject` rather than `@State`: the controller is a reference type whose lifetime must survive
view re-creation.

### Reading the controller

```swift
struct HomeView: View {
    @EnvironmentObject var controller: AppController

    var body: some View {
        Button("Settings") {
            controller.push(to: HomeDestinations.settings)
        }
        .navigationDestination(for: HomeDestinations.self) { destination in
            switch destination {
            case .settings: SettingsView()
            }
        }
    }
}
```

With `ObservableObject`, the injected type stays concrete — there is no `@Environment(Type.self)`.

### Everything else is identical

Destination macros, ``OriginKey()``, `deepLink(to:)`, and ``NaviLogging`` do not depend on the
observation mechanism. The only difference is how the controller publishes its ``NaviControllerProperties``.
