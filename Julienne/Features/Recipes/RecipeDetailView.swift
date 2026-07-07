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
                Button {
                    recipe.isPinned.toggle()
                } label: {
                    Image(systemName: recipe.isPinned ? "pin.fill" : "pin")
                }
                .accessibilityLabel(recipe.isPinned ? "Unpin recipe" : "Pin recipe")
            }
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

    @State private var override: RecipeUnit?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(ingredient.name)
            Spacer(minLength: 12)
            unitControl
        }
        .onAppear {
            if override == nil {
                override = IngredientDisplayUnit.read(for: ingredient.id)
            }
        }
    }

    @ViewBuilder
    private var unitControl: some View {
        let options = RecipeUnit.allCases(for: ingredient.unit.kind)
        if options.count <= 1 {
            Text(displayString)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        } else {
            Menu {
                ForEach(options) { unit in
                    Button(unit.menuLabel) {
                        override = unit
                        IngredientDisplayUnit.write(unit, for: ingredient.id)
                    }
                }
            } label: {
                ZStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Text(widestPlaceholder(among: options))
                            .monospacedDigit()
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .hidden()

                    HStack(spacing: 4) {
                        Text(displayString)
                            .monospacedDigit()
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }

    private var displayUnit: RecipeUnit {
        if let override { return override }
        if ingredient.unit.kind == .count { return .count }
        let base = Quantity(amount: ingredient.amount, unit: ingredient.unit)
        return base.displayed(in: system).unit
    }

    private var displayString: String {
        let canonical = ingredient.amount * scale * ingredient.unit.toCanonical
        if displayUnit == .poundsOunces {
            return poundsOuncesLabel(fromGrams: canonical)
        }
        let converted = canonical / displayUnit.toCanonical
        return "\(AmountFormatter.string(converted)) \(displayUnit.fullName(for: converted))"
    }

    private func widestPlaceholder(among options: [RecipeUnit]) -> String {
        options.map { unit -> String in
            let canonical = ingredient.amount * scale * ingredient.unit.toCanonical
            if unit == .poundsOunces {
                return poundsOuncesLabel(fromGrams: canonical)
            }
            let converted = canonical / unit.toCanonical
            return "\(AmountFormatter.string(converted)) \(unit.fullName(for: converted))"
        }
        .max(by: { $0.count < $1.count }) ?? displayString
    }

    private func poundsOuncesLabel(fromGrams grams: Double) -> String {
        let totalOunces = grams / 28.3495
        if totalOunces < 1 {
            let ozName = totalOunces == 1 ? "ounce" : "ounces"
            return "\(AmountFormatter.string(totalOunces)) \(ozName)"
        }
        var pounds = Int((totalOunces / 16).rounded(.down))
        var ounces = Int((totalOunces - Double(pounds) * 16).rounded())
        if ounces == 16 {
            pounds += 1
            ounces = 0
        }
        let lbName = pounds == 1 ? "pound" : "pounds"
        let ozName = ounces == 1 ? "ounce" : "ounces"
        if pounds == 0 { return "\(ounces) \(ozName)" }
        if ounces == 0 { return "\(pounds) \(lbName)" }
        return "\(pounds) \(lbName) \(ounces) \(ozName)"
    }
}

#Preview {
    NavigationStack {
        let context = PreviewSupport.container().mainContext
        let recipe = (try? context.fetch(FetchDescriptor<Recipe>()))?.first ?? Recipe(title: "Sample", yield: 2)
        RecipeDetailView(recipe: recipe)
    }
}
