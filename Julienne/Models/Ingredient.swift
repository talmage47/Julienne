import Foundation
import SwiftData

@Model
final class Ingredient {
    var id: UUID = UUID()
    var name: String = ""
    var amount: Double = 0
    var unitRaw: String = RecipeUnit.count.rawValue
    var sortOrder: Int = 0

    var recipe: Recipe?

    init(name: String = "", amount: Double = 0, unit: RecipeUnit = .count, sortOrder: Int = 0) {
        self.name = name
        self.amount = amount
        self.unitRaw = unit.rawValue
        self.sortOrder = sortOrder
    }

    var unit: RecipeUnit {
        get { RecipeUnit(rawValue: unitRaw) ?? .count }
        set { unitRaw = newValue.rawValue }
    }

    var quantity: Quantity {
        Quantity(amount: amount, unit: unit)
    }
}
