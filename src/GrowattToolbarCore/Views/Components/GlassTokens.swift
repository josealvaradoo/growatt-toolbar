import SwiftUI

/// Compact Control Center tile-scale design tokens used across a 280pt-wide
/// flat-surface popover (single-card layout, not a multi-card dashboard).
/// Mirrors the macOS 26 Liquid Glass design system — spacing, corner radii,
/// and typography are tuned for one glanceable panel rather than a
/// free-form canvas.
public enum GlassTokens {
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
        public static let xxs:     CGFloat = 2
        public static let xs:      CGFloat = 4
        public static let sm:      CGFloat = 8
        public static let md:      CGFloat = 12
        public static let xl:      CGFloat = 20
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
