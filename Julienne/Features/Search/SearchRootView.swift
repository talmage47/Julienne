import SwiftData
import SwiftUI

struct SearchRootView: View {
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @State private var query: String = ""

    private var filtered: [Recipe] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return recipes }
        return recipes.filter { recipe in
            if recipe.title.localizedCaseInsensitiveContains(trimmed) { return true }
            return recipe.orderedIngredients.contains { ingredient in
                ingredient.name.localizedCaseInsensitiveContains(trimmed)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    RecipeRow(recipe: recipe)
                }
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Recipes or ingredients")
            .settingsToolbar()
        }
    }
}

#Preview {
    SearchRootView()
        .modelContainer(PreviewSupport.container())
}
