# Navi API Reference

Source of truth: `Sources/Core/` and `Sources/NaviMacrosPlugin/`. Signatures below match the current
`develop` implementation (generics, not existentials).

## Requirements

| Item | Value |
|---|---|
| iOS / macOS | 16.0+ / 13.0+ |
| Swift | 6.0+ (tools 6.0–6.4 via `Package@swift-*.swift`) |
| Xcode | 16.0+ |
| Runtime dependencies | none |
| Build-time dependency | `swift-syntax` (macro plugin target `NaviMacrosPlugin` only) |

## Protocols

### `NaviController`

```swift
@MainActor
public protocol NaviController: AnyObject {
    var properties: NaviControllerProperties { get set }

    func push<D: DestinationRepresentable>(to destination: D)
    func pop()
    func popToRoot()
    func pop<O: OriginRepresentable>(to origin: O)
    func deepLink(to newPath: [any DestinationRepresentable])
}
```

- All members are main-actor isolated; the whole extension of default implementations is `@MainActor`.
- Every method has a default implementation, so a conformance only has to supply `properties`.
- `push` and `pop(to:)` are **generic** in the destination/origin type (`D: DestinationRepresentable`,
  `O: OriginRepresentable`) rather than taking existentials; only `deepLink(to:)` accepts
  `[any DestinationRepresentable]`. Passing an existential from such an array to `push` still works through
  implicit existential opening (that is what `deepLink` itself does), but call sites should normally pass the
  concrete case.

### `DestinationRepresentable`

```swift
public protocol DestinationRepresentable: Hashable {
    var navigationOrigin: (any OriginRepresentable)? { get }
}
```

Default `navigationOrigin` returns `nil`. Prefer the `@DestinationRepresentable` macro over manual conformance.

### `OriginRepresentable`

```swift
public protocol OriginRepresentable {
    var key: NavigationOriginKey { get }
}
```

### `NaviLogging`

```swift
public protocol NaviLogging {
    func logInfo(_ message: String)
    func logError(_ message: String)
}
```

Optional. Pass an instance to `NaviControllerProperties(logger:)`; omit or pass `nil` to disable logging.
Navi logs every push, pop, origin registration, origin prune, and failure through this protocol.

## Types

### `NaviControllerProperties`

```swift
public struct NaviControllerProperties {
    public var path: NavigationPath
    public init(logger: (any NaviLogging)? = nil)
}
```

Only `path` is public. `naviStackOrigins` and `logger` are internal — read them only from inside the Navi
module (tests use `@testable import Navi`). The struct is a value type, so the controller must expose it as a
mutable `var` for `NavigationStack(path: $controller.properties.path)` to bind.

### `NavigationOriginKey`

```swift
public struct NavigationOriginKey: Hashable, Sendable {
    public init(debugName: String? = nil)
}
```

Identity is a fresh `UUID` per instance; `debugName` is a dev-facing label used in logs. Keys are not
`Codable`, so origin state is inherently in-memory and is not restored across launches.

## Macros

```swift
@attached(member, names: named(navigationOrigin), named(Origins))
@attached(extension, conformances: DestinationRepresentable)
public macro DestinationRepresentable()

@attached(peer)
public macro OriginKey()
```

`@DestinationRepresentable` goes on the enum, `@OriginKey` on the individual cases that should be pop targets.
`@OriginKey` is a peer macro that generates nothing itself — it is only a marker the `@DestinationRepresentable`
enum macro reads, so it has no effect without `@DestinationRepresentable` on the enum.

### Exact expansion

```swift
@DestinationRepresentable
enum Destination {
    @OriginKey case first
    case second
}
```

```swift
enum Destination {
    case first
    case second

    var navigationOrigin: (any OriginRepresentable)? {
        switch self {
        case .first:
            return Origins.first
        case .second:
            return nil
        }
    }

    enum Origins: OriginRepresentable {
        case first
        var key: NavigationOriginKey {
            switch self {
            case .first:
                Self.firstOriginKey
            }
        }
        static private let firstOriginKey = NavigationOriginKey(debugName: "Destination - first Origin")
    }
}

extension Destination: DestinationRepresentable {
}
```

