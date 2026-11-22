# Deep linking

Replace the current stack with a multi-step route in one call.

## Overview

### Semantics

`deepLink(to:)` resets to root first, then pushes the destinations in order:

```swift
controller.deepLink(to: [
    HomeDestinations.settings,
    SettingsDestinations.notifications,
    NotificationsDestinations.email
])
```

Two consequences follow from that implementation:

- **It replaces, it does not append.** Calling `deepLink` while the user is already three screens
  deep returns to root and rebuilds the stack. If you need to extend the current stack, use
  `push(to:)`.
- **Order matters.** Destinations are pushed front to back, so the last element ends up on top and
  each intermediate screen is rendered once for the duration of the transition.

### Heterogeneous routes

The parameter is `[any DestinationRepresentable]`, the only place Navi accepts type-erased
destinations. A single route can therefore span several per-feature enums without a shared umbrella
type:

```swift
let route: [any DestinationRepresentable] = [
    HomeCoordinator.Coordinators.aFlow,
    AFlowCoordinator.Destination.stepTwo,
    BFlowCoordinator.Destination.stepThree
]
controller.deepLink(to: route)
```

Push call sites should stay generic over the concrete case; only routing tables need the existential.

### Building routes asynchronously

Route construction usually depends on data that arrives with the link. Build the array first, then
navigate once — `deepLink(to:)` is synchronous and main-actor isolated, so it should not be
interleaved with awaits:

```swift
struct HomeTabDeeplinkBuilder {
    func build(for deeplink: HomeTabDeeplink) async -> [any DestinationRepresentable] {
        switch deeplink {
        case .startBFlow:
            [HomeCoordinator.Coordinators.aFlow, AFlowCoordinator.Destination.stepTwo]
        case .stepTwoOfAFlow:
            await loadStepTwoRoute()
        }
    }
}

let route = await HomeTabDeeplinkBuilder().build(for: .startBFlow)
controller.deepLink(to: route)
```

### Interaction with origins

Every push performed by `deepLink` records its origin exactly like a manual `push(to:)`. If the route
repeats a case that carries ``OriginKey()``, the last occurrence wins, because each push overwrites
the stored index for that key:

```swift
@DestinationRepresentable
enum FlowDestinations {
    @OriginKey case list
    case detail(id: Int)
}

controller.deepLink(to: [
    FlowDestinations.list,
    FlowDestinations.detail(id: 1),
    FlowDestinations.list        // Origins.list now points at depth 3
])
```

Model the route so that a repeated origin case is intentional; otherwise take the origin out of the
enum and track the state explicitly. See <doc:PopToOrigin> for what the stored index means at pop
time.

### Failure modes

`deepLink(to:)` cannot fail: it clears the path and pushes unconditionally. The silent trap is origin
state — the reset discards every origin the route does not re-push, so a later `pop(to:)` for an
omitted case asserts in debug. Build the route as the full path you want, not as a delta.
