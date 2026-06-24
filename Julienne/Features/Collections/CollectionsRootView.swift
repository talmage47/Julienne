import SwiftData
import SwiftUI

struct CollectionsRootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \RecipeCollection.createdAt, order: .reverse) private var collections: [RecipeCollection]
    @Query private var allRecipes: [Recipe]

    @State private var showingNewCollection = false
    @State private var newCollectionName = ""
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        AllRecipesView()
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("All Recipes").font(.body)
                                Text("\(allRecipes.count) recipes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "tray.full")
                        }
                    }
                }

                Section("Collections") {
                    if collections.isEmpty {
                        Text("No collections yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(collections) { collection in
                            NavigationLink {
                                CollectionDetailView(collection: collection)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(collection.name)
                                    Text("\(collection.recipeCount) recipes")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteCollections)
                    }
                }
            }
            .navigationTitle("Julienne")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        newCollectionName = ""
                        showingNewCollection = true
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
        }
    }

    private func createCollection() {
        let name = newCollectionName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let collection = RecipeCollection(name: name)
        context.insert(collection)
    }

    private func deleteCollections(at offsets: IndexSet) {
        for index in offsets {
            context.delete(collections[index])
        }
    }
}

#Preview {
    CollectionsRootView()
        .modelContainer(PreviewSupport.container())
}
