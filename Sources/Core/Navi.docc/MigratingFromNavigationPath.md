# Migrating from NavigationPath

Navi is additive: it wraps `NavigationStack` and does not force an architecture. Migrate one feature
at a time and leave the rest on the raw path until you get to them.

## Overview

### Before and after

**Before** — the view owns navigation state, and every mutation is an ad-hoc call on the path:

```swift
struct AppRoot: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
        }
    }
}

path.append(HomeRoute.settings)
path.removeLast()
path = NavigationPath()
```

**After** — one controller owns the path, and call sites express intent:

```swift
@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}

NavigationStack(path: $controller.properties.path) {
    HomeView()
}

controller.push(to: HomeDestinations.settings)
controller.pop()
controller.popToRoot()
```

### Call-site map

| Raw path | Navi |
|---|---|
| `path.append(route)` | `controller.push(to: route)` |
| `path.removeLast()` | `controller.pop()` |
| `path = NavigationPath()` | `controller.popToRoot()` |
| `path.count` | `controller.properties.path.count` |
| `path.removeLast(n)` or manual surgery | model the target as an ``OriginKey()`` case and call `pop(to:)` |
| `onOpenURL { path.append(…) }` | `controller.deepLink(to: route)` |

See <doc:PopToOrigin> for the origin-based replacement of manual path surgery.

### Two rules

1. **Keep binding to `$controller.properties.path`** and never mutate the path directly once the
   controller owns it. Direct `append` / `removeLast` / assignment bypasses origin tracking, and the
   next `pop(to:)` targets a stale index.
2. **The controller must be observable** (`@Observable`, or `ObservableObject` with `@Published` on
   iOS 16 — see <doc:SupportingiOS16>) and `properties` must be a settable `var`, or the stack will
   not re-render.

### From a typed path array

A homogeneous `[Route]` array maps cleanly onto `NavigationPath`:

```swift
// Before
@State private var path: [Route] = []

// After
@DestinationRepresentable
enum Route {
    @OriginKey case settings
    case profile
}
```

Because `NavigationPath` is type-erased, converting also unlocks mixing enums in one route
(`deepLink(to: [A.x, B.y])`) instead of maintaining a shared umbrella enum.

### The coordinator pattern

Keep the coordinators; change what they own. Inject `any NaviController` instead of holding a path or
a `UINavigationController`, and expose intent-shaped methods:

```swift
struct SettingsCoordinator {
    @DestinationRepresentable
    enum Destination {
        case root
        @OriginKey case notifications
        case detail(id: UUID)
    }

    let controller: any NaviController
    private let onFinish: () -> Void

    func start() { controller.push(to: Destination.root) }
    func showDetail(id: UUID) { controller.push(to: Destination.detail(id: id)) }
    func backToNotifications() { controller.pop(to: Destination.Origins.notifications) }
    func finish() { onFinish() }   // the owner decides: pop, popToRoot, or dismiss
}
```

- The coordinator owns the destination enum and the switch mapping it to views; the views own layout.
- Inject `any NaviController`, not a concrete type, so flows compose.
- Callbacks stay for decisions ("the flow ended, what now?"), not for navigation.

### One controller per stack

A single app-wide navigation object breaks with `NavigationStack`, because each tab or column has its
own stack. Give each stack its own controller and pass it into that stack's flows:

```swift
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

Keep the stored type concrete — a `@State` of `any NaviController` is not observed by SwiftUI, even
though functions can take `any NaviController` as a parameter.

### Gotchas

| Symptom | Cause | Fix |
|---|---|---|
| Stack never updates | controller is a plain class, or `properties` is `let` | make it `@Observable` / `ObservableObject` with a settable `var properties` |
| Missing `@MainActor` diagnostics | ``NaviController`` is main-actor isolated | annotate the controller and its owner `@MainActor`; the `ObservableObject` variant needs it explicitly |
| `pop(to:)` asserts in debug | origin was never pushed, or the case lacks `@OriginKey` | push the origin first, or mark the case |
| `pop(to:)` lands on the wrong depth | same origin case pushed twice — the latest push wins | target state, not values; don't reuse an origin case with different payloads |
| `pop(to:)` goes to the wrong depth after a swipe-back | SwiftUI mutated the bound path directly; origins reconcile on the next `pop()` or `push` | avoid `pop(to:)` right after a user-driven back — re-push, or use `pop()` / `popToRoot()` |
| Deep link appends instead of replacing | `deepLink(to:)` extends nothing — it resets first | pass the full route |
| `PublicEnum.Origins.x` not found across modules | generated members are `internal` | keep destination enums internal, or pop from the declaring module |

### Checklist

- [ ] `swift build` passes with no macro diagnostics.
- [ ] Every `NavigationStack` has exactly one controller owner.
- [ ] No `path.append` / `path.removeLast` / `path = NavigationPath()` left outside the controller.
- [ ] Every enum passed to `.navigationDestination(for:)` is `@DestinationRepresentable`.
- [ ] Every `pop(to:)` target has `@OriginKey` and is reachable through a push in the tested route.
- [ ] Deep links rebuild the stack rather than nesting onto it.
- [ ] Optional: a ``NaviLogging`` implementation is wired up during the migration, then kept or removed deliberately.