Behaviour notes:

- `Origins` is only generated when at least one case is marked. A macro-generated `enum` case stands in for the
  origin, so `pop(to:)` receives `Destination.Origins.first`, never the key itself (the `…OriginKey` statics are
  `private`).
- `@OriginKey case first, third` marks **every** element of that declaration.
- Cases with associated values keep their payload on the destination enum and are keyed as value-less `Origins`
  cases. The pattern `case .detail:` matches any payload, so the origin is per **case**, not per value.
- Keyword case names work (`case \`default\`` → `Origins.default`); backticks are stripped for the key name.
- Nested enums are supported and the extension is qualified: `extension Box.Destination: DestinationRepresentable`,
  `extension Outer.Middle.Destination: …`.
- Generic enums are supported **without** `@OriginKey`; the extension adds `where T: Hashable` for each parameter
  (and keeps the enum's own where clause).
- Generated members carry no access modifier, so for a `public` enum `Origins`, `navigationOrigin`, and the
  conformance are internal. Cross-module `pop(to: PublicEnum.Origins.x)` does not compile — keep destination
  enums internal, or navigate from the declaring module.
- Re-declaring the conformance yourself (`enum X: DestinationRepresentable`) is honoured: the extension macro
  emits nothing.

### Diagnostics (all errors)

| Situation | Message |
|---|---|
| Macro on struct / class / actor / protocol | `@DestinationRepresentable can only be applied to an enum` |
| Enum without cases | `@DestinationRepresentable can only be applied to an enum with at least one case` |
| `@OriginKey` on anything that is not an enum case | `@OriginKey can only be applied to an enum case` |
| `@OriginKey` on a case of a **generic** enum | `@OriginKey is not supported on a case of a generic enum, because its generated origin key would be a static stored property, which Swift does not allow in generic types` |
| `@OriginKey` on a raw-identifier case (`` case `my case` ``) | `@OriginKey is not supported on a case whose name is a raw identifier, because the generated origin key would not be a valid Swift identifier` |

In the generic-enum and raw-identifier cases the macro bails out (or skips that case), so the type compiles
but the case has no origin — `pop(to:)` for it is a debug assertion.

## `NaviController` semantics (verified against `NaviControllerTests`)

| Method | Path effect | Origin effect |
|---|---|---|
| `push(to:)` | Appends one destination | Records `origin.key → path.count` (the pushed screen's 1-based depth) |
| `pop()` | Removes the last destination; logs an error when the path is empty | Prunes any origin whose index exceeds the new count |
| `popToRoot()` | Replaces the path with an empty `NavigationPath` | Clears every origin |
| `pop(to: origin)` | Removes `count - originIndex` trailing destinations — the origin screen itself **stays** | Removes origins of the popped screens; a stale index equal to the top means "no change" |
| `deepLink(to: [ … ])` | `popToRoot()` first, then pushes the array in order | Origins are re-registered by the pushes; the last occurrence of a repeated case wins |

Consequences worth planning around:

- Pushing the same `@OriginKey` case twice overwrites the stored index with the most recent depth, so
  `pop(to:)` always targets the **shallowest path back to the latest occurrence**.
- SwiftUI's swipe-back / system back button mutates the bound `NavigationPath` directly and bypasses `pop()`, so
  origins are not reconciled until the next `pop()` (prune) or `push` (overwrite). If you need `pop(to:)` right
  after a user-driven back, re-push or use `pop()`/`popToRoot()` instead.
- Assigning `properties.path` yourself (or calling `path.append`/`removeLast`) skips origin bookkeeping entirely.
  Prefer the controller API everywhere.
- `pop(to:)` for an origin that was never pushed logs an error and calls `assertionFailure` — a debug crash, a
  silent no-op in release.
