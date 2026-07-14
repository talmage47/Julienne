import Foundation

#if canImport(EventKit)
import EventKit
#endif

struct AggregatedIngredient: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var displayText: String
    var sourceRecipes: [String]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AggregatedIngredient, rhs: AggregatedIngredient) -> Bool { lhs.id == rhs.id }
}

enum RemindersExporter {
    /// Aggregate ingredients across the given meal plan entries, converting each to the user's
    /// display system. Groups by (lowercased name, kind) and sums canonical amounts.
    @MainActor
    static func aggregate(entries: [MealPlanEntry], in system: UnitSystem) -> [AggregatedIngredient] {
        struct Key: Hashable {
            let name: String
            let kind: MeasurementKind
        }
        struct Bucket {
            var displayName: String
            var kind: MeasurementKind
            var canonical: Double
            var storedUnit: RecipeUnit
            var sources: Set<String>
        }

        var buckets: [Key: Bucket] = [:]
        for entry in entries {
            guard let recipe = entry.recipe else { continue }
            for ingredient in recipe.orderedIngredients {
                let name = ingredient.name.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { continue }
                let key = Key(name: name.lowercased(), kind: ingredient.unit.kind)
                let canonical = ingredient.amount * entry.scale * ingredient.unit.toCanonical
                var bucket = buckets[key] ?? Bucket(
                    displayName: name,
                    kind: ingredient.unit.kind,
                    canonical: 0,
                    storedUnit: ingredient.unit,
                    sources: []
                )
                bucket.canonical += canonical
                bucket.sources.insert(recipe.title.isEmpty ? "Untitled" : recipe.title)
                buckets[key] = bucket
            }
        }

        return buckets.values
            .sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
            .map { bucket -> AggregatedIngredient in
                let displayUnit = pickDisplayUnit(kind: bucket.kind, stored: bucket.storedUnit, system: system)
                let converted = bucket.canonical / displayUnit.toCanonical
                let text: String
                if bucket.kind == .count {
                    text = "\(AmountFormatter.string(converted))"
                } else {
                    text = "\(AmountFormatter.string(converted)) \(displayUnit.fullName(for: converted))"
                }
                return AggregatedIngredient(
                    name: bucket.displayName,
                    displayText: text,
                    sourceRecipes: Array(bucket.sources).sorted()
                )
            }
    }

    private static func pickDisplayUnit(kind: MeasurementKind, stored: RecipeUnit, system: UnitSystem) -> RecipeUnit {
        if kind == .count { return .count }
        return Quantity(amount: 1, unit: stored).displayed(in: system).unit
    }

    #if canImport(EventKit)
    /// Request reminders access. Returns true if granted (or already granted).
    static func requestAccess() async -> Bool {
        let store = EKEventStore()
        if #available(iOS 17.0, *) {
            do {
                return try await store.requestFullAccessToReminders()
            } catch {
                return false
            }
        } else {
            return await withCheckedContinuation { cont in
                store.requestAccess(to: .reminder) { granted, _ in
                    cont.resume(returning: granted)
                }
            }
        }
    }

    /// Create reminders for each item in the default reminders list. Returns number written.
    @discardableResult
    static func write(_ items: [AggregatedIngredient], listName: String? = nil) async throws -> Int {
        let store = EKEventStore()
        let calendar: EKCalendar
        if let listName, let match = store.calendars(for: .reminder).first(where: { $0.title == listName }) {
            calendar = match
        } else if let def = store.defaultCalendarForNewReminders() {
            calendar = def
        } else {
            throw RemindersExportError.noDefaultList
        }

        var written = 0
        for item in items {
            let reminder = EKReminder(eventStore: store)
            reminder.calendar = calendar
            reminder.title = "\(item.name) — \(item.displayText)"
            try store.save(reminder, commit: false)
            written += 1
        }
        try store.commit()
        return written
    }
    #else
    static func requestAccess() async -> Bool { false }
    static func write(_ items: [AggregatedIngredient], listName: String? = nil) async throws -> Int { 0 }
    #endif
}

enum RemindersExportError: LocalizedError {
    case noDefaultList
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .noDefaultList: "No default Reminders list is configured."
        case .notAuthorized: "Reminders access was not granted."
        }
    }
}
