import SwiftUI

/// Centralized Liquid Glass design tokens used across the popover and its
/// sub-components. Mirrors the iOS 26 / macOS 26 design system spacing and
/// corner radii so the whole surface reads as a single, cohesive material.
enum GlassTokens {
    /// Corner radii (in points) for each glass surface in the hierarchy.
    enum Radius {
        /// Outer popover window.
        static let popover: CGFloat = 24
        /// Hero card showing battery percentage and indicator.
        static let card: CGFloat = 20
        /// Compact metric tile.
        static let tile: CGFloat = 14
        /// Pill / button.
        static let pill: CGFloat = 999
    }

    /// Edge insets for each glass surface.
    enum Padding {
        /// Popover outer padding.
        static let popover: CGFloat = 18
        /// Inner padding for cards.
        static let card: CGFloat = 16
        /// Inner padding for compact tiles.
        static let tile: CGFloat = 12
    }

    /// Minimum interactive size for control surfaces.
    enum ControlSize {
        static let button: CGFloat = 32
    }
}
