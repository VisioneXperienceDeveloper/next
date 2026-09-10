import Foundation
import OSLog
import SwiftData

enum DomainError: Error, Equatable {
    case emptyStatement
    case visionExists
    case activeStepExists
    case stepAlreadyCompleted
    case stepNotCompleted
    case reflectionExists
    case detachedModel
    case readOnlyStore
}

/// The single mutation boundary for the app's local, main-actor context.
/// No suspension occurs between validation and save. Editors hold value drafts.
@MainActor
struct VisionActions {
    let context: ModelContext

    @discardableResult
    func createVision(title: String, now: Date = .now) throws -> Vision {
        let title = try statement(title)
        try requireWritableStore()
        guard try !context.fetch(FetchDescriptor<Vision>()).contains(where: { !$0.isDeleted }) else {
            throw DomainError.visionExists
        }
        let vision = Vision(title: title, now: now)
        do {
            try save { context.insert(vision) }
        } catch {
            context.delete(vision)
            context.processPendingChanges()
            throw error
        }
        return vision
    }

    @discardableResult
    func createNextStep(title: String, for vision: Vision, now: Date = .now) throws -> Step {
        let title = try statement(title)
        try requireWritableStore()
        try requireAttached(vision)
        guard vision.activeStep == nil else { throw DomainError.activeStepExists }
        let previousUpdatedAt = vision.updatedAt
        let step = Step(title: title, vision: vision, now: now)
        do {
            try save {
                context.insert(step)
                vision.updatedAt = now
            }
        } catch {
            vision.steps.removeAll { $0 === step }
            context.delete(step)
            vision.updatedAt = previousUpdatedAt
            context.processPendingChanges()
            throw error
        }
        return step
    }

    func updateVision(_ vision: Vision, title: String, now: Date = .now) throws {
        let title = try statement(title)
        try requireWritableStore()
        try requireAttached(vision)
        let previousTitle = vision.title
        let previousUpdatedAt = vision.updatedAt
        do {
            try save {
                vision.title = title
                vision.updatedAt = now
            }
        } catch {
            // SwiftData can retain cached scalar values after a failed save and
            // rollback. Restore the values observed by Home explicitly.
            vision.title = previousTitle
            vision.updatedAt = previousUpdatedAt
            throw error
        }
    }

    func updateStep(_ step: Step, title: String, now: Date = .now) throws {
        let title = try statement(title)
        try requireWritableStore()
        try requireAttached(step)
        guard !step.isCompleted else { throw DomainError.stepAlreadyCompleted }
        let previousTitle = step.title
        let previousUpdatedAt = step.vision?.updatedAt
        do {
            try save {
                step.title = title
                step.vision?.updatedAt = now
            }
        } catch {
            step.title = previousTitle
            if let previousUpdatedAt { step.vision?.updatedAt = previousUpdatedAt }
            throw error
        }
    }

    func completeStep(_ step: Step, now: Date = .now) throws {
        try requireWritableStore()
        try requireAttached(step)
        guard !step.isCompleted else { throw DomainError.stepAlreadyCompleted }
        let oldUpdatedAt = step.vision?.updatedAt
        do {
            try save {
                step.completedAt = now
                step.vision?.updatedAt = now
            }
        } catch {
            step.completedAt = nil
            if let oldUpdatedAt { step.vision?.updatedAt = oldUpdatedAt }
            throw error
        }
    }

    @discardableResult
    func addReflection(_ content: String, to step: Step, now: Date = .now) throws -> Reflection {
        try requireWritableStore()
        try requireAttached(step)
        let reflection = try Reflection(content: statement(content), step: step, now: now)
        do {
            try save { context.insert(reflection) }
        } catch {
            step.reflection = nil
            context.delete(reflection)
            context.processPendingChanges()
            throw error
        }
        return reflection
    }

    func deleteVision(_ vision: Vision) throws {
        try requireWritableStore()
        try requireAttached(vision)
        try save { context.delete(vision) }
    }

    private func statement(_ value: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw DomainError.emptyStatement }
        return trimmed
    }

    private func requireAttached(_ model: some PersistentModel) throws {
        guard model.modelContext === context, !model.isDeleted else {
            throw DomainError.detachedModel
        }
    }

    private func requireWritableStore() throws {
        // SwiftData may update its cache before a read-only store rejects a save.
        // Refuse that unsupported write before touching the observed object graph.
        guard context.container.configurations.allSatisfy(\.allowsSave) else {
            throw DomainError.readOnlyStore
        }
    }

    private func save(_ changes: () -> Void) throws {
        do {
            try context.transaction(block: changes)
        } catch {
            context.rollback()
            Diagnostics.persistence(error)
            throw error
        }
    }
}

enum Diagnostics {
    static func persistence(_ error: Error) {
        #if DEBUG
        let nsError = error as NSError
        // Never log descriptions/userInfo: a persistence error can contain private text.
        Logger(subsystem: "com.visionexperiencedeveloper.next", category: "Persistence")
            .error("Persistence failure: \(nsError.domain, privacy: .public) code \(nsError.code)")
        #endif
    }
}
