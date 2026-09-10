import SwiftData
import SwiftUI

struct RootView: View {
    @Query(sort: \Vision.createdAt) private var visions: [Vision]
    @State private var sheet: HomeSheet?

    var body: some View {
        Group {
            if let vision = visions.first(where: { !$0.isDeleted }) {
                NavigationStack {
                    HomeView(vision: vision, present: { sheet = $0 })
                }
            } else {
                OnboardingFlow { vision in
                    sheet = .createStep(vision)
                }
            }
        }
        .sheet(item: $sheet) { destination in
            switch destination {
            case .createStep(let vision): StepEditorView(vision: vision)
            case .editVision(let vision): VisionEditorView(vision: vision)
            case .complete(let step): CompletionFlow(step: step)
            }
        }
    }
}

enum HomeSheet: Identifiable {
    case complete(Step)
    case createStep(Vision)
    case editVision(Vision)

    var id: String {
        switch self {
        case .complete(let step): "complete-\(step.id)"
        case .createStep(let vision): "create-\(vision.id)"
        case .editVision(let vision): "vision-\(vision.id)"
        }
    }
}
