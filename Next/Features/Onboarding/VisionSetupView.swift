import SwiftData
import SwiftUI

struct VisionSetupView: View {
    @Environment(\.modelContext) private var context
    @Binding var draft: String
    var onCreated: (Vision) -> Void
    @FocusState private var editorFocused: Bool
    @State private var showError = false
    @State private var errorMessage = Copy.visionSaveError

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(Copy.visionQuestion)
                    .font(.largeTitle.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                Text(Copy.visionGuidance)
                    .font(.body)
                    .foregroundStyle(Color.primary.opacity(0.68))
                StatementEditor(label: Copy.vision, example: Copy.visionExample, text: $draft, focus: $editorFocused)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Text(Copy.vision))
        .navigationBarTitleDisplayMode(.inline)
        .nextActionBar {
            PrimaryButton(title: Copy.continueAction, action: save)
                .disabled(draft.isBlankStatement)
                .accessibilityIdentifier("continueVision")
        }
        .dismissKeyboardOutsideEditor(focus: $editorFocused)
        .alert(Text(Copy.saveErrorTitle), isPresented: $showError) {
            Button { } label: { Text(Copy.ok) }
        } message: {
            Text(errorMessage)
        }
    }

    private func save() {
        do {
            let vision = try VisionActions(context: context).createVision(title: draft)
            onCreated(vision)
        } catch {
            errorMessage = error as? DomainError == .visionExists ? Copy.existingVisionError : Copy.visionSaveError
            showError = true
        }
    }
}
