import Foundation
import SwiftUI

@Observable
final class CookingSession {
    private(set) var recipe: Recipe?
    var stepIndex: Int = 0
    var scale: Double = 1.0
    private(set) var startedAt: Date?

    var isActive: Bool { recipe != nil }

    var totalSteps: Int {
        recipe?.orderedSteps.count ?? 0
    }

    var currentStep: RecipeStep? {
        guard let steps = recipe?.orderedSteps, steps.indices.contains(stepIndex) else { return nil }
        return steps[stepIndex]
    }

    var currentStepText: String {
        currentStep?.text ?? ""
    }

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(stepIndex + 1) / Double(totalSteps)
    }

    func start(recipe: Recipe, scale: Double = 1.0) {
        self.recipe = recipe
        self.scale = scale
        self.stepIndex = 0
        self.startedAt = Date()
        LiveActivityController.start(recipe: recipe, stepIndex: 0, totalSteps: recipe.orderedSteps.count)
    }

    func advance() {
        guard stepIndex < totalSteps - 1 else { return }
        stepIndex += 1
        pushLiveActivityUpdate()
    }

    func retreat() {
        guard stepIndex > 0 else { return }
        stepIndex -= 1
        pushLiveActivityUpdate()
    }

    func jump(to index: Int) {
        guard (0..<totalSteps).contains(index) else { return }
        stepIndex = index
        pushLiveActivityUpdate()
    }

    func stop() {
        recipe = nil
        stepIndex = 0
        scale = 1.0
        startedAt = nil
        LiveActivityController.end()
    }

    private func pushLiveActivityUpdate() {
        guard let recipe else { return }
        LiveActivityController.update(recipe: recipe, stepIndex: stepIndex, totalSteps: totalSteps)
    }
}
