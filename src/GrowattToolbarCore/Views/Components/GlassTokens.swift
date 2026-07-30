import SwiftUI

/// Compact Control Center tile-scale design tokens used across a 280pt-wide
/// flat-surface popover (single-card layout, not a multi-card dashboard).
/// Mirrors the macOS 26 Liquid Glass design system — spacing, corner radii,
/// and typography are tuned for one glanceable panel rather than a
/// free-form canvas.
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
        /// Battery-indicator terminal nub (the small "+" tip on the right of the bar).
        public static let terminal: CGFloat = 3
    }

    /// Edge insets for each glass surface.
    public enum Padding {
        /// Popover outer padding for a 280pt-wide compact surface.
        public static let popover: CGFloat = 16
        /// Inner padding for cards.
        public static let card: CGFloat = 16
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

    /// Numeric typography for the compact Control Center tile. The hero
    /// percentage uses a 28pt display number — scaled down from the
    /// original 44pt dashboard hero to fit the 280pt-wide single-card
    /// popover. The fixed point size means the popover does not scale
    /// with Dynamic Type; this is a conscious trade-off (the hero is a
    /// glance instrument, not body copy).
    public enum Numeric {
        public static let hero: Font = .system(size: 28, weight: .bold, design: .rounded)
    }
}
