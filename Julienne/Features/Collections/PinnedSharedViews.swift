import SwiftData
import SwiftUI

private let squircleGridColumns = [
    GridItem(.flexible(), spacing: 0),
    GridItem(.flexible(), spacing: 0),
]

private let squircleCellPadding: CGFloat = 6

enum PinnedItem: Identifiable {
    case collection(RecipeCollection)
    case recipe(Recipe)

    var id: String {
        switch self {
        case .collection(let c): return "collection:\(c.id.uuidString)"
        case .recipe(let r): return "recipe:\(r.id.uuidString)"
        }
    }

    var pinOrder: Int {
        switch self {
        case .collection(let c): return c.pinOrder
        case .recipe(let r): return r.pinOrder
        }
    }

    func setPinOrder(_ value: Int) {
        switch self {
        case .collection(let c): c.pinOrder = value
        case .recipe(let r): r.pinOrder = value
        }
    }

    var sortKey: String {
        switch self {
        case .collection(let c): return c.name
        case .recipe(let r): return r.title
        }
    }
}

@MainActor
enum PinOrdering {
    static func nextPinOrder(in context: ModelContext) -> Int {
        let recipeFetch = FetchDescriptor<Recipe>(predicate: #Predicate<Recipe> { $0.isPinned })
        let collectionFetch = FetchDescriptor<RecipeCollection>(predicate: #Predicate<RecipeCollection> { $0.isPinned })
        let maxRecipe = (try? context.fetch(recipeFetch))?.map(\.pinOrder).max()
        let maxCollection = (try? context.fetch(collectionFetch))?.map(\.pinOrder).max()
        return max(maxRecipe ?? -1, maxCollection ?? -1) + 1
    }

    static func togglePin(_ recipe: Recipe, in context: ModelContext) {
        if recipe.isPinned {
            recipe.isPinned = false
        } else {
            recipe.pinOrder = nextPinOrder(in: context)
            recipe.isPinned = true
        }
    }

    static func togglePin(_ collection: RecipeCollection, in context: ModelContext) {
        if collection.isPinned {
            collection.isPinned = false
        } else {
            collection.pinOrder = nextPinOrder(in: context)
            collection.isPinned = true
        }
    }

    static func reorderPinned(sourceID: String, targetID: String, in items: [PinnedItem]) {
        guard sourceID != targetID,
              let src = items.firstIndex(where: { $0.id == sourceID }),
              let tgt = items.firstIndex(where: { $0.id == targetID }) else { return }
        var arr = items
        let moving = arr.remove(at: src)
        let insertAt = src < tgt ? tgt - 1 : tgt
        arr.insert(moving, at: min(insertAt, arr.count))
        for (i, item) in arr.enumerated() { item.setPinOrder(i) }
    }

    static func reorderShared(sourceID: String, targetID: String, in recipes: [Recipe]) {
        guard sourceID != targetID,
              let src = recipes.firstIndex(where: { $0.id.uuidString == sourceID }),
              let tgt = recipes.firstIndex(where: { $0.id.uuidString == targetID }) else { return }
        var arr = recipes
        let moving = arr.remove(at: src)
        let insertAt = src < tgt ? tgt - 1 : tgt
        arr.insert(moving, at: min(insertAt, arr.count))
        for (i, recipe) in arr.enumerated() { recipe.sharedOrder = i }
    }
}

struct PinnedItemsView: View {
    @Environment(\.modelContext) private var context
    @Query private var allRecipes: [Recipe]
    @Query private var collections: [RecipeCollection]

    private var items: [PinnedItem] {
        let cs = collections.filter { $0.isPinned }.map(PinnedItem.collection)
        let rs = allRecipes.filter { $0.isPinned }.map(PinnedItem.recipe)
        return (cs + rs).sorted { a, b in
            if a.pinOrder != b.pinOrder { return a.pinOrder < b.pinOrder }
            return a.sortKey < b.sortKey
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: squircleGridColumns, spacing: 0) {
                ForEach(items) { item in
                    pinnedCell(item)
                        .padding(squircleCellPadding)
                        .contentShape(Rectangle())
                        .dropDestination(for: String.self) { dropped, _ in
                            guard let src = dropped.first, src != item.id else { return false }
                            PinOrdering.reorderPinned(sourceID: src, targetID: item.id, in: items)
                            return true
                        }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: items.map(\.id))
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Pinned")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func pinnedCell(_ item: PinnedItem) -> some View {
        switch item {
        case .collection(let collection):
            NavigationLink {
                CollectionDetailView(collection: collection)
            } label: {
                CollectionSquircle(collection: collection, size: nil)
            }
            .buttonStyle(.plain)
            .contextMenu {
                PinToggleButton(isPinned: collection.isPinned) {
                    PinOrdering.togglePin(collection, in: context)
                }
            }
            .draggable(item.id) {
                CollectionSquircle(collection: collection, size: nil)
            }
        case .recipe(let recipe):
            NavigationLink {
                RecipeDetailView(recipe: recipe)
            } label: {
                RecipeSquircle(recipe: recipe, size: nil)
            }
            .buttonStyle(.plain)
            .contextMenu {
                PinToggleButton(isPinned: recipe.isPinned) {
                    PinOrdering.togglePin(recipe, in: context)
                }
            }
            .draggable(item.id) {
                RecipeSquircle(recipe: recipe, size: nil)
            }
        }
    }
}

struct SharedItemsView: View {
    @Environment(\.modelContext) private var context
    @Query private var allRecipes: [Recipe]

    private var sharedRecipes: [Recipe] {
        allRecipes.filter { $0.sourceOwnerID != nil }.sorted { a, b in
            if a.sharedOrder != b.sharedOrder { return a.sharedOrder < b.sharedOrder }
            return a.title < b.title
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: squircleGridColumns, spacing: 0) {
                ForEach(sharedRecipes) { recipe in
                    let id = recipe.id.uuidString
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeSquircle(recipe: recipe, size: nil)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        PinToggleButton(isPinned: recipe.isPinned) {
                            PinOrdering.togglePin(recipe, in: context)
                        }
                    }
                    .draggable(id) {
                        RecipeSquircle(recipe: recipe, size: nil)
                    }
                    .padding(squircleCellPadding)
                    .contentShape(Rectangle())
                    .dropDestination(for: String.self) { dropped, _ in
                        guard let src = dropped.first, src != id else { return false }
                        PinOrdering.reorderShared(sourceID: src, targetID: id, in: sharedRecipes)
                        return true
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: sharedRecipes.map(\.id))
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
