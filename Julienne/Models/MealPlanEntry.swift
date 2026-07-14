import Foundation
import SwiftData

@Model
final class MealPlanEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var scale: Double = 1.0
    var servings: Int = 0
    var createdAt: Date = Date()

    var recipe: Recipe?

    init(date: Date = Date(), recipe: Recipe? = nil, scale: Double = 1.0, servings: Int = 0) {
        self.date = date
        self.recipe = recipe
        self.scale = scale
        self.servings = servings
    }

    var dayKey: Date {
        Calendar.current.startOfDay(for: date)
    }
}
