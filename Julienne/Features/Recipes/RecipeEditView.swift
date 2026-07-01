import SwiftData
import SwiftUI

struct RecipeEditView: View {
    enum Mode {
        case create
        case createIn(collection: RecipeCollection)
        case edit(Recipe)
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var yield: Int = 4
    @State private var draftIngredients: [IngredientDraft] = []
    @State private var draftSteps: [StepDraft] = []

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        Form {
            Section("Recipe") {
                TextField("Title", text: $title)
                Stepper(value: $yield, in: 1...100) {
                    Text("Yields \(yield) servings")
                }
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Notes")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }

            Section {
                ForEach($draftIngredients) { $ingredient in
                    IngredientEditRow(ingredient: $ingredient)
                }
                .onDelete { offsets in
                    draftIngredients.remove(atOffsets: offsets)
                }
                .onMove { from, to in
                    draftIngredients.move(fromOffsets: from, toOffset: to)
                }
                Button {
                    draftIngredients.append(IngredientDraft())
                } label: {
                    Label("Add Ingredient", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Ingredients")
            }

            Section {
                ForEach($draftSteps) { $step in
                    TextField("Step", text: $step.text, axis: .vertical)
                        .lineLimit(1...6)
                }
                .onDelete { offsets in
                    draftSteps.remove(atOffsets: offsets)
                }
                .onMove { from, to in
                    draftSteps.move(fromOffsets: from, toOffset: to)
                }
                Button {
                    draftSteps.append(StepDraft())
                } label: {
                    Label("Add Step", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Steps")
            }
        }
        .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            #if os(iOS) || os(visionOS)
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
            #endif
        }
        .onAppear(perform: load)
    }

    private func load() {
        switch mode {
        case .create, .createIn:
            if draftIngredients.isEmpty {
                draftIngredients = [IngredientDraft()]
            }
            if draftSteps.isEmpty {
                draftSteps = [StepDraft()]
            }
        case .edit(let recipe):
            title = recipe.title
            notes = recipe.notes ?? ""
            yield = recipe.yield
            draftIngredients = recipe.orderedIngredients.map { IngredientDraft(model: $0) }
            draftSteps = recipe.orderedSteps.map { StepDraft(model: $0) }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }

        let recipe: Recipe
        switch mode {
        case .create, .createIn:
            recipe = Recipe(title: trimmedTitle, yield: yield)
            context.insert(recipe)
        case .edit(let existing):
            recipe = existing
            recipe.title = trimmedTitle
            recipe.yield = yield
        }
        recipe.notes = notes.isEmpty ? nil : notes

        for old in recipe.ingredients ?? [] { context.delete(old) }
        for old in recipe.steps ?? [] { context.delete(old) }

        let ingredients = draftIngredients.enumerated().compactMap { index, draft -> Ingredient? in
            let name = draft.name.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { return nil }
            let ingredient = Ingredient(name: name, amount: draft.amount, unit: draft.unit, sortOrder: index)
            ingredient.recipe = recipe
            return ingredient
        }
        for ingredient in ingredients { context.insert(ingredient) }
        recipe.ingredients = ingredients

        let steps = draftSteps.enumerated().compactMap { index, draft -> RecipeStep? in
            let text = draft.text.trimmingCharacters(in: .whitespaces)
            guard !text.isEmpty else { return nil }
            let step = RecipeStep(text: text, sortOrder: index)
            step.recipe = recipe
            return step
        }
        for step in steps { context.insert(step) }
        recipe.steps = steps

        if case .createIn(let collection) = mode {
            var current = collection.recipes ?? []
            current.append(recipe)
            collection.recipes = current
        }

        recipe.touch()
        dismiss()
    }
}

private struct IngredientDraft: Identifiable {
    let id = UUID()
    var name: String = ""
    var amount: Double = 0
    var unit: RecipeUnit = .count

    init() {}

    init(model: Ingredient) {
        name = model.name
        amount = model.amount
        unit = model.unit
    }
}

private struct StepDraft: Identifiable {
    let id = UUID()
    var text: String = ""

    init() {}

    init(model: RecipeStep) {
        text = model.text
    }
}

private struct IngredientEditRow: View {
    @Binding var ingredient: IngredientDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Ingredient", text: $ingredient.name)
            HStack {
                TextField("Amount", value: $ingredient.amount, format: .number)
                    .frame(maxWidth: 100)
                    #if os(iOS) || os(visionOS)
                    .keyboardType(.decimalPad)
                    #endif
                Picker("Unit", selection: $ingredient.unit) {
                    ForEach(RecipeUnit.editableCases) { unit in
                        Text(unit.menuLabel).tag(unit)
                    }
                }
                .labelsHidden()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecipeEditView(mode: .create)
    }
    .modelContainer(PreviewSupport.container())
}
