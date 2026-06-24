import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe
    @UnitSystemPreference private var unitSystem

    @State private var scale: Double = 1.0
    @State private var showingEdit = false

    private var portions: Int {
        max(1, Int((Double(recipe.yield) * scale).rounded()))
    }

    var body: some View {
        Form {
            Section {
                ScaleControl(scale: $scale, baseYield: recipe.yield, portions: portions)
            }

            if !recipe.orderedIngredients.isEmpty {
                Section("Ingredients") {
                    ForEach(recipe.orderedIngredients) { ingredient in
                        IngredientRow(ingredient: ingredient, scale: scale, system: unitSystem)
                    }
                }
            }

            if !recipe.orderedSteps.isEmpty {
                Section("Steps") {
                    ForEach(Array(recipe.orderedSteps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(index + 1).")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 24, alignment: .trailing)
                            Text(step.text)
                        }
                    }
                }
            }

            if let notes = recipe.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
            }
        }
        .navigationTitle(recipe.title.isEmpty ? "Untitled" : recipe.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                RecipeEditView(mode: .edit(recipe))
            }
        }
    }
}

private struct ScaleControl: View {
    @Binding var scale: Double
    let baseYield: Int
    let portions: Int

    private let presets: [Double] = [0.5, 1, 2]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Servings")
                Spacer()
                Text("\(portions)")
                    .font(.headline)
                    .monospacedDigit()
            }
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { value in
                    Button {
                        scale = value
                    } label: {
                        Text(label(for: value))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(scale == value ? .accentColor : .secondary)
                }
            }
            Stepper(value: $scale, in: 0.25...10, step: 0.25) {
                Text("Scale: \(String(format: "%.2gx", scale))")
                    .monospacedDigit()
            }
            Text("Base recipe yields \(baseYield)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func label(for value: Double) -> String {
        switch value {
        case 0.5: "½×"
        case 1: "1×"
        case 2: "2×"
        default: String(format: "%.2gx", value)
        }
    }
}

private struct IngredientRow: View {
    let ingredient: Ingredient
    let scale: Double
    let system: UnitSystem

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(displayAmount)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(minWidth: 80, alignment: .leading)
            Text(ingredient.name)
            Spacer()
        }
    }

    private var displayAmount: String {
        let scaled = Quantity(amount: ingredient.amount * scale, unit: ingredient.unit)
        let display = ingredient.unit.kind == .count ? scaled : scaled.displayed(in: system)
        return AmountFormatter.string(display)
    }
}

#Preview {
    NavigationStack {
        let context = PreviewSupport.container().mainContext
        let recipe = (try? context.fetch(FetchDescriptor<Recipe>()))?.first ?? Recipe(title: "Sample", yield: 2)
        RecipeDetailView(recipe: recipe)
    }
}
