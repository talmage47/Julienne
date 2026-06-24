import Foundation
import SwiftData

enum PreviewSupport {
    @MainActor
    static func container() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: Recipe.self,
                Ingredient.self,
                RecipeStep.self,
                RecipeCollection.self,
                configurations: config
            )
        } catch {
            fatalError("PreviewSupport container failed: \(error)")
        }
        seed(container.mainContext)
        return container
    }

    @MainActor
    private static func seed(_ context: ModelContext) {
        let pasta = Recipe(title: "Pasta al Limone", yield: 4, notes: "Bright and quick.")
        pasta.ingredients = [
            Ingredient(name: "Spaghetti", amount: 400, unit: .grams, sortOrder: 0),
            Ingredient(name: "Lemons", amount: 2, unit: .count, sortOrder: 1),
            Ingredient(name: "Parmesan", amount: 100, unit: .grams, sortOrder: 2),
            Ingredient(name: "Olive oil", amount: 60, unit: .milliliters, sortOrder: 3),
        ]
        pasta.steps = [
            RecipeStep(text: "Boil salted water; cook pasta to al dente.", sortOrder: 0),
            RecipeStep(text: "Zest and juice the lemons.", sortOrder: 1),
            RecipeStep(text: "Toss pasta with oil, juice, zest, and cheese.", sortOrder: 2),
        ]

        let weeknights = RecipeCollection(name: "Weeknights")
        weeknights.recipes = [pasta]

        context.insert(pasta)
        context.insert(weeknights)
    }
}
