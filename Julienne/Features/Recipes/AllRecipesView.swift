import SwiftData
import SwiftUI

struct AllRecipesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @State private var showingNewRecipe = false

    var body: some View {
        List {
            if recipes.isEmpty {
                ContentUnavailableView(
                    "No recipes yet",
                    systemImage: "book.closed",
                    description: Text("Tap + to add your first recipe.")
                )
            } else {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeRow(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
        }
        .navigationTitle("All Recipes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewRecipe = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewRecipe) {
            NavigationStack {
                RecipeEditView(mode: .create)
            }
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            context.delete(recipes[index])
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(recipe.title.isEmpty ? "Untitled" : recipe.title)
                .font(.body)
            Text("Serves \(recipe.yield) · \(recipe.orderedIngredients.count) ingredients")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        AllRecipesView()
    }
    .modelContainer(PreviewSupport.container())
}
