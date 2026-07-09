import SwiftData
import SwiftUI

struct CollectionsRootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \RecipeCollection.createdAt, order: .reverse) private var collections: [RecipeCollection]
    @Query private var allRecipes: [Recipe]

    @State private var showingNewCollection = false
    @State private var newCollectionName = ""
    @State private var showingSettings = false
    @State private var showingNewRecipe = false

    private var pinnedRecipes: [Recipe] {
        allRecipes.filter { $0.isPinned }.sorted { $0.title < $1.title }
    }

    private var pinnedCollections: [RecipeCollection] {
        collections.filter { $0.isPinned }.sorted { $0.name < $1.name }
    }

    private var hasPinnedItems: Bool {
        !pinnedRecipes.isEmpty || !pinnedCollections.isEmpty
    }

    private var sharedRecipes: [Recipe] {
        allRecipes.filter { $0.sourceOwnerID != nil }.sorted { $0.title < $1.title }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if hasPinnedItems {
                        pinnedSection
                    }
                    if !sharedRecipes.isEmpty {
                        sharedSection
                    }
                    collectionsSection
                }
                .padding(.vertical)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingNewRecipe = true
                        } label: {
                            Label("New Recipe", systemImage: "square.and.pencil")
                        }
                        Button {
                            newCollectionName = ""
                            showingNewCollection = true
                        } label: {
                            Label("New Collection", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New Collection", isPresented: $showingNewCollection) {
                TextField("Name", text: $newCollectionName)
                Button("Cancel", role: .cancel) {}
                Button("Create") { createCollection() }
                    .disabled(newCollectionName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingNewRecipe) {
                NavigationStack {
                    RecipeEditView(mode: .create)
                }
            }
        }
    }

    // MARK: - Sections

    private var sharedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            navigableSectionHeader("Shared") {
                SharedItemsView()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(sharedRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            RecipeSquircle(recipe: recipe, size: Self.compactSquircleSize)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            PinToggleButton(isPinned: recipe.isPinned) {
                                recipe.isPinned.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            navigableSectionHeader("Pinned") {
                PinnedItemsView()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(pinnedCollections) { collection in
                        NavigationLink {
                            CollectionDetailView(collection: collection)
                        } label: {
                            CollectionSquircle(collection: collection, size: Self.compactSquircleSize)
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
                            RecipeSquircle(recipe: recipe, size: Self.compactSquircleSize)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            PinToggleButton(isPinned: recipe.isPinned) {
                                recipe.isPinned.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    private static let compactSquircleSize: CGFloat = 117

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Collections")

            VStack(spacing: 0) {
                NavigationLink {
                    AllRecipesView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "tray.full.fill")
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.25))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("All Recipes")
                                .foregroundStyle(.white)
                            Text("\(allRecipes.count) recipes")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if collections.isEmpty {
                    Text("No collections yet")
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                } else {
                    ForEach(collections) { collection in
                        NavigationLink {
                            CollectionDetailView(collection: collection)
                        } label: {
                            collectionRow(collection)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            PinToggleButton(isPinned: collection.isPinned) {
                                collection.isPinned.toggle()
                            }
                        }
                    }
                }
            }
        }
    }

    private func collectionRow(_ collection: RecipeCollection) -> some View {
        HStack(spacing: 12) {
            RecipeThumbnail(recipe: collection.recipes?.first)
            VStack(alignment: .leading, spacing: 2) {
                Text(collection.name)
                    .foregroundStyle(.white)
                Text("\(collection.recipeCount) recipes")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            if collection.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.title.bold())
                .foregroundStyle(.white)
            Image(systemName: "chevron.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.gray)
            Spacer()
        }
        .padding(.horizontal)
    }

    private func navigableSectionHeader<Destination: View>(
        _ title: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            sectionHeader(title)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func createCollection() {
        let name = newCollectionName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let collection = RecipeCollection(name: name)
        context.insert(collection)
    }
}

#Preview {
    CollectionsRootView()
        .modelContainer(PreviewSupport.container())
        .environment(AppSettings.shared)
}
