import Foundation
import SwiftData
import Testing
@testable import Next

@MainActor
struct VisionActionsTests {
    private func setup() throws -> (ModelContainer, VisionActions) {
        let container = try Persistence.makeContainer(inMemory: true)
        return (container, VisionActions(context: container.mainContext))
    }

    @Test func createsOneVisionWithTrimmedTextAndDates() throws {
        let (container, actions) = try setup()
        let now = Date(timeIntervalSince1970: 1_000)
        let vision = try actions.createVision(title: "  Learn Korean.\n", now: now)
        #expect(vision.title == "Learn Korean.")
        #expect(vision.createdAt == now)
        #expect(vision.updatedAt == now)
        #expect(vision.activeStep == nil)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Vision>()) == 1)
        #expect(throws: DomainError.visionExists) { try actions.createVision(title: "Another vision") }
    }

    @Test func rejectsBlankInputBeforeMutating() throws {
        let (container, actions) = try setup()
        #expect(throws: DomainError.emptyStatement) { try actions.createVision(title: " \n\t ") }
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Vision>()) == 0)
        let vision = try actions.createVision(title: "Write a book")
        #expect(throws: DomainError.emptyStatement) { try actions.createNextStep(title: "\n", for: vision) }
        #expect(vision.steps.isEmpty)
    }

    @Test func createsFirstStepWithInverseAndPreventsAnother() throws {
        let (container, actions) = try setup()
        let vision = try actions.createVision(title: "Write a book")
        let step = try actions.createNextStep(title: "  Write the introduction.\n", for: vision)
        #expect(step.title == "Write the introduction.")
        #expect(step.vision?.id == vision.id)
        #expect(vision.activeStep?.id == step.id)
        #expect(!step.isCompleted)
        #expect(step.completedAt == nil)
        #expect(throws: DomainError.activeStepExists) {
            try actions.createNextStep(title: "Make a backlog", for: vision)
        }
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Step>()) == 1)
    }

    @Test func editsPreserveIdentityAndRelationships() throws {
        let (container, actions) = try setup()
        defer { withExtendedLifetime(container) {} }
        let vision = try actions.createVision(title: "Write a book")
        let step = try actions.createNextStep(title: "Write", for: vision)
        let originalID = step.id
        let originalDate = step.createdAt
        let now = Date(timeIntervalSince1970: 2_000)
        try actions.updateVision(vision, title: "  Write a short novel. ", now: now)
        try actions.updateStep(step, title: "Write one paragraph.", now: now)
        #expect(vision.title == "Write a short novel.")
        #expect(vision.updatedAt == now)
        #expect(step.id == originalID)
        #expect(step.createdAt == originalDate)
        #expect(vision.activeStep?.title == "Write one paragraph.")
        #expect(throws: DomainError.emptyStatement) { try actions.updateStep(step, title: " ") }
        #expect(step.title == "Write one paragraph.")
    }

    @Test func rejectsModelsFromAnotherContext() throws {
        let (container, actions) = try setup()
        let (otherContainer, otherActions) = try setup()
        defer { withExtendedLifetime((container, otherContainer)) {} }
        let vision = try otherActions.createVision(title: "Learn a language")
        #expect(throws: DomainError.detachedModel) {
            try actions.createNextStep(title: "Read one page", for: vision)
        }
    }

    @Test func reflectionCannotBelongToAnActiveStep() throws {
        let (container, actions) = try setup()
        defer { withExtendedLifetime(container) {} }
        let vision = try actions.createVision(title: "Learn Korean")
        let step = try actions.createNextStep(title: "Read one page", for: vision)
        #expect(throws: DomainError.stepNotCompleted) { try Reflection(content: "A useful word", step: step) }
        #expect(step.reflection == nil)
    }

    @Test func schemaCompletionHasOneSourceOfTruth() throws {
        let (container, actions) = try setup()
        defer { withExtendedLifetime(container) {} }
        let vision = try actions.createVision(title: "Learn Korean")
        let step = try actions.createNextStep(title: "Read one page", for: vision)
        try actions.completeStep(step, now: Date(timeIntervalSince1970: 3_000))
        #expect(step.isCompleted)
        #expect(vision.activeStep == nil)
        #expect(throws: DomainError.stepAlreadyCompleted) { try actions.updateStep(step, title: "Rewrite history") }
    }

    @Test func cascadeDeletesChildrenWithoutDeletingParentInReverse() throws {
        let (container, actions) = try setup()
        let context = container.mainContext
        let vision = try actions.createVision(title: "Learn Korean")
        let step = try actions.createNextStep(title: "Read one page", for: vision)
        step.completedAt = .now
        let reflection = try Reflection(content: "A useful word", step: step)
        context.insert(reflection)
        try context.save()
        #expect(step.reflection?.id == reflection.id)
        context.delete(vision)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Vision>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Step>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Reflection>()) == 0)

        let nextVision = try actions.createVision(title: "Build something meaningful")
        let nextStep = try actions.createNextStep(title: "Sketch one idea", for: nextVision)
        context.delete(nextStep)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Vision>()) == 1)
        #expect(nextVision.activeStep == nil)
    }
}
