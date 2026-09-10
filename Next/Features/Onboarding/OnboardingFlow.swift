import SwiftUI

struct OnboardingFlow: View {
    var onVisionCreated: (Vision) -> Void
    @State private var visionDraft = ""

    var body: some View {
        NavigationStack {
            WelcomeView()
                .navigationDestination(for: OnboardingRoute.self) { _ in
                    VisionSetupView(draft: $visionDraft, onCreated: onVisionCreated)
                }
        }
    }
}

enum OnboardingRoute: Hashable { case vision }

struct WelcomeView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer(minLength: 48)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 44, weight: .regular))
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    Text(Copy.appName)
                        .font(.largeTitle.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(Copy.tagline)
                        .font(.title2)
                        .foregroundStyle(Color.primary.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 48)
                }
                .frame(maxWidth: 560, minHeight: max(0, geometry.size.height - 48), alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar { ToolbarItem(placement: .topBarTrailing) { NavigationLink { AboutView() } label: { Image(systemName: "info.circle").accessibilityLabel(Text(Copy.about)) } } }
        .nextActionBar {
            NavigationLink(value: OnboardingRoute.vision) {
                Text(Copy.getStarted)
                    .font(.headline)
                    .foregroundStyle(Color("OnAccentColor"))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .nextPrimaryActionStyle()
            .accessibilityIdentifier("getStarted")
        }
    }
}
