import ActivityKit
import SwiftUI
import WidgetKit

struct CookingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CookingActivityAttributes.self) { context in
            // Lock screen / banner
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .padding(12)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.recipeTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Step \(context.state.stepIndex + 1) of \(context.state.totalSteps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(context.state.stepText)
                        .font(.subheadline)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .activityBackgroundTint(Color.black.opacity(0.9))
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.stepIndex + 1)/\(context.state.totalSteps)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.recipeTitle)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.stepText)
                        .font(.subheadline)
                        .lineLimit(3)
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text("\(context.state.stepIndex + 1)/\(context.state.totalSteps)")
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
            .widgetURL(URL(string: "julienne://cooking"))
            .keylineTint(.orange)
        }
    }
}
