import Foundation
import SwiftData

@Model
final class RecipeCollection {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date()

    var recipes: [Recipe]? = []

    init(name: String = "") {
        self.name = name
    }

    var recipeCount: Int {
        recipes?.count ?? 0
    }
}
