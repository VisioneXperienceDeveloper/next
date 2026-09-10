import Foundation
import SwiftData

enum NextSchema: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Vision.self, Step.self, Reflection.self] }

    @Model
    final class Vision {
        @Attribute(.unique) var id: UUID
        var title: String
        var createdAt: Date
        var updatedAt: Date
        @Relationship(deleteRule: .cascade, inverse: \Step.vision)
        var steps: [Step] = []

        init(title: String, now: Date = .now) {
            id = UUID()
            self.title = title
            createdAt = now
            updatedAt = now
        }

        /// Deterministic even if an imported or damaged store violates the invariant.
        /// All app writes still reject a second incomplete Step in VisionActions.
        var activeStep: Step? {
            steps.filter { !$0.isDeleted && !$0.isCompleted }.min {
                if $0.createdAt == $1.createdAt { return $0.id.uuidString < $1.id.uuidString }
                return $0.createdAt < $1.createdAt
            }
        }
    }

    @Model
    final class Step {
        @Attribute(.unique) var id: UUID
        var title: String
        var createdAt: Date
        var completedAt: Date?
        var vision: Vision?
        @Relationship(deleteRule: .cascade, inverse: \Reflection.step)
        var reflection: Reflection?

        var isCompleted: Bool { completedAt != nil }

        init(title: String, vision: Vision, now: Date = .now) {
            id = UUID()
            self.title = title
            createdAt = now
            self.vision = vision
        }
    }

    @Model
    final class Reflection {
        @Attribute(.unique) var id: UUID
        var content: String
        var createdAt: Date
        var step: Step?

        init(content: String, step: Step, now: Date = .now) throws {
            guard step.isCompleted else { throw DomainError.stepNotCompleted }
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { throw DomainError.emptyStatement }
            guard step.reflection == nil else { throw DomainError.reflectionExists }
            id = UUID()
            self.content = trimmed
            createdAt = now
            self.step = step
        }
    }
}

typealias Vision = NextSchema.Vision
typealias Step = NextSchema.Step
typealias Reflection = NextSchema.Reflection
