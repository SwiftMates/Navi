//
//  NavigationBackSource.swift
//  Navi
//
//  Created by Lazar-Kiss Mark on 11/11/2026.
//

/// Indicates how a reduction of the navigation path was initiated.
///
/// Reported through ``NaviController/didNavigateBack(removedCount:newCount:source:)``.
public enum NavigationBackSource: Sendable, Equatable {

    /// Caused by a Navi API call: ``NaviController/pop()``, ``NaviController/pop(to:)``,
    /// or ``NaviController/popToRoot()``.
    case programmatic

    /// Caused by the system back button or the interactive swipe-to-go-back gesture.
    ///
    /// SwiftUI does not expose a way to tell these two apart, so they share a single case.
    case systemOrGesture
}
