import SwiftData
import SwiftUI

struct StepEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    private let vision: Vision
    @State private var draft: String
    @FocusState private var editorFocused: Bool
    @State private var showError = false
    @State private var errorMessage = Copy.stepSaveError

    init(vision: Vision) {
        self.vision = vision
        _draft = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Group {
                        VStack(alignment: .leading, spacing: 8) {
                            Eyebrow(title: Copy.yourVision)
                            Text(verbatim: vision.title)
                                .font(.body)
                                .foregroundStyle(Color.primary.opacity(0.68))
                        }
                    }
                    Text(Copy.stepQuestion)
                        .font(.largeTitle.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(Copy.stepGuidance)
                        .font(.body)
                        .foregroundStyle(Color.primary.opacity(0.68))
                    StatementEditor(label: Copy.nextStep, example: Copy.stepExample, text: $draft, focus: $editorFocused)
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(Text(Copy.nextStep))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Text(Copy.cancel) }
                }
            }
            .nextActionBar {
                PrimaryButton(title: Copy.start, action: save)
                    .disabled(draft.isBlankStatement)
                    .accessibilityIdentifier("saveStep")
            }
            .dismissKeyboardOutsideEditor(focus: $editorFocused)
            .alert(Text(Copy.saveErrorTitle), isPresented: $showError) {
                Button { } label: { Text(Copy.ok) }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func save() {
        do {
            let actions = VisionActions(context: context)
            try actions.createNextStep(title: draft, for: vision)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            dismiss()
        } catch {
            errorMessage = error as? DomainError == .activeStepExists ? Copy.existingStepError : Copy.stepSaveError
            showError = true
        }
    }
}
