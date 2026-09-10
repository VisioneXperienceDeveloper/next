import SwiftData
import SwiftUI

struct VisionEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let vision: Vision
    @State private var draft: String
    @FocusState private var editorFocused: Bool
    @State private var showError = false
    @State private var confirmDelete = false

    init(vision: Vision) {
        self.vision = vision
        _draft = State(initialValue: vision.title)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(Copy.visionQuestion)
                        .font(.largeTitle.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(Copy.visionGuidance)
                        .font(.body)
                        .foregroundStyle(Color.primary.opacity(0.68))
                    StatementEditor(label: Copy.vision, example: Copy.visionExample, text: $draft, focus: $editorFocused)
                    Button(role: .destructive) { confirmDelete = true } label: { Text(Copy.deleteVision).frame(minHeight: 44) }
                        .accessibilityIdentifier("deleteVision")
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(Text(Copy.editVision))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Text(Copy.cancel) }
                }
            }
            .nextActionBar {
                PrimaryButton(title: Copy.save, action: save)
                    .disabled(draft.isBlankStatement)
                    .accessibilityIdentifier("saveVision")
            }
            .dismissKeyboardOutsideEditor(focus: $editorFocused)
            .confirmationDialog(Text(Copy.deleteQuestion), isPresented: $confirmDelete, titleVisibility: .visible) {
                Button(role: .destructive) {
                    do { try VisionActions(context: context).deleteVision(vision); dismiss() }
                    catch { showError = true }
                } label: { Text(Copy.deleteVision) }
            } message: { Text(Copy.deleteWarning) }
            .alert(Text(Copy.saveErrorTitle), isPresented: $showError) {
                Button { } label: { Text(Copy.ok) }
            } message: {
                Text(Copy.visionSaveError)
            }
        }
    }

    private func save() {
        do {
            try VisionActions(context: context).updateVision(vision, title: draft)
            dismiss()
        } catch {
            showError = true
        }
    }
}
