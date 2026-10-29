# Navi Usage Examples

Examples mirror `Examples/Basic` (iOS 17+), `Examples/Basic-iOS16`, and `Examples/Coordinators`.

## Minimal app (iOS 17+)

```swift
import SwiftUI
import Navi

@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}

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

@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}

struct HomeView: View {
    @Environment(AppController.self) var controller

    var body: some View {
        List {
            Button("Settings") { controller.push(to: HomeDestinations.settings) }
            Button("Profile") { controller.push(to: HomeDestinations.profile) }
        }
        .navigationTitle("Home")
        .navigationDestination(for: HomeDestinations.self) { destination in
            switch destination {
            case .settings: SettingsView()
            case .profile: ProfileView()
            }
        }
    }
}

struct SettingsView: View {
    @Environment(AppController.self) var controller

    var body: some View {
        Button("Back to Home") {
            controller.pop(to: HomeDestinations.Origins.settings)
        }
        .navigationTitle("Settings")
    }
}
```

## iOS 16 / macOS 13 controller

```swift
@MainActor
final class AppController: NaviController, ObservableObject {
    @Published var properties = NaviControllerProperties(logger: AppLogger())
}
```

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

struct HomeView: View {
    @EnvironmentObject var controller: AppController
    // …
}
```

## One destination enum per screen

Navi does not require a single global route enum. Register each feature's enum where it is used and keep the
enum next to its views (`Examples/Basic/Views`):

```swift
struct ViewA: View {
    @Environment(BasicExampleController.self) var controller

    var body: some View {
        Button("Show View - B") { controller.push(to: ViewADestinations.viewB) }
            .navigationTitle("View - A")
            .navigationDestination(for: ViewADestinations.self) { destination in
                switch destination {
                case .viewB: ViewB()
                }
            }
    }
}

@DestinationRepresentable
enum ViewADestinations {
    case viewB
}
```

## Multiple stacks (tabs)

Give every `NavigationStack` its own controller. Do not share one controller between two stacks.

```swift
@Observable
final class TabController: NaviController {
    var properties = NaviControllerProperties()
}

struct NavigationStackWrapper<Content: View>: View {
    @State private var controller = TabController()
    let content: (TabController) -> Content

    var body: some View {
        NavigationStack(path: $controller.properties.path) {
            content(controller)
        }
    }
}
```

Keep the stored type concrete (as in `Examples/Coordinators/Core/NavigationStackWrapper.swift`); an existential
`any NaviController` in `@State` would not be observed by SwiftUI. A tab's flow receives that controller and only
ever calls `push` / `pop` / `popToRoot` on it, while coordinators can still take `any NaviController` as a parameter.

## Feature-scoped coordinator

The coordinator keeps the controller and the routing rules; views stay ignorant of each other.

```swift
struct BFlowCoordinator {
    @DestinationRepresentable
    enum Destination {
        case stepTwo
        case stepThree
    }

    let controller: any NaviController
    private let onFinish: () -> Void

    func onStepOneNext() { controller.push(to: Destination.stepTwo) }
    func onStepTwoNext() { controller.push(to: Destination.stepThree) }
    func onFinishTapped() { onFinish() }      // caller decides: popToRoot() or hand back to a parent flow
    func goToRoot() { controller.popToRoot() }
}
```

Nested enums inside a struct or another coordinator are supported; the macro qualifies the extension
(`extension BFlowCoordinator.Destination: DestinationRepresentable`).

## Multi-step deep link across features

`deepLink(to:)` takes `[any DestinationRepresentable]`, so one route can span several feature enums.
Build the array in a dedicated builder (`Examples/Coordinators/Core/Deeplink`):

```swift
enum Deeplink {
    case homeTab(HomeTabDeeplink)
    case deeplinksTab(DeeplinksTabDeeplink)
}

struct HomeTabDeeplinkBuilder {
    func build(for deeplink: HomeTabDeeplink) async -> [any DestinationRepresentable] {
        switch deeplink {
        case .startBFlow:
            [HomeCoordinator.Coordinators.aFlow,
             AFlowCoordinator.Destination.stepTwo,
             AFlowCoordinator.Coordinators.bFlow]
        case .stepTwoOfAFlow:
            await loadStepTwoRoute()          // fetch data before routing
        }
    }

    private func loadStepTwoRoute() async -> [any DestinationRepresentable] {
        try? await Task.sleep(for: .seconds(2))
        return [HomeCoordinator.Coordinators.aFlow,
                AFlowCoordinator.Destination.stepTwo]
    }
}
```

```swift
let route = await HomeTabDeeplinkBuilder().build(for: .startBFlow)
controller.deepLink(to: route)
```

Deep links always replace the stack: `deepLink(to:)` resets to root first. Route arrays may repeat a
destination (`[main, viewA, viewB, viewC]`); each push re-registers its origin, and the last occurrence wins.

## Associated values

```swift
@DestinationRepresentable
enum DetailDestinations {
    @OriginKey case item(id: String)
    case user(userID: Int, name: String)
}

controller.push(to: DetailDestinations.item(id: "42"))
controller.pop(to: DetailDestinations.Origins.item)   // per case, not per id
```

Associated values must be `Hashable`. Origins are keyed per case: whether you pushed `item(id: "1")` or
`item(id: "42")`, there is a single `Origins.item` key pointing at the most recent one. If you need to return to a
specific value, don't use `@OriginKey` for that case — model the value as a stable screen or keep one case per step.

## Logging

```swift
import OSLog

struct AppLogger: NaviLogging {
    private let logger = Logger(subsystem: "com.example.app", category: "navigation")

    func logInfo(_ message: String) { logger.info("\(message)") }
    func logError(_ message: String) { logger.error("\(message)") }
}

@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties(logger: AppLogger())
}
```

Logs cover every push/pop, each origin registration and prune, and every failure (empty `pop()`, missing origin,
over-popping). Leave the logger out in production if you don't need the trail.

## Reading stack state

```swift
struct StackDepthBadge: View {
    let count: Int

    var body: some View {
        Text("Elements in stack: \(count)")
    }
}

StackDepthBadge(count: controller.properties.path.count)
```

`properties.path` is the only public state. `properties.naviStackOrigins` is internal to the Navi module — a
consumer app cannot inspect tracked origins, only `path.count`.
