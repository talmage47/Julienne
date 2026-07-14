import Foundation

#if os(iOS)
import ActivityKit

struct CookingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var stepIndex: Int
        public var totalSteps: Int
        public var stepText: String

        public init(stepIndex: Int, totalSteps: Int, stepText: String) {
            self.stepIndex = stepIndex
            self.totalSteps = totalSteps
            self.stepText = stepText
        }
    }

    public var recipeTitle: String

    public init(recipeTitle: String) {
        self.recipeTitle = recipeTitle
    }
}
#endif
