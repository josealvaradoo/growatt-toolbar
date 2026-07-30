import SwiftUI

/// Centralized Liquid Glass design tokens used across the popover and its
/// sub-components. Mirrors the iOS 26 / macOS 26 design system spacing and
/// corner radii so the whole surface reads as a single, cohesive material.
public enum GlassTokens {
    /// Corner radii (in points) for each glass surface in the hierarchy.
    ///
    /// The popover background uses a local `PopoverGeometry.cornerRadius`
    /// constant (24pt) rather than a value here — it's a single-use
    /// surface-specific number, and the principled macOS 26+ choice
    /// (`.containerConcentric` via `.corners(.containerConcentric())`)
    /// would require platform branching the Package.swift floor wouldn't
    /// tolerate. The hero card and metric tile use the values here
    /// because they are nested surfaces, not container-filling ones.
    public enum Radius {
        /// Hero card showing battery percentage and indicator.
        public static let card: CGFloat = 20
        /// Compact metric tile.
        public static let tile: CGFloat = 14
        /// Battery-indicator terminal nub (the small "+" tip on the right of the bar).
        public static let terminal: CGFloat = 3
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

    /// Inter-element spacing. Apple's effective scale is 4/8 with a 2pt
    /// half-step for optical adjustments. Use `xxs` and `hairline` only for
    /// micro-adjustments, never for structural layout.
    public enum Spacing {
        public static let hairline: CGFloat = 1
        public static let xxs:     CGFloat = 2
        public static let xs:      CGFloat = 4
        public static let sm:      CGFloat = 8
        public static let md:      CGFloat = 12
        public static let lg:      CGFloat = 16
        public static let xl:      CGFloat = 20
        public static let xxl:     CGFloat = 24
        public static let xxxl:    CGFloat = 32
    }

    /// Numeric typography. The hero percentage is a deliberate 44pt
    /// display number (DESIGN.md `typography.display-sm`) — the fixed
    /// point means the popover does not scale with Dynamic Type. This is
    /// a conscious design trade-off (the hero is a glance instrument,
    /// not body copy); the trade-off is documented at the call site.
    public enum Numeric {
        public static let hero: Font = .system(size: 44, weight: .bold, design: .rounded)
    }
}
