# Popping to an origin

Return to a known screen without counting pops or reaching into the path.

## Overview

### The problem

`pop()` removes one screen and `popToRoot()` removes all of them. Neither expresses "go back to the
settings screen, wherever it sits in the stack" — with a plain `NavigationPath` you would compute a
count and call `removeLast(_:)`, which breaks the moment the route changes.

Navi models the target instead. Mark the destination:

```swift
@DestinationRepresentable
enum HomeDestinations {
    @OriginKey case settings
    case profile
}
```

and pop to it:

```swift
controller.pop(to: HomeDestinations.Origins.settings)
```

### What the macro generates

`@OriginKey` is a peer macro that generates nothing on its own. It is a marker read by
`@DestinationRepresentable`, which then emits two members on the destination enum:

```swift
enum HomeDestinations {
    case settings
    case profile

    var navigationOrigin: (any OriginRepresentable)? {
        switch self {
        case .settings: return Origins.settings
        case .profile: return nil
        }
    }

    enum Origins: OriginRepresentable {
        case settings
        var key: NavigationOriginKey { … }
    }
}
```

`Origins` is emitted only when at least one case is marked, and the `NavigationOriginKey` statics
inside it are `private` — `pop(to:)` takes the generated `Origins` case, never a key.

The enums that `@OriginKey` marks therefore have three properties worth knowing:

- **One origin per case, not per value.** `case detail(id: Int)` with a payload is a single
  `Origins.detail`; the most recent push wins. If you need to return to a specific value, don't make
  that case an origin.
- **Multi-element declarations are fully marked.** `@OriginKey case first, third` marks both.
- **Generic enums cannot host origins.** The generated key would be a static stored property, which
  Swift forbids in generic types; the macro reports an error instead. Generic destination enums
  without `@OriginKey` are fine.

### How the index is tracked

Origins are recorded at push time and pruned when the stack shrinks:

| Call | Effect on origins |
|---|---|
| `push(to:)` | Records `origin.key → path.count` — the pushed screen's 1-based depth |
| `pop()` | Prunes any origin whose index exceeds the new count |
| `popToRoot()` | Clears every origin |
| `pop(to:)` | Removes `count - index` trailing destinations; the origin screen itself **stays** |
| `deepLink(to:)` | Clears, then re-registers origins through its pushes |

Pruning lives in the controller: `pop()`, `pop(to:)`, and `popToRoot()` reconcile the tracked
origins as part of the mutation. SwiftUI's own back button and swipe-to-go-back mutate the bound
`NavigationPath` directly and bypass the controller, so origins are only reconciled on the next
`pop()`, or overwritten by the next `push(to:)`. Don't call `pop(to:)` right after a user-driven back
— push again, or use `pop()` / `popToRoot()`.

### Calling `pop(to:)` with a stale origin

If the key is not in the table, the controller logs an error through ``NaviLogging`` and calls
`assertionFailure`: a debug crash, a silent no-op in release. Usually this means the origin screen was
never pushed, or the case is missing `@OriginKey`.

### Visibility across modules

The macro emits its members without an access modifier, so for a `public` destination enum the
`Origins` enum, `navigationOrigin`, and the conformance are all `internal`. `PublicEnum.Origins.settings`
does not compile from another module.

Keep destination enums internal to the module that declares the views for them, or call `pop(to:)`
from that same module. Cross-module navigation goes through `push(to:)` / `deepLink(to:)`, which are
generic and only need the ``DestinationRepresentable`` conformance.
