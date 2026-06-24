import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @UnitSystemPreference private var unitSystem

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Display system", selection: $unitSystem) {
                        ForEach(UnitSystem.allCases) { system in
                            Text(system.label).tag(system)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text("Affects how ingredient amounts are displayed. Stored values are unchanged.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    LabeledContent("App", value: "Julienne")
                    LabeledContent("Phase", value: "1 — Local foundation")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
