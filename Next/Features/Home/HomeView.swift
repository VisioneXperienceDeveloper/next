import SwiftUI

struct HomeView: View {
    let vision: Vision
    var present: (HomeSheet) -> Void

    var body: some View {
        ScrollView {
            NextGlassGroup {
                VStack(alignment: .leading, spacing: 32) {
                    TimelineView(.periodic(from: .now, by: 60)) { timeline in
                        Text(timeline.date, format: .dateTime.weekday(.wide).day().month(.wide))
                            .font(.subheadline)
                            .foregroundStyle(Color.primary.opacity(0.68))
                    }

                    if let step = vision.activeStep {
                        activeStep(step)
                    } else {
                        emptyStep
                    }

                    Button { present(.editVision(vision)) } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Eyebrow(title: Copy.yourVision)
                            Text(verbatim: vision.title)
                                .font(.title2)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(Text(Copy.editVisionHint))
                    .accessibilityIdentifier("visionSummary")

                    NavigationLink { JourneyView(vision: vision) } label: {
                        Label { Text(Copy.viewJourney) } icon: { Image(systemName: "arrow.right") }
                            .font(.body.weight(.medium))
                            .frame(minHeight: 44)
                    }
                    .nextSecondaryActionStyle()
                    .accessibilityIdentifier("viewJourney")
                }
                .frame(maxWidth: 560, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(Text(Copy.appName))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("homeScreen")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { NavigationLink { AboutView() } label: { Image(systemName: "info.circle").accessibilityLabel(Text(Copy.about)) } } }
    }

    private func activeStep(_ step: Step) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Copy.yourNextStep)
                .font(.title.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Button { present(.complete(step)) } label: {
                VStack(alignment: .leading, spacing: 32) {
                    Text(verbatim: step.title)
                        .font(.largeTitle.weight(.medium))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Text(Copy.complete)
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "circle")
                            .font(.body)
                            .accessibilityHidden(true)
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 20)
                    .frame(minHeight: 52)
                    .nextStepAffordance()
                }
                .padding(24)
                .frame(maxWidth: .infinity, minHeight: 240, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 32))
                .contentShape(RoundedRectangle(cornerRadius: 32))
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text(Copy.openStepHint))
            .accessibilityIdentifier("activeStep")
        }
    }

    private var emptyStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Copy.stepQuestion)
                .font(.largeTitle.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Text(Copy.emptyStep)
                .font(.body)
                .foregroundStyle(Color.primary.opacity(0.68))
            PrimaryButton(title: Copy.addStep) { present(.createStep(vision)) }
                .accessibilityIdentifier("addNextStep")
                .padding(.top, 8)
        }
    }
}
