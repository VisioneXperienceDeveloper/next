import SwiftUI

struct PrimaryButton: View {
    let title: LocalizedStringResource
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("OnAccentColor"))
                .frame(maxWidth: .infinity, minHeight: 28)
                .padding(.vertical, 8)
        }
        .nextPrimaryActionStyle()
    }
}

struct Eyebrow: View {
    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(Color.primary.opacity(0.68))
    }
}

/// Glass is reserved for controls. Statements and Journey entries stay opaque.
struct NextGlassGroup<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: 24) { content }
        } else {
            content
        }
    }
}

private struct NextActionStyle: ViewModifier {
    var prominent: Bool
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26, *), !reduceTransparency, contrast != .increased {
            if prominent {
                content.buttonStyle(.glassProminent).buttonBorderShape(.capsule).controlSize(.large)
            } else {
                content.buttonStyle(.glass).buttonBorderShape(.capsule).controlSize(.regular)
            }
        } else if prominent {
            content.buttonStyle(.borderedProminent).buttonBorderShape(.capsule).controlSize(.large)
        } else {
            content.buttonStyle(.bordered).buttonBorderShape(.capsule).controlSize(.regular)
        }
    }
}

private struct NextActionBar<Bar: View>: ViewModifier {
    let bar: Bar

    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            // Let the system provide the scroll-edge treatment behind floating controls.
            content.safeAreaBar(edge: .bottom, spacing: 0) { controls }
        } else {
            content.safeAreaInset(edge: .bottom, spacing: 0) {
                controls.background(.background)
            }
        }
    }

    private var controls: some View {
        NextGlassGroup { bar }
            .frame(maxWidth: 560)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
    }
}

private struct NextStepAffordance: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26, *), !reduceTransparency, contrast != .increased {
            content.glassEffect(.regular.tint(Color.accentColor.opacity(0.10)).interactive(), in: .capsule)
        } else {
            content.background(Color(uiColor: .tertiarySystemFill), in: Capsule())
        }
    }
}

extension View {
    func nextPrimaryActionStyle() -> some View { modifier(NextActionStyle(prominent: true)) }
    func nextSecondaryActionStyle() -> some View { modifier(NextActionStyle(prominent: false)) }
    func nextStepAffordance() -> some View { modifier(NextStepAffordance()) }
    func nextActionBar<Bar: View>(@ViewBuilder content: () -> Bar) -> some View {
        modifier(NextActionBar(bar: content()))
    }
}
