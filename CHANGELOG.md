# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-31

First stable release. `develop` (`de14eed`) is 14 commits ahead of `0.0.4`.

### Added
- `@DestinationRepresentable` and `@OriginKey` macros (`Sources/Core/Macros/DestinationMacro.swift:8`, `Sources/NaviMacrosPlugin/DestinationMacroImpl.swift`) — type-safe destination declarations with auto-generated `Origins` and `navigationOrigin` (#24)
- `OriginRepresentable` / `NavigationOriginKey` support for `pop(to:)` with tracked origins (`Sources/Core/Navigation/OriginRepresentable.swift:15`, `Sources/Core/Navigation/NaviController.swift:14`) (#28)
- `Examples/Basic-iOS16` example project for iOS 16 / macOS 13 using `ObservableObject` + `@Published` (`Examples/Basic-iOS16/Basic-iOS16/BasicExampleController.swift:11`) (#39)

### Changed
- Minimum deployment lowered to **iOS 16.0+ / macOS 13.0+** (`Package.swift:9`) — previously iOS 17 / macOS 14 (#39)
- `NaviControllerProperties` logger is now **optional** (`Sources/Core/Navigation/NaviControllerProperties.swift:27`): `init(logger: (any NaviLogging)? = nil)`; `Sources/Core/Logger/NaviLogging.swift:9` renamed from `NaviLoggerable` (#30, #33)
- README updated: requirements matrix with Swift 6 / Xcode 16, restructured Basic Usage with optional logger and dual controller examples (Observable vs ObservableObject), Examples table

### Fixed
- Macro generates no code for enums with no cases (`Sources/NaviMacrosPlugin/DestinationMacroImpl.swift`) (#35)
- String interpolation warning in `Sources/Core/Navigation/NaviController.swift:156` (#33)

### CI / Tooling
- PR validation now builds `Examples/Basic` (`fastlane/Fastfile`, `.github/workflows/pr-validation.yml:12`) (#36)
- Dependabot configured for GitHub Actions, Bundler, and Swift packages (`.github/dependabot.yml`) (#38)

### Known follow-up (not in 1.0.0)
- Swipe-back / direct `NavigationPath` mutation coverage added as tests in `feature/cover-navigation-path-changes-on-back-or-swie-to-back` (`Tests/Core/Navigation/NaviControllerTests.swift:159`); docs/behaviour may be refined post-1.0.0 (#41 pending)
- Coordinator example remains on `feature/coordinator-demo` (DRAFT #34) — planned post-1.0.0

[1.0.0]: https://github.com/SwiftMates/Navi/releases/tag/1.0.0
