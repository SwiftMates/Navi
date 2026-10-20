# Migrating to Navi

Navi is additive: it wraps `NavigationStack` and does not force an architecture. Migrate one feature at a time.

## From raw `NavigationPath`

**Before**

```swift
@State private var path = NavigationPath()

NavigationStack(path: $path) { … }

path.append(HomeRoute.settings)
path.removeLast()
path = NavigationPath()                       // pop to root
```

**After**

```swift
@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}

NavigationStack(path: $controller.properties.path) { … }

controller.push(to: HomeDestinations.settings)
controller.pop()
controller.popToRoot()
```

Call-site map:

| Raw path | Navi |
|---|---|
| `path.append(route)` | `controller.push(to: route)` |
| `path.removeLast()` | `controller.pop()` |
| `path = NavigationPath()` | `controller.popToRoot()` |
| `path.count` | `controller.properties.path.count` |
| `path.removeLast(n)` / manual surgery | none — model the target as an `@OriginKey` case and call `pop(to:)` |
| `onOpenURL { path.append(…) }` route building | `controller.deepLink(to: route)` |

Two rules matter here:

1. Keep using `NavigationStack(path: $controller.properties.path)` — never mutate the path directly once the
   controller owns it, or origin tracking silently desyncs.
2. The controller must be a `var` property on an `@Observable` / `ObservableObject` type, otherwise SwiftUI will
   not re-render the stack when the path changes.

## From a typed path array (`NavigationStack(path: $path)` with `[Route]`)

A homogeneous `[Route]` array maps cleanly onto `NavigationPath`:

**Before**

```swift
@State private var path: [Route] = []

NavigationStack(path: $path) { destination in
    switch destination {
    case .settings: SettingsView()
    case .profile: ProfileView()
    }
}
```

**After**

```swift
@DestinationRepresentable
enum Route {
    @OriginKey case settings
    case profile
}

@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}

NavigationStack(path: $controller.properties.path) {
    HomeView()
        .navigationDestination(for: Route.self) { destination in
            switch destination {
            case .settings: SettingsView()
            case .profile: ProfileView()
            }
        }
}
```

`NavigationPath` is type-erased, so if you later deep-link across several features you gain the ability to mix
enums in one route (`deepLink(to: [A.x, B.y])`) instead of inventing a shared umbrella enum.

## From the classic coordinator pattern

Keep the coordinators; swap what they own. Instead of each coordinator holding a mutable path, a `UINavigationController`,
or firing a callback per push, inject `any NaviController` and expose only intent-shaped methods.

**Before**

```swift
final class SettingsCoordinator {
    private let navigationController: UINavigationController
    var onFinish: (() -> Void)?

    func start() {
        let vc = SettingsViewController()
        vc.onDone = { self.onFinish?() }
        navigationController.pushViewController(vc, animated: true)
    }
}
```

**After**

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
    func showNotifications() { controller.push(to: Destination.notifications) }
    func showDetail(id: UUID) { controller.push(to: Destination.detail(id: id)) }
    func backToNotifications() { controller.pop(to: Destination.Origins.notifications) }
    func finish() { onFinish() }                 // the owner decides whether to pop or popToRoot
}
```

Rules that keep this clean:

- Coordinators own `@DestinationRepresentable` enums **and** the switch that maps them to views; the views own
  layout only.
- Inject `any NaviController`, not a concrete controller type, so flows compose (a flow started inside another
  flow just receives the same controller).
- One controller per `NavigationStack`. A flow that opens a sheet with its own stack needs its own controller.
- Callbacks stay for *decisions* ("the flow ended, what now?"), not for *navigation*.

## From shared / singleton navigation state

A single app-wide navigation object usually breaks with `NavigationStack` (one stack per tab or column). Split it:
the root owns the controllers, each stack gets one, and flows receive the controller of the stack they live in.
`Examples/Coordinators` shows the shape: `MainTabView` builds a `NavigationStackWrapper` per tab, and each
coordinator receives that tab's `NavigationController`.

## Gradual adoption

1. Add the package dependency.
2. Introduce one `NaviController` at the root of one stack and pass it down (or inject it via the environment).
3. Convert one feature's routes into a `@DestinationRepresentable` enum; register it with
   `.navigationDestination(for:)` where the enum is used.
4. Replace that feature's `path.append` / `removeLast` with `push` / `pop` / `popToRoot`.
5. Add `@OriginKey` only to the cases you actually want to pop back to, then replace manual surgery with `pop(to:)`.

Leave the remaining features on the raw path until you get to them — Navi and direct path mutation coexist as long
as each stack has exactly one owner of the mutations.

## Gotchas during migration

| Symptom | Cause | Fix |
|---|---|---|
| Stack never updates | controller is a plain class, or `properties` is a `let` | `@Observable` (iOS 17+) or `ObservableObject` + `@Published`, and a settable `var properties` |
| Missing `@MainActor` diagnostics | `NaviController` is main-actor isolated | annotate the controller (and the type holding it) `@MainActor`; the `ObservableObject` variant needs it explicitly |
| `pop(to:)` asserts in debug | origin was never pushed, or the case has no `@OriginKey` | push the origin first; mark the case with `@OriginKey` |
| `pop(to:)` goes to the wrong depth after a swipe-back | SwiftUI mutated the bound path directly; origins are only reconciled on the next `pop()` / `push` | avoid `pop(to:)` immediately after user-driven back — re-push or use `pop()` / `popToRoot()` |
| Deep link appends instead of replacing | expected `deepLink` to extend the stack | `deepLink(to:)` always resets to root first; push the full route array |
| `@OriginKey` rejected on a generic enum | generated key would be a static stored property | drop `@OriginKey` there (generic enums without it are fine) or make the enum non-generic |
| `PublicEnum.Origins.x` not found in another module | generated `Origins` and the conformance are internal | keep destination enums internal, or call `pop(to:)` from the module that declares the enum |
| Wrong screen after `pop(to:)` when the same case appears twice | one key per case, last push wins | target the state, not the value — don't reuse `@OriginKey` cases with different payloads |

## Verification checklist

- [ ] `swift build` / app builds with no macro diagnostics.
- [ ] Every `NavigationStack` in the app has exactly one `NaviController` owner.
- [ ] No remaining `path.append` / `path.removeLast` / `path = NavigationPath()` outside the controller.
- [ ] Each `.navigationDestination(for:)` enum is `@DestinationRepresentable` (no manual conformance left).
- [ ] Every `pop(to:)` target has `@OriginKey` and is reachable by a push in the tested route.
- [ ] Deep links reset the stack rather than nesting onto the current one.
- [ ] Optional: a `NaviLogging` implementation is wired up while migrating, then removed or kept deliberately.
