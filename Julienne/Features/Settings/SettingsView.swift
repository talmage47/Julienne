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
        MockData.seed(into: context)
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

private struct SettingsToolbarModifier: ViewModifier {
    @State private var showingSettings = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
    }
}

extension View {
    func settingsToolbar() -> some View {
        modifier(SettingsToolbarModifier())
    }
}
