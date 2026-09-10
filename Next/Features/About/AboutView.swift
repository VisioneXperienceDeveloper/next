import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text(Copy.tagline).font(.title2)
                Text(Copy.publisher).foregroundStyle(Color.primary.opacity(0.68))
            }
            Section {
                Text(Copy.privacySummary)
                if let url = URL(string: "https://www.visionexperiencedeveloper.com/en/policies/next") {
                    Link(destination: url) { Text(Copy.privacy) }
                }
            } header: { Text(Copy.privacy) }
            Section {
                if let url = URL(string: "https://www.visionexperiencedeveloper.com/en/supports/next") {
                    Link(destination: url) { Text(Copy.support) }
                }
                if let url = URL(string: "mailto:visionexperiencedeveloper@gmail.com") {
                    Link(destination: url) { Text(Copy.email) }
                }
            } header: { Text(Copy.support) }
        }.navigationTitle(Text(Copy.about))
    }
}
