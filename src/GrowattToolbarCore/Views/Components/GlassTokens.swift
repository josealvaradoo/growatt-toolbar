import SwiftUI

/// Centralized Liquid Glass design tokens used across the popover and its
/// sub-components. Mirrors the iOS 26 / macOS 26 design system spacing and
/// corner radii so the whole surface reads as a single, cohesive material.
public enum GlassTokens {
    /// Corner radii (in points) for each glass surface in the hierarchy.
    public enum Radius {
        /// Outer popover window.
        public static let popover: CGFloat = 24
        /// Hero card showing battery percentage and indicator.
        public static let card: CGFloat = 20
        /// Compact metric tile.
        public static let tile: CGFloat = 14
        /// Pill / button.
        public static let pill: CGFloat = 999
    }

    /// Edge insets for each glass surface.
    public enum Padding {
        /// Popover outer padding.
        public static let popover: CGFloat = 18
        /// Inner padding for cards.
        public static let card: CGFloat = 16
        /// Inner padding for compact tiles.
        public static let tile: CGFloat = 12
    }

    /// Minimum interactive size for control surfaces.
    public enum ControlSize {
        public static let button: CGFloat = 32
    }
}
