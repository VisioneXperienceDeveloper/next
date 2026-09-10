import Foundation
import SwiftData
import Testing
@testable import Next

@MainActor
struct PersistenceTests {
    @Test func visionAndStepSurviveContainerRecreation() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Next.store")
        let ids = try writeInitialStore(url)
        let reopened = try Persistence.makeContainer(url: url)
        let visions = try reopened.mainContext.fetch(FetchDescriptor<Vision>())
        let vision = try #require(visions.first)
        #expect(visions.count == 1)
        #expect(vision.id == ids.0)
        #expect(vision.title == "Become a developer")
        #expect(vision.activeStep?.id == ids.1)
        #expect(vision.activeStep?.title == "Apply for one position.")
        #expect(vision.steps.count == 1)
        #expect(vision.activeStep?.vision?.id == vision.id)
        #expect(throws: DomainError.activeStepExists) {
            try VisionActions(context: reopened.mainContext).createNextStep(title: "Another", for: vision)
        }
    }

    @Test func savedVisionWithoutStepSurvivesInterruption() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Next.store")
        try writeVisionOnly(url)
        let container = try Persistence.makeContainer(url: url)
        let vision = try #require(container.mainContext.fetch(FetchDescriptor<Vision>()).first)
        #expect(vision.title == "Write a book")
        #expect(vision.activeStep == nil)
        try VisionActions(context: container.mainContext).createNextStep(title: "Write one paragraph.", for: vision)
        #expect(vision.activeStep?.title == "Write one paragraph.")
    }

    @Test func readOnlyStoreRejectsEditsWithoutMutation() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Next.store")
        _ = try writeInitialStore(url)
        let schema = Schema(versionedSchema: NextSchema.self)
        let configuration = ModelConfiguration(schema: schema, url: url, allowsSave: false, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        context.autosaveEnabled = false
        let vision = try #require(context.fetch(FetchDescriptor<Vision>()).first)
        #expect(throws: (any Error).self) {
            try VisionActions(context: context).updateVision(vision, title: "An unsaved edit")
        }
        #expect(vision.title == "Become a developer")
        let step = try #require(vision.activeStep)
        #expect(throws: (any Error).self) {
            try VisionActions(context: context).updateStep(step, title: "An unsaved Step")
        }
        #expect(step.title == "Apply for one position.")
        let reopened = try Persistence.makeContainer(url: url)
        let persisted = try #require(reopened.mainContext.fetch(FetchDescriptor<Vision>()).first)
        #expect(persisted.title == vision.title)
        #expect(persisted.activeStep?.title == step.title)
    }

    @Test func readOnlyStoreRejectsStepCreationWithoutGhostStep() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Next.store")
        try writeVisionOnly(url)
        let schema = Schema(versionedSchema: NextSchema.self)
        let configuration = ModelConfiguration(schema: schema, url: url, allowsSave: false, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        context.autosaveEnabled = false
        let vision = try #require(context.fetch(FetchDescriptor<Vision>()).first)
        let originalDate = vision.updatedAt
        #expect(throws: (any Error).self) {
            try VisionActions(context: context).createNextStep(title: "An unsaved Step", for: vision)
        }
        #expect(vision.activeStep == nil)
        #expect(vision.updatedAt == originalDate)
        #expect(try context.fetch(FetchDescriptor<Step>()).filter { !$0.isDeleted }.isEmpty)
        let reopened = try Persistence.makeContainer(url: url)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<Step>()) == 0)
        // A retry must report the write restriction, never a phantom active Step.
        do {
            try VisionActions(context: context).createNextStep(title: "Try again", for: vision)
            Issue.record("The read-only store unexpectedly accepted a save")
        } catch {
            #expect(error as? DomainError == .readOnlyStore)
        }
        #expect(vision.activeStep == nil)
    }

    @Test func readOnlyStoreRejectsVisionCreationWithoutGhostVision() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Next.store")
        try writeEmptyStore(url)
        let schema = Schema(versionedSchema: NextSchema.self)
        let configuration = ModelConfiguration(schema: schema, url: url, allowsSave: false, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        context.autosaveEnabled = false
        let actions = VisionActions(context: context)
        for _ in 0..<2 {
            do {
                try actions.createVision(title: "Write a book")
                Issue.record("The read-only store unexpectedly accepted a save")
            } catch {
                #expect(error as? DomainError == .readOnlyStore)
            }
            #expect(try context.fetch(FetchDescriptor<Vision>()).filter { !$0.isDeleted }.isEmpty)
        }
        let reopened = try Persistence.makeContainer(url: url)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<Vision>()) == 0)
    }

    private func writeEmptyStore(_ url: URL) throws {
        let container = try Persistence.makeContainer(url: url)
        try container.mainContext.save()
    }

    private func writeInitialStore(_ url: URL) throws -> (UUID, UUID) {
        let container = try Persistence.makeContainer(url: url)
        let actions = VisionActions(context: container.mainContext)
        let vision = try actions.createVision(title: "Become a developer")
        let step = try actions.createNextStep(title: "Apply for one position.", for: vision)
        return (vision.id, step.id)
    }

    private func writeVisionOnly(_ url: URL) throws {
        let container = try Persistence.makeContainer(url: url)
        try VisionActions(context: container.mainContext).createVision(title: "Write a book")
    }
}
