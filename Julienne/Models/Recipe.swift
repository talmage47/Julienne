import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String? = nil
    var yield: Int = 1
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()

    var parentRecipeID: UUID? = nil
    var variationName: String? = nil

    var sourceRecipeID: UUID? = nil
    var sourceOwnerID: String? = nil
    var copiedAt: Date? = nil

    var imageData: Data? = nil
    var isPinned: Bool = false
    var pinOrder: Int = 0
    var sharedOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var ingredients: [Ingredient]? = []

    @Relationship(deleteRule: .cascade, inverse: \RecipeStep.recipe)
    var steps: [RecipeStep]? = []

    @Relationship(inverse: \RecipeCollection.recipes)
    var collections: [RecipeCollection]? = []

    init(title: String = "", yield: Int = 1, notes: String? = nil) {
        self.title = title
        self.yield = yield
        self.notes = notes
    }

    var orderedIngredients: [Ingredient] {
        (ingredients ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var orderedSteps: [RecipeStep] {
        (steps ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    func touch() {
        modifiedAt = Date()
    }
}
