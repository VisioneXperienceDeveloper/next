import Foundation
import SwiftData
import Testing
@testable import Next

@MainActor
struct CoreLoopTests {
    @Test func completionReflectionAndContinuity() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        let actions = VisionActions(context: container.mainContext)
        let vision = try actions.createVision(title: "Write a book")
        let first = try actions.createNextStep(title: "Write a paragraph", for: vision)
        #expect(throws: DomainError.stepNotCompleted) { try actions.addReflection("A lesson", to: first) }
        let completion = Date(timeIntervalSince1970: 5000)
        try actions.completeStep(first, now: completion)
        #expect(first.isCompleted && first.completedAt == completion)
        #expect(vision.activeStep == nil)
        #expect(throws: DomainError.stepAlreadyCompleted) { try actions.completeStep(first) }
        #expect(first.completedAt == completion)
        #expect(throws: DomainError.emptyStatement) { try actions.addReflection(" \n", to: first) }
        let reflection = try actions.addReflection("  Start with a scene. \n", to: first)
        #expect(first.reflection?.id == reflection.id)
        #expect(reflection.step?.id == first.id)
        #expect(reflection.content == "Start with a scene.")
        #expect(throws: DomainError.reflectionExists) { try actions.addReflection("Again", to: first) }
        let second = try actions.createNextStep(title: "Write the next scene", for: vision)
        #expect(vision.activeStep?.id == second.id)
        #expect(JourneyOrder.completed(vision.steps).map(\.id) == [first.id])
        try actions.updateVision(vision, title: "Write a novel")
        #expect(first.reflection?.content == "Start with a scene.")
        try actions.deleteVision(vision)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Step>()) == 0)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Reflection>()) == 0)
    }

    @Test func journeyUsesCompletionNotCreationAndGroupsMonths() throws {
        let container = try Persistence.makeContainer(inMemory: true)
        defer { withExtendedLifetime(container) {} }
        let actions = VisionActions(context: container.mainContext)
        let vision = try actions.createVision(title: "Learn")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let first = try actions.createNextStep(title: "First", for: vision, now: .distantFuture)
        try actions.completeStep(first, now: Date(timeIntervalSince1970: 0))
        let second = try actions.createNextStep(title: "Second", for: vision, now: .distantPast)
        try actions.completeStep(second, now: Date(timeIntervalSince1970: 40 * 86400))
        _ = try actions.createNextStep(title: "Still active", for: vision)
        #expect(JourneyOrder.completed(vision.steps).map(\.id) == [second.id, first.id])
        let groups = JourneyOrder.months(vision.steps, calendar: calendar)
        #expect(groups.count == 2)
        #expect(groups.first?.steps.first?.id == second.id)
    }

    @Test func entireLoopPersistsAcrossContainers() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Next.store")
        do {
            let container = try Persistence.makeContainer(url: url)
            let actions = VisionActions(context: container.mainContext)
            let vision = try actions.createVision(title: "Build something")
            let step = try actions.createNextStep(title: "Sketch one idea", for: vision)
            try actions.completeStep(step)
            try actions.addReflection("Keep it small", to: step)
            try actions.createNextStep(title: "Make a prototype", for: vision)
        }
        do {
            let container = try Persistence.makeContainer(url: url)
            let vision = try #require(container.mainContext.fetch(FetchDescriptor<Vision>()).first)
            #expect(vision.activeStep?.title == "Make a prototype")
            #expect(JourneyOrder.completed(vision.steps).first?.reflection?.content == "Keep it small")
            try VisionActions(context: container.mainContext).deleteVision(vision)
        }
        let reopened = try Persistence.makeContainer(url: url)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<Vision>()) == 0)
        #expect(try reopened.mainContext.fetchCount(FetchDescriptor<Reflection>()) == 0)
    }
}
