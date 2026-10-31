//
//  DestinationMacro.swift
//  Navi
//
//  Created by David Pall on 2026. 07. 21..
//

/// Generates a ``DestinationRepresentable`` conformance for an enum of navigation destinations.
///
/// Apply the macro to the enum you pass to `navigationDestination(for:)`. The macro is enum-only and
/// works at compile time — it emits no runtime code beyond the members described below.
///
/// ```swift
/// @DestinationRepresentable
/// enum HomeDestinations {
///     @OriginKey case settings
///     case profile
/// }
/// ```
///
/// ## Generated members
///
/// - A `navigationOrigin` property that returns `nil` for every case, unless the case is marked with
///   ``OriginKey()`` — then it returns the matching `Origins` case.
/// - An `extension` declaring the ``DestinationRepresentable`` conformance. If you already declared it
///   yourself, nothing is emitted.
/// - A nested `Origins` enum conforming to ``OriginRepresentable``, but only when at least one case is
///   marked with ``OriginKey()``. It is what ``NaviController/pop(to:)`` accepts.
///
/// ## Requirements
///
/// - The attached declaration must be an `enum` with at least one case; anything else is a compile
///   error.
/// - Cases marked with ``OriginKey()`` may not belong to a generic enum, because the generated origin
///   key would be a static stored property.
/// - Generated members carry no access modifier. On a `public` enum, `Origins`, `navigationOrigin`, and
///   the conformance are therefore `internal`, so `pop(to:)` must be called from the declaring module.
///
/// ## See Also
///
/// - ``OriginKey()``
/// - ``DestinationRepresentable``
@attached(member, names: named(navigationOrigin), named(Origins))
@attached(extension, conformances: DestinationRepresentable)
public macro DestinationRepresentable() = #externalMacro(
    module: "NaviMacrosPlugin",
    type: "DestinationRepresentableMacro"
)

/// Marks an enum case as a pop target for ``NaviController/pop(to:)``.
///
/// A peer macro that generates no code of its own: it is a marker read by ``DestinationRepresentable()``,
/// which uses it to emit the enum's `Origins` type and its `navigationOrigin` mapping. Used without
/// ``DestinationRepresentable()`` on the enclosing enum it has no effect beyond validation.
///
/// ```swift
/// @DestinationRepresentable
/// enum HomeDestinations {
///     @OriginKey case settings
///     case profile
/// }
///
/// controller.pop(to: HomeDestinations.Origins.settings)
/// ```
///
/// ## Scope
///
/// An origin is tracked per **case**, not per value: `@OriginKey case detail(id: Int)` produces a single
/// `Origins.detail` that points at the most recent push. `@OriginKey case first, third` marks every
/// element of that declaration.
///
/// ## Diagnosed misuse
///
/// Each of these is a compile error, not a fallback:
///
/// - Applied to anything other than an enum case.
/// - Applied to a case of a generic enum: the generated key would need a static stored property, which
///   Swift does not allow in generic types.
/// - Applied to a case whose name is a raw identifier: the generated key would not be a valid Swift
///   identifier, so the case cannot be used as an origin.
///
/// ## See Also
///
/// - ``DestinationRepresentable()``
/// - ``OriginRepresentable``
@attached(peer)
public macro OriginKey() = #externalMacro(
    module: "NaviMacrosPlugin",
    type: "OriginKeyMacro"
)
