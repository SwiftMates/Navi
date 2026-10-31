# ``Navi``

Type-safe programmatic navigation for SwiftUI, built on `NavigationStack`.

## Overview

Navi is a thin typed layer over Apple's `NavigationStack`. It adds compile-time checked
destinations, a programmatic API (`push`, `pop`, `popToRoot`), multi-step deep linking, and
pop-to-destination — without replacing the native navigation model or imposing an architecture.

A conforming controller owns the `NavigationPath` that a `NavigationStack` renders, so every
mutation goes through one place:

```swift
@Observable
final class AppController: NaviController {
    var properties = NaviControllerProperties()
}

@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}

controller.push(to: HomeDestinations.settings)
controller.pop(to: HomeDestinations.Origins.settings)
```

Navi does not require a single global route enum: each feature can declare its own
`@DestinationRepresentable` enum and register it with `navigationDestination(for:)` where it is used.
`deepLink(to:)` is the one API that accepts heterogeneous routes, so a route can span features
without a shared umbrella type.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DeepLinking>
- <doc:PopToOrigin>
- <doc:SupportingiOS16>

### Guides

- <doc:MigratingFromNavigationPath>

### Controllers

- ``NaviController``
- ``NaviControllerProperties``

### Destinations

- ``DestinationRepresentable``
- ``OriginRepresentable``
- ``NavigationOriginKey``

### Macros

- ``DestinationRepresentable()``
- ``OriginKey()``

### Logging

- ``NaviLogging``
