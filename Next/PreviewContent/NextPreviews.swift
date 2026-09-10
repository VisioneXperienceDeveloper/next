#if DEBUG
import SwiftData
import SwiftUI

private enum PreviewScreen { case root, vision, home, step, editVision, journey, completion }

@MainActor
private struct PreviewHost: View {
    let screen: PreviewScreen
    let fixture: Result<(ModelContainer, Vision?), Error>
    @State private var draft = ""

    init(screen: PreviewScreen, empty: Bool = false, longText: Bool = false) {
        self.screen = screen
        fixture = Result {
            let container = try Persistence.makeContainer(inMemory: true)
            guard screen != .root && screen != .vision else { return (container, nil) }
            let actions = VisionActions(context: container.mainContext)
            let vision = try actions.createVision(title: longText
                ? "Become a software engineer in Australia, building thoughtful products that help people make meaningful changes in their lives."
                : "Become a software engineer in Australia.")
            if screen == .journey && !empty {
                let completed = try actions.createNextStep(title: "Updated my portfolio.", for: vision)
                try actions.completeStep(completed)
                try actions.addReflection("A small example tells a clear story.", to: completed)
                let withoutReflection = try actions.createNextStep(title: "Read one role description.", for: vision)
                try actions.completeStep(withoutReflection)
            }
            if !empty {
                try actions.createNextStep(title: longText
                    ? "Read one developer position description, choose a relevant example from my portfolio, and write a short application explaining what I learned."
                    : "Apply for one developer position.", for: vision)
            }
            return (container, vision)
        }
    }

    var body: some View {
        switch fixture {
        case .success(let (container, vision)):
            Group {
                switch screen {
                case .root: RootView()
                case .vision:
                    NavigationStack { VisionSetupView(draft: $draft, onCreated: { _ in }) }
                case .home:
                    if let vision { NavigationStack { HomeView(vision: vision, present: { _ in }) } }
                case .step:
                    if let vision { StepEditorView(vision: vision) }
                case .journey:
                    if let vision { NavigationStack { JourneyView(vision: vision) } }
                case .completion:
                    if let step = vision?.activeStep { CompletionFlow(step: step) }
                case .editVision:
                    if let vision { VisionEditorView(vision: vision) }
                }
            }
            .modelContainer(container)
            .tint(Color("AccentColor"))
        case .failure:
            ContentUnavailableView("Preview unavailable", systemImage: "exclamationmark.triangle")
        }
    }
}

#Preview("New user") { PreviewHost(screen: .root) }
#Preview("Vision setup") { PreviewHost(screen: .vision) }
#Preview("First Step") { PreviewHost(screen: .step, empty: true) }
#Preview("Active Step") { PreviewHost(screen: .home) }
#Preview("No active Step · Empty Journey") { PreviewHost(screen: .home, empty: true) }
#Preview("Edit Vision") { PreviewHost(screen: .editVision) }
#Preview("Dark Mode") { PreviewHost(screen: .home).preferredColorScheme(.dark) }
#Preview("Long text · Accessibility") {
    PreviewHost(screen: .home, longText: true)
        .environment(\.dynamicTypeSize, .accessibility3)
}
#Preview("Journey · Reflections") { PreviewHost(screen: .journey) }
#Preview("Empty Journey") { PreviewHost(screen: .journey, empty: true) }
#Preview("Floating actions · Dark") {
    NavigationStack {
        ScrollView { Text(Copy.reflectionQuestion).font(.largeTitle).padding(24) }
            .nextActionBar {
                VStack(spacing: 8) {
                    PrimaryButton(title: Copy.save) { }
                    Button { } label: { Text(Copy.skip).frame(minHeight: 44) }
                        .nextSecondaryActionStyle()
                }
            }
    }
    .preferredColorScheme(.dark)
    .tint(Color("AccentColor"))
}
#Preview("Complete Step") { PreviewHost(screen: .completion) }
#Preview("About") { NavigationStack { AboutView() } }
#endif
