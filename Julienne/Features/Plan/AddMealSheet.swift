import SwiftData
import SwiftUI

struct AddMealSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Recipe.title) private var recipes: [Recipe]

    let date: Date

    @State private var query: String = ""

    private var filtered: [Recipe] {
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmed.isEmpty { return recipes }
        return recipes.filter { $0.title.lowercased().contains(trimmed) }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "No Recipes",
                        systemImage: "book",
                        description: Text("Create a recipe first, then plan it here.")
                    )
                } else {
                    ForEach(filtered) { recipe in
                        Button {
                            add(recipe)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recipe.title)
                                        .foregroundStyle(.white)
                                    Text("Yields \(recipe.yield)")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255))
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var title: String {
        "Plan for " + date.formatted(.dateTime.month().day().weekday())
    }

    private func add(_ recipe: Recipe) {
        let entry = MealPlanEntry(date: Calendar.current.startOfDay(for: date), recipe: recipe)
        context.insert(entry)
    }
}

#Preview {
    AddMealSheet(date: Date())
        .modelContainer(PreviewSupport.container())
}
