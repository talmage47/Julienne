import SwiftData
import SwiftUI

struct PlanRootView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppSettings.self) private var settings
    @Query(sort: \MealPlanEntry.date) private var entries: [MealPlanEntry]

    @State private var focusedDay: Date = Calendar.current.startOfDay(for: Date())
    @State private var addingForDate: Date?
    @State private var showingExport = false

    private var calendar: Calendar { .current }

    private var weekDays: [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: focusedDay) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    private func entries(on day: Date) -> [MealPlanEntry] {
        let start = calendar.startOfDay(for: day)
        return entries.filter { calendar.isDate($0.date, inSameDayAs: start) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                weekStrip
                Divider().background(Color.white.opacity(0.08))
                dayContent
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Plan")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingExport = true
                    } label: {
                        Image(systemName: "cart")
                    }
                    .accessibilityLabel("Export to Reminders")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addingForDate = focusedDay
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add meal")
                }
            }
            .settingsToolbar()
            .sheet(item: Binding(
                get: { addingForDate.map { AddMealTarget(date: $0) } },
                set: { addingForDate = $0?.date }
            )) { target in
                AddMealSheet(date: target.date)
            }
            .sheet(isPresented: $showingExport) {
                ShoppingExportSheet(initialStart: focusedDay)
            }
        }
    }

    // MARK: - Week strip

    private var weekStrip: some View {
        HStack(spacing: 6) {
            ForEach(weekDays, id: \.self) { day in
                let selected = calendar.isDate(day, inSameDayAs: focusedDay)
                let count = entries(on: day).count
                Button {
                    focusedDay = day
                } label: {
                    VStack(spacing: 4) {
                        Text(day.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.caption2)
                            .foregroundStyle(selected ? .white : .gray)
                        Text(day.formatted(.dateTime.day()))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(selected ? .white : .white.opacity(0.8))
                        Circle()
                            .fill(count > 0 ? settings.accentColor : Color.clear)
                            .frame(width: 5, height: 5)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selected ? settings.accentColor.opacity(0.25) : Color.white.opacity(0.04))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .overlay(alignment: .topLeading) {
            weekNavigation
                .padding(.top, -32)
        }
    }

    private var weekNavigation: some View {
        HStack {
            Button {
                shiftWeek(-1)
            } label: {
                Image(systemName: "chevron.left")
            }
            Text(weekLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.gray)
            Button {
                shiftWeek(1)
            } label: {
                Image(systemName: "chevron.right")
            }
            Spacer()
            Button("Today") { focusedDay = calendar.startOfDay(for: Date()) }
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 12)
    }

    private var weekLabel: String {
        guard let first = weekDays.first, let last = weekDays.last else { return "" }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: first)) – \(f.string(from: last))"
    }

    private func shiftWeek(_ delta: Int) {
        if let new = calendar.date(byAdding: .weekOfYear, value: delta, to: focusedDay) {
            focusedDay = new
        }
    }

    // MARK: - Day content

    private var dayContent: some View {
        let dayEntries = entries(on: focusedDay)
        return Group {
            if dayEntries.isEmpty {
                ContentUnavailableView {
                    Label("No Meals Planned", systemImage: "fork.knife")
                } description: {
                    Text("Tap + to add a recipe for this day.")
                }
                .foregroundStyle(.white)
            } else {
                List {
                    ForEach(dayEntries) { entry in
                        entryRow(entry)
                            .listRowBackground(Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255))
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            context.delete(dayEntries[index])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func entryRow(_ entry: MealPlanEntry) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.recipe?.title ?? "Missing recipe")
                    .foregroundStyle(.white)
                Text(subtitle(for: entry))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Stepper("", value: Binding(
                get: { entry.scale },
                set: { entry.scale = max(0.25, $0) }
            ), in: 0.25...10, step: 0.25)
            .labelsHidden()
        }
    }

    private func subtitle(for entry: MealPlanEntry) -> String {
        guard let recipe = entry.recipe else { return "" }
        let portions = max(1, Int((Double(recipe.yield) * entry.scale).rounded()))
        return "\(portions) servings · \(String(format: "%.2gx", entry.scale))"
    }
}

private struct AddMealTarget: Identifiable {
    let date: Date
    var id: Date { date }
}

#Preview {
    PlanRootView()
        .modelContainer(PreviewSupport.container())
        .environment(AppSettings.shared)
        .environment(CookingSession())
}
