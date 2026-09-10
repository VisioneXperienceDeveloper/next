import SwiftData
import SwiftUI

/// A single sheet owns the temporary completion sequence. Every committed phase
/// is durable; closing the sheet or app returns to the domain-derived Home state.
struct CompletionFlow: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let step: Step
    @State private var phase: Phase = .step
    @State private var draft = ""
    @FocusState private var editorFocused: Bool
    @State private var showError = false
    private enum Phase { case step, edit, completed, reflection, next }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let vision = step.vision, phase == .next {
                        Eyebrow(title: Copy.yourVision)
                        Text(verbatim: vision.title).foregroundStyle(Color.primary.opacity(0.68))
                    }
                    Text(title).font(.largeTitle.weight(.semibold)).accessibilityAddTraits(.isHeader)
                    switch phase {
                    case .step:
                        Text(verbatim: step.title).font(.largeTitle).fixedSize(horizontal: false, vertical: true)
                        Image(systemName: "circle").font(.system(size: 48, weight: .ultraLight)).foregroundStyle(Color.accentColor).accessibilityHidden(true).padding(.vertical, 32)
                        Button { draft = step.title; phase = .edit } label: { Text(Copy.editText).frame(minHeight: 44) }.nextSecondaryActionStyle().accessibilityIdentifier("editStep")
                    case .completed:
                        Image(systemName: "checkmark").font(.system(size: 48, weight: .light)).foregroundStyle(Color.accentColor).accessibilityHidden(true).padding(.vertical, 32)
                        Text(Copy.reflectInvitation).font(.title2)
                    case .edit:
                        StatementEditor(label: Copy.nextStep, example: Copy.stepExample, text: $draft, focus: $editorFocused)
                    case .reflection:
                        StatementEditor(label: Copy.reflection, example: Copy.reflectionExample, text: $draft, focus: $editorFocused)
                    case .next:
                        Text(Copy.stepQuestion).font(.title)
                        Text(Copy.stepGuidance).foregroundStyle(Color.primary.opacity(0.68))
                        StatementEditor(label: Copy.nextStep, example: Copy.stepExample, text: $draft, focus: $editorFocused)
                    }
                }
                .frame(maxWidth: 560, alignment: .leading).padding(24).frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if phase == .edit { draft = ""; phase = .step } else { dismiss() }
                    } label: { Text(phase == .edit ? Copy.cancel : Copy.close) }
                }
            }
            .nextActionBar {
                VStack(spacing: 8) {
                    PrimaryButton(title: buttonTitle, action: act)
                        .disabled(needsDraft && draft.isBlankStatement)
                        .accessibilityIdentifier(buttonID)
                    if phase == .completed || phase == .reflection {
                        Button { advance(.next) } label: {
                            Text(Copy.skip)
                                .foregroundStyle(Color.accentColor)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("skipReflection")
                    }
                }

            }
            .dismissKeyboardOutsideEditor(focus: $editorFocused)
            .alert(Text(Copy.saveErrorTitle), isPresented: $showError) {
                Button { } label: { Text(Copy.ok) }
            } message: { Text(Copy.changeError) }
        }
    }

    private var title: LocalizedStringResource {
        switch phase {
        case .step: Copy.yourNextStep
        case .edit: Copy.editStep
        case .completed: Copy.forward
        case .reflection: Copy.reflectionQuestion
        case .next: Copy.keepMoving
        }
    }
    private var needsDraft: Bool { phase == .edit || phase == .reflection || phase == .next }
    private var buttonTitle: LocalizedStringResource {
        switch phase {
        case .step: Copy.complete
        case .completed: Copy.addReflection
        case .next: Copy.continueAction
        case .edit, .reflection: Copy.save
        }
    }
    private var buttonID: String {
        switch phase {
        case .step: "completeStep"
        case .completed: "addReflection"
        case .reflection: "saveReflection"
        case .next, .edit: "saveStep"
        }
    }
    private func advance(_ next: Phase) {
        draft = ""
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.18)) { phase = next }
    }
    private func act() {
        let actions = VisionActions(context: context)
        do {
            switch phase {
            case .step:
                try actions.completeStep(step)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                advance(.completed)
            case .completed: advance(.reflection)
            case .reflection:
                try actions.addReflection(draft, to: step)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                advance(.next)
            case .next:
                guard let vision = step.vision else { throw DomainError.detachedModel }
                try actions.createNextStep(title: draft, for: vision)
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                dismiss()
            case .edit:
                try actions.updateStep(step, title: draft)
                dismiss()
            }
        } catch { showError = true }
    }
}
