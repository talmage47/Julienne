import SwiftData
import SwiftUI

@main
struct JulienneApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Recipe.self,
                Ingredient.self,
                RecipeStep.self,
                RecipeCollection.self
            )
        } catch {
            print("ModelContainer failed: \(error)")
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AppSettings.shared)
        }
        .modelContainer(container)
    }
}

