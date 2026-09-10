import SwiftUI

struct StatementEditor: View {
    let label: LocalizedStringResource
    let example: LocalizedStringResource
    @Binding var text: String
    var focus: FocusState<Bool>.Binding

    var body: some View {
        TextField("", text: $text, prompt: Text(example), axis: .vertical)
            .font(.title2)
            .lineLimit(3...8)
            .textInputAutocapitalization(.sentences)
            .padding(20)
            .frame(minHeight: 148, alignment: .topLeading)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
            .focused(focus)
            .accessibilityLabel(Text(label))
            .accessibilityIdentifier("statementInput")
            .task {
                // Wait for presentation before requesting focus; cancelled with the view.
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                focus.wrappedValue = true
            }
    }
}

extension String {
    var isBlankStatement: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

// Observe taps without consuming controls or text-selection gestures. A window
// recognizer also sees empty space around a ScrollView and its safe-area footer.
private struct OutsideEditorKeyboardDismissal: UIViewRepresentable {
    var focus: FocusState<Bool>.Binding

    func makeUIView(context: Context) -> KeyboardDismissalObserver {
        let view = KeyboardDismissalObserver()
        view.isUserInteractionEnabled = false
        view.dismissFocus = { focus.wrappedValue = false }
        return view
    }

    func updateUIView(_ view: KeyboardDismissalObserver, context: Context) {
        view.dismissFocus = { focus.wrappedValue = false }
    }

    static func dismantleUIView(_ view: KeyboardDismissalObserver, coordinator: ()) {
        view.detach()
    }
}

private final class KeyboardDismissalObserver: UIView, UIGestureRecognizerDelegate {
    var dismissFocus: (() -> Void)?
    private weak var observedWindow: UIWindow?
    private lazy var tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

    override func didMoveToWindow() {
        super.didMoveToWindow()
        detach()
        guard let window else { return }
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
        observedWindow = window
    }

    func detach() {
        observedWindow?.removeGestureRecognizer(tap)
        observedWindow = nil
    }

    @objc private func dismissKeyboard() {
        dismissFocus?()
        observedWindow?.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var touchedView = touch.view
        while let view = touchedView {
            // Leave cursor placement, selection, and native text-input controls alone.
            if view is UITextField || view is UITextView { return false }
            touchedView = view.superview
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

extension View {
    func dismissKeyboardOutsideEditor(focus: FocusState<Bool>.Binding) -> some View {
        background(OutsideEditorKeyboardDismissal(focus: focus))
    }
}
