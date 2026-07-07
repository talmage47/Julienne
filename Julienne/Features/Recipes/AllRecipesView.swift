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
                    .contextMenu {
                        PinToggleButton(isPinned: recipe.isPinned) {
                            recipe.isPinned.toggle()
                        }
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
        HStack(spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.title.isEmpty ? "Untitled" : recipe.title)
                    .font(.body)
                Text("Serves \(recipe.yield) · \(recipe.orderedIngredients.count) ingredients")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if recipe.isPinned {
                Spacer(minLength: 0)
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 2)
    }
}

struct PinToggleButton: View {
    let isPinned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(isPinned ? "Unpin" : "Pin",
                  systemImage: isPinned ? "pin.slash" : "pin")
        }
    }
}

#Preview {
    NavigationStack {
        AllRecipesView()
    }
    .modelContainer(PreviewSupport.container())
}
