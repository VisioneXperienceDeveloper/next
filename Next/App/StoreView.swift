import SwiftData
import SwiftUI

struct StoreView: View {
    @State private var container: ModelContainer?
    @State private var failed = false

    var body: some View {
        Group {
            if let container {
                RootView()
                    .modelContainer(container)
            } else if failed {
                ContentUnavailableView {
                    Label { Text(Copy.openError) } icon: { Image(systemName: "arrow.clockwise") }
                } description: {
                    Text(Copy.openErrorBody)
                } actions: {
                    Button(action: load) { Text(Copy.retry) }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView { Text(Copy.opening) }
            }
        }
        .tint(Color("AccentColor"))
        #if DEBUG
        .preferredColorScheme(ProcessInfo.processInfo.arguments.contains("--ui-test-dark") ? .dark : nil)
        #endif
        .task { if container == nil { load() } }
    }

    private func load() {
        do {
            #if DEBUG
            // UI tests use isolated disk stores, never a reset of the user's store.
            let arguments = ProcessInfo.processInfo.arguments
            if let index = arguments.firstIndex(of: "--ui-test-store"),
               arguments.indices.contains(index + 1),
               let id = UUID(uuidString: arguments[index + 1]) {
                let directory = URL.applicationSupportDirectory.appending(path: "UITestStores")
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                container = try Persistence.makeContainer(url: directory.appending(path: "\(id).store"))
            } else {
                container = try Persistence.makeContainer()
            }
            #else
            container = try Persistence.makeContainer()
            #endif
            failed = false
        } catch {
            Diagnostics.persistence(error)
            failed = true
        }
    }
}
