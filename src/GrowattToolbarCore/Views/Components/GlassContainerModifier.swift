import SwiftUI

/// View modifier that wraps the content in a `GlassEffectContainer` on
/// macOS 26+, and is a no-op on macOS 15.
///
/// `GlassEffectContainer` is the Liquid Glass primitive that gives a
/// group of nearby glass surfaces a shared sampling region. Without it,
/// each `.glassEffect(...)` call is computed independently — the lensing
/// and specular highlights on the popover background, the state badge,
/// and the refresh button are computed as three separate planes. With it,
/// they're one coherent glass plane.
///
/// Per `DESIGN.md`, every view that composes two or more nearby glass
/// surfaces should call `.glassContainer(spacing:)` once on the parent.
struct GlassContainerModifier: ViewModifier {
    let spacing: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    /// Wraps the view in a `GlassEffectContainer` on macOS 26+, no-op
    /// on macOS 15. Use on any view that composes two or more nearby
    /// glass surfaces.
    public func glassContainer(spacing: CGFloat) -> some View {
        modifier(GlassContainerModifier(spacing: spacing))
    }
}
