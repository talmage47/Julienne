import SwiftData
import SwiftUI

struct CollectionDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var collection: RecipeCollection

    @State private var showingRecipePicker = false
    @State private var showingNewRecipe = false

    private var recipes: [Recipe] {
        (collection.recipes ?? []).sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        List {
            if recipes.isEmpty {
                ContentUnavailableView(
                    "No recipes yet",
                    systemImage: "book.closed",
                    description: Text("Add recipes from your library, or create a new one.")
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
                            PinOrdering.togglePin(recipe, in: context)
                        }
                    }
                }
                .onDelete { offsets in
                    let toRemove = offsets.map { recipes[$0] }
                    var current = collection.recipes ?? []
                    current.removeAll { recipe in toRemove.contains(where: { $0.id == recipe.id }) }
                    collection.recipes = current
                }
            }
        }
        .navigationTitle($collection.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        showingNewRecipe = true
                    } label: {
                        Label("New Recipe", systemImage: "square.and.pencil")
                    }
                    Button {
                        showingRecipePicker = true
                    } label: {
                        Label("Add from Library", systemImage: "tray.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingRecipePicker) {
            RecipePickerSheet(collection: collection)
        }
        .sheet(isPresented: $showingNewRecipe) {
            NavigationStack {
                RecipeEditView(mode: .createIn(collection: collection))
            }
        }
    }
}

private struct RecipePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var collection: RecipeCollection
    @Query(sort: \Recipe.title) private var allRecipes: [Recipe]

    private var available: [Recipe] {
        let inCollection = Set((collection.recipes ?? []).map(\.id))
        return allRecipes.filter { !inCollection.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List(available) { recipe in
                Button {
                    var current = collection.recipes ?? []
                    current.append(recipe)
                    collection.recipes = current
                    dismiss()
                } label: {
                    RecipeRow(recipe: recipe)
                }
                .foregroundStyle(.primary)
            }
            .overlay {
                if available.isEmpty {
                    ContentUnavailableView(
                        "Nothing to add",
                        systemImage: "checkmark.circle",
                        description: Text("Every recipe is already in this collection.")
                    )
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(collection: RecipeCollection(name: "Weeknights"))
    }
    .modelContainer(PreviewSupport.container())
}
