import SwiftData
import SwiftUI

private let squircleGridColumns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12),
]

struct PinnedItemsView: View {
    @Query private var allRecipes: [Recipe]
    @Query(sort: \RecipeCollection.createdAt, order: .reverse) private var collections: [RecipeCollection]

    private var pinnedRecipes: [Recipe] {
        allRecipes.filter { $0.isPinned }.sorted { $0.title < $1.title }
    }

    private var pinnedCollections: [RecipeCollection] {
        collections.filter { $0.isPinned }.sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: squircleGridColumns, spacing: 12) {
                ForEach(pinnedCollections) { collection in
                    NavigationLink {
                        CollectionDetailView(collection: collection)
                    } label: {
                        CollectionSquircle(collection: collection, size: nil)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        PinToggleButton(isPinned: collection.isPinned) {
                            collection.isPinned.toggle()
                        }
                    }
                }
                ForEach(pinnedRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeSquircle(recipe: recipe, size: nil)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        PinToggleButton(isPinned: recipe.isPinned) {
                            recipe.isPinned.toggle()
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Pinned")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SharedItemsView: View {
    @Query private var allRecipes: [Recipe]

    private var sharedRecipes: [Recipe] {
        allRecipes.filter { $0.sourceOwnerID != nil }.sorted { $0.title < $1.title }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: squircleGridColumns, spacing: 12) {
                ForEach(sharedRecipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeSquircle(recipe: recipe, size: nil)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        PinToggleButton(isPinned: recipe.isPinned) {
                            recipe.isPinned.toggle()
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Shared")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Pinned") {
    NavigationStack {
        PinnedItemsView()
    }
    .modelContainer(PreviewSupport.container())
}

#Preview("Shared") {
    NavigationStack {
        SharedItemsView()
    }
    .modelContainer(PreviewSupport.container())
}
