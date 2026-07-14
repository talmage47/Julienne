import SwiftData
import SwiftUI

struct ShoppingExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @UnitSystemPreference private var unitSystem
    @Query private var allEntries: [MealPlanEntry]

    let initialStart: Date

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var checked: Set<UUID> = []
    @State private var exportError: String?
    @State private var isExporting = false
    @State private var didExport = false

    init(initialStart: Date) {
        self.initialStart = initialStart
        let cal = Calendar.current
        let start = cal.startOfDay(for: initialStart)
        let end = cal.date(byAdding: .day, value: 6, to: start) ?? start
        _startDate = State(initialValue: start)
        _endDate = State(initialValue: end)
    }

    private var entriesInRange: [MealPlanEntry] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: startDate)
        let endInclusive = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: endDate)) ?? endDate
        return allEntries.filter { $0.date >= start && $0.date < endInclusive }
    }

    private var aggregated: [AggregatedIngredient] {
        RemindersExporter.aggregate(entries: entriesInRange, in: unitSystem)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Date Range") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                .listRowBackground(Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255))

                Section {
                    if aggregated.isEmpty {
                        Text("No planned meals in this range.")
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(aggregated) { item in
                            row(item)
                        }
                    }
                } header: {
                    HStack {
                        Text("Ingredients")
                        Spacer()
                        if !aggregated.isEmpty {
                            Button(checked.count == aggregated.count ? "None" : "All") {
                                if checked.count == aggregated.count {
                                    checked.removeAll()
                                } else {
                                    checked = Set(aggregated.map(\.id))
                                }
                            }
                            .font(.caption.weight(.semibold))
                        }
                    }
                }

                if let exportError {
                    Section {
                        Text(exportError).foregroundStyle(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await export() }
                    } label: {
                        if isExporting {
                            ProgressView()
                        } else {
                            Text(didExport ? "Done" : "Export")
                        }
                    }
                    .disabled(checked.isEmpty || isExporting)
                }
            }
            .onAppear {
                checked = Set(aggregated.map(\.id))
            }
            .onChange(of: startDate) { _, _ in checked = Set(aggregated.map(\.id)) }
            .onChange(of: endDate) { _, _ in checked = Set(aggregated.map(\.id)) }
        }
    }

    private func row(_ item: AggregatedIngredient) -> some View {
        let isChecked = checked.contains(item.id)
        return Button {
            if isChecked { checked.remove(item.id) } else { checked.insert(item.id) }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isChecked ? settings.accentColor : .gray)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(item.name)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(item.displayText)
                            .foregroundStyle(.gray)
                            .monospacedDigit()
                    }
                    if !item.sourceRecipes.isEmpty {
                        Text(item.sourceRecipes.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundStyle(.gray.opacity(0.7))
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255))
    }

    @MainActor
    private func export() async {
        isExporting = true
        defer { isExporting = false }
        exportError = nil

        let selected = aggregated.filter { checked.contains($0.id) }
        guard !selected.isEmpty else { return }

        let granted = await RemindersExporter.requestAccess()
        guard granted else {
            exportError = "Reminders access denied. Enable it in Settings › Privacy › Reminders."
            return
        }

        do {
            _ = try await RemindersExporter.write(selected)
            didExport = true
            try? await Task.sleep(nanoseconds: 500_000_000)
            dismiss()
        } catch {
            exportError = error.localizedDescription
        }
    }
}

#Preview {
    ShoppingExportSheet(initialStart: Date())
        .modelContainer(PreviewSupport.container())
        .environment(AppSettings.shared)
}
