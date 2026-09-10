import Foundation
import SwiftData

@MainActor
enum Persistence {
    static func makeContainer(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema(versionedSchema: NextSchema.self)
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        } else {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory,
                cloudKitDatabase: .none
            )
        }
        let container = try ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = false
        return container
    }
}
