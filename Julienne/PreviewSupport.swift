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
        MockData.seed(into: context)
    }
}
