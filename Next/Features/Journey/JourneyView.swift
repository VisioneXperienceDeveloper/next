import SwiftData
import SwiftUI

struct JourneyMonth: Identifiable {
    let date: Date
    let steps: [Step]
    var id: Date { date }
}

enum JourneyOrder {
    static func completed(_ steps: [Step]) -> [Step] {
        steps.filter { !$0.isDeleted && $0.completedAt != nil }.sorted {
            if $0.completedAt == $1.completedAt { return $0.id.uuidString < $1.id.uuidString }
            return ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)
        }
    }
    static func months(_ steps: [Step], calendar: Calendar = .current) -> [JourneyMonth] {
        let grouped = Dictionary(grouping: completed(steps)) { step in
            calendar.dateInterval(of: .month, for: step.completedAt ?? step.createdAt)?.start ?? step.createdAt
        }
        return grouped.keys.sorted(by: >).map { JourneyMonth(date: $0, steps: completed(grouped[$0] ?? [])) }
    }
}

struct JourneyView: View {
    @Query private var steps: [Step]
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    init(vision: Vision) {
        let id = vision.id
        _steps = Query(filter: #Predicate<Step> { $0.vision?.id == id && $0.completedAt != nil }, sort: \Step.completedAt, order: .reverse)
    }
    var body: some View {
        let months = JourneyOrder.months(steps)
        let lastStepID = months.last?.steps.last?.id

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                if steps.isEmpty {
                    Text(Copy.emptyJourneyTitle).font(.title2)
                    Text(Copy.emptyJourneyBody).foregroundStyle(Color.primary.opacity(0.68))
                } else {
                    ForEach(months) { month in
                        Section {
                            ForEach(month.steps) { step in
                                entry(step, showsConnector: step.id != lastStepID)
                                    .accessibilityElement(children: .combine)
                            }
                        } header: {
                            Text(month.date, format: .dateTime.month(.wide).year()).font(.caption.weight(.semibold)).textCase(.uppercase).tracking(1).foregroundStyle(Color.primary.opacity(0.68)).accessibilityAddTraits(.isHeader)
                        }
                    }
                }
            }.frame(maxWidth: 560, alignment: .leading).padding(24).frame(maxWidth: .infinity)
        }
        .defaultScrollAnchor(.top)
        .navigationTitle(Text(Copy.journey))
        .accessibilityIdentifier("journeyScreen")
    }

    @ViewBuilder private func entry(_ step: Step, showsConnector: Bool) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) {
                Text(step.completedAt ?? step.createdAt, format: .dateTime.day())
                    .font(.caption).foregroundStyle(Color.primary.opacity(0.68))
                contents(step)
            }
        } else {
            HStack(alignment: .top, spacing: 20) {
                VStack(spacing: 12) {
                    Text(step.completedAt ?? step.createdAt, format: .dateTime.day()).font(.headline).monospacedDigit()
                    if showsConnector {
                        Rectangle().fill(Color.primary.opacity(0.16)).frame(width: 1, height: 40).accessibilityHidden(true)
                    }
                }.frame(minWidth: 32)
                contents(step)
            }
        }
    }

    private func contents(_ step: Step) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: step.title).font(.title3.weight(.medium))
            if let reflection = step.reflection {
                Text(verbatim: reflection.content).font(.body).foregroundStyle(Color.primary.opacity(0.68))
            }
        }.fixedSize(horizontal: false, vertical: true)
    }

}
