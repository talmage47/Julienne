import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppSettings.self) private var settings

    @State private var accentColor: Color = .blue
    @State private var showingExportDialog = false
    @State private var showingImporter = false

    private let backgroundColor = Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255)
    private let rowColor = Color(red: 0x24 / 255, green: 0x24 / 255, blue: 0x24 / 255)

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                List {
                    unitsSection(settings: settings)
                    appearanceSection(settings: settings)
                    dataSection
                    #if DEBUG
                    developerSection
                    #endif
                }
                .scrollContentBackground(.hidden)
                .listSectionSpacing(.compact)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(settings.accentColor)
                }
            }
            .confirmationDialog("Export Format", isPresented: $showingExportDialog, titleVisibility: .visible) {
                Button("JSON") {}
                Button("CSV") {}
                Button("Cancel", role: .cancel) {}
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json, .commaSeparatedText]) { _ in }
        }
        .presentationDragIndicator(.visible)
        .onAppear { accentColor = settings.accentColor }
        .onChange(of: accentColor) { _, new in settings.accentColor = new }
    }

    // MARK: - Sections

    private func unitsSection(settings: AppSettings) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Unit System")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Picker("Unit System", selection: Binding(
                    get: { settings.unitSystem },
                    set: { settings.unitSystem = $0 }
                )) {
                    Text("Imperial (lbs)").tag(UnitSystem.imperial)
                    Text("Metric (kg)").tag(UnitSystem.metric)
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)
            .listRowBackground(rowColor)
        } header: {
            Text("Units").foregroundStyle(.gray)
        }
    }

    private func appearanceSection(settings: AppSettings) -> some View {
        Section {
            HStack {
                Text("Accent Color").foregroundStyle(.white)
                Spacer()
                ColorPicker("", selection: $accentColor, supportsOpacity: false)
                    .labelsHidden()
            }
            .listRowBackground(rowColor)

            HStack {
                Text("Preview").foregroundStyle(.gray)
                Spacer()
                HStack(spacing: 10) {
                    Circle()
                        .fill(settings.accentColor)
                        .frame(width: 22, height: 22)
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(settings.accentColor, lineWidth: 1.5)
                        .frame(width: 60, height: 22)
                }
            }
            .listRowBackground(rowColor)
        } header: {
            Text("Appearance").foregroundStyle(.gray)
        }
    }

    private var dataSection: some View {
        Section {
            settingsRow(
                label: "Export Data",
                labelColor: .white,
                trailing: { Image(systemName: "square.and.arrow.up").foregroundStyle(.gray) }
            ) {
                showingExportDialog = true
            }

            settingsRow(
                label: "Import Data",
                labelColor: .white,
                trailing: { Image(systemName: "square.and.arrow.down").foregroundStyle(.gray) }
            ) {
                showingImporter = true
            }
        } header: {
            Text("Data").foregroundStyle(.gray)
        }
    }

    #if DEBUG
    private var developerSection: some View {
        Section {
            settingsRow(
                label: "Load Sample Data",
                labelColor: .orange,
                trailing: { EmptyView() }
            ) {
                loadSampleData()
            }

            settingsRow(
                label: "Wipe All Data",
                labelColor: .red,
                trailing: { EmptyView() }
            ) {
                wipeAllData()
            }
        } header: {
            Text("Developer").foregroundStyle(.gray)
        }
    }
    #endif

    // MARK: - Row builder

    @ViewBuilder
    private func settingsRow<Trailing: View>(
        label: String,
        labelColor: Color,
        @ViewBuilder trailing: () -> Trailing,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(label).foregroundStyle(labelColor)
                Spacer()
                trailing()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(rowColor)
    }

    // MARK: - Dev actions

    #if DEBUG
    private func loadSampleData() {
        let pasta = Recipe(title: "Pasta al Limone", yield: 4, notes: "Bright and quick.")
        pasta.ingredients = [
            Ingredient(name: "Spaghetti", amount: 400, unit: .grams, sortOrder: 0),
            Ingredient(name: "Lemons", amount: 2, unit: .count, sortOrder: 1),
            Ingredient(name: "Parmesan", amount: 100, unit: .grams, sortOrder: 2),
            Ingredient(name: "Olive oil", amount: 60, unit: .milliliters, sortOrder: 3),
        ]
        pasta.steps = [
            RecipeStep(text: "Boil salted water; cook pasta to al dente.", sortOrder: 0),
            RecipeStep(text: "Zest and juice the lemons.", sortOrder: 1),
            RecipeStep(text: "Toss pasta with oil, juice, zest, and cheese.", sortOrder: 2),
        ]

        let soup = Recipe(title: "Tomato Soup", yield: 6, notes: "Weeknight comfort.")
        soup.ingredients = [
            Ingredient(name: "Tomatoes", amount: 1.5, unit: .kilograms, sortOrder: 0),
            Ingredient(name: "Onion", amount: 1, unit: .count, sortOrder: 1),
            Ingredient(name: "Garlic", amount: 3, unit: .count, sortOrder: 2),
            Ingredient(name: "Cream", amount: 200, unit: .milliliters, sortOrder: 3),
        ]
        soup.steps = [
            RecipeStep(text: "Sauté onion and garlic until soft.", sortOrder: 0),
            RecipeStep(text: "Add tomatoes and simmer 25 minutes.", sortOrder: 1),
            RecipeStep(text: "Blend smooth and stir in cream.", sortOrder: 2),
        ]

        let cookies = Recipe(title: "Chocolate Chip Cookies", yield: 24)
        cookies.ingredients = [
            Ingredient(name: "Butter", amount: 225, unit: .grams, sortOrder: 0),
            Ingredient(name: "Brown sugar", amount: 200, unit: .grams, sortOrder: 1),
            Ingredient(name: "Sugar", amount: 100, unit: .grams, sortOrder: 2),
            Ingredient(name: "Eggs", amount: 2, unit: .count, sortOrder: 3),
            Ingredient(name: "Flour", amount: 350, unit: .grams, sortOrder: 4),
            Ingredient(name: "Chocolate chips", amount: 300, unit: .grams, sortOrder: 5),
        ]
        cookies.steps = [
            RecipeStep(text: "Cream butter and sugars.", sortOrder: 0),
            RecipeStep(text: "Beat in eggs, then flour.", sortOrder: 1),
            RecipeStep(text: "Fold in chips. Bake 12 min at 180°C.", sortOrder: 2),
        ]

        let weeknights = RecipeCollection(name: "Weeknights")
        weeknights.recipes = [pasta, soup]

        let baking = RecipeCollection(name: "Baking")
        baking.recipes = [cookies]

        context.insert(pasta)
        context.insert(soup)
        context.insert(cookies)
        context.insert(weeknights)
        context.insert(baking)
    }

    private func wipeAllData() {
        do {
            try context.delete(model: Recipe.self)
            try context.delete(model: Ingredient.self)
            try context.delete(model: RecipeStep.self)
            try context.delete(model: RecipeCollection.self)
            try context.save()
        } catch {
            print("Wipe failed: \(error)")
        }
    }
    #endif
}

#Preview {
    SettingsView()
        .environment(AppSettings.shared)
        .modelContainer(PreviewSupport.container())
}
