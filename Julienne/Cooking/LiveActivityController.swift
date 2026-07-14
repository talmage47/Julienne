import Foundation

#if os(iOS)
import ActivityKit

/// Manages the lifecycle of a cooking Live Activity. Silently no-ops if Live Activities
/// are disabled by the user or the widget extension isn't installed.
enum LiveActivityController {
    private static var current: Activity<CookingActivityAttributes>?

    static func start(recipe: Recipe, stepIndex: Int, totalSteps: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        Task { await endAsync() }

        let attributes = CookingActivityAttributes(recipeTitle: recipe.title.isEmpty ? "Cooking" : recipe.title)
        let state = CookingActivityAttributes.ContentState(
            stepIndex: stepIndex,
            totalSteps: totalSteps,
            stepText: stepText(for: recipe, at: stepIndex)
        )

        do {
            current = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Live Activity start failed: \(error)")
        }
    }

    static func update(recipe: Recipe, stepIndex: Int, totalSteps: Int) {
        guard let activity = current else { return }
        let state = CookingActivityAttributes.ContentState(
            stepIndex: stepIndex,
            totalSteps: totalSteps,
            stepText: stepText(for: recipe, at: stepIndex)
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    static func end() {
        guard let activity = current else { return }
        current = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private static func endAsync() async {
        guard let activity = current else { return }
        current = nil
        await activity.end(nil, dismissalPolicy: .immediate)
    }

    private static func stepText(for recipe: Recipe, at index: Int) -> String {
        let steps = recipe.orderedSteps
        guard steps.indices.contains(index) else { return "" }
        return steps[index].text
    }
}
#else
enum LiveActivityController {
    static func start(recipe: Recipe, stepIndex: Int, totalSteps: Int) {}
    static func update(recipe: Recipe, stepIndex: Int, totalSteps: Int) {}
    static func end() {}
}
#endif
