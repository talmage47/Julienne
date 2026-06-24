import Foundation

enum MeasurementKind: String, Codable, CaseIterable, Sendable {
    case mass
    case volume
    case count
}

enum UnitSystem: String, Codable, CaseIterable, Identifiable, Sendable {
    case metric
    case imperial

    var id: String { rawValue }

    var label: String {
        switch self {
        case .metric: "Metric"
        case .imperial: "Imperial"
        }
    }
}

enum RecipeUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case grams
    case kilograms
    case ounces
    case pounds

    case milliliters
    case liters
    case teaspoons
    case tablespoons
    case cups
    case fluidOunces
    case pints
    case quarts
    case gallons

    case count

    var id: String { rawValue }

    var kind: MeasurementKind {
        switch self {
        case .grams, .kilograms, .ounces, .pounds:
            .mass
        case .milliliters, .liters, .teaspoons, .tablespoons, .cups, .fluidOunces, .pints, .quarts, .gallons:
            .volume
        case .count:
            .count
        }
    }

    var system: UnitSystem? {
        switch self {
        case .grams, .kilograms, .milliliters, .liters:
            .metric
        case .ounces, .pounds, .teaspoons, .tablespoons, .cups, .fluidOunces, .pints, .quarts, .gallons:
            .imperial
        case .count:
            nil
        }
    }

    /// Multiplier from this unit to its kind's canonical unit (g for mass, ml for volume, count for count).
    var toCanonical: Double {
        switch self {
        case .grams: 1
        case .kilograms: 1000
        case .ounces: 28.3495
        case .pounds: 453.592
        case .milliliters: 1
        case .liters: 1000
        case .teaspoons: 4.92892
        case .tablespoons: 14.7868
        case .cups: 236.588
        case .fluidOunces: 29.5735
        case .pints: 473.176
        case .quarts: 946.353
        case .gallons: 3785.41
        case .count: 1
        }
    }

    var shortLabel: String {
        switch self {
        case .grams: "g"
        case .kilograms: "kg"
        case .ounces: "oz"
        case .pounds: "lb"
        case .milliliters: "ml"
        case .liters: "L"
        case .teaspoons: "tsp"
        case .tablespoons: "tbsp"
        case .cups: "cup"
        case .fluidOunces: "fl oz"
        case .pints: "pt"
        case .quarts: "qt"
        case .gallons: "gal"
        case .count: ""
        }
    }

    var longLabel: String {
        switch self {
        case .grams: "Grams"
        case .kilograms: "Kilograms"
        case .ounces: "Ounces"
        case .pounds: "Pounds"
        case .milliliters: "Milliliters"
        case .liters: "Liters"
        case .teaspoons: "Teaspoons"
        case .tablespoons: "Tablespoons"
        case .cups: "Cups"
        case .fluidOunces: "Fluid Ounces"
        case .pints: "Pints"
        case .quarts: "Quarts"
        case .gallons: "Gallons"
        case .count: "Count"
        }
    }

    static func allCases(for kind: MeasurementKind) -> [RecipeUnit] {
        RecipeUnit.allCases.filter { $0.kind == kind }
    }
}

struct Quantity: Equatable, Sendable {
    var amount: Double
    var unit: RecipeUnit

    var canonicalAmount: Double { amount * unit.toCanonical }

    /// Convert to a target unit of the same kind. Returns nil for cross-kind conversion.
    func converted(to target: RecipeUnit) -> Quantity? {
        guard target.kind == unit.kind else { return nil }
        return Quantity(amount: canonicalAmount / target.toCanonical, unit: target)
    }

    /// Pick a sensible display unit in the requested system for this measurement's kind. Picks the largest unit that keeps the amount >= 1.
    func displayed(in system: UnitSystem) -> Quantity {
        let candidates = Self.displayCandidates(for: unit.kind, system: system)
        guard !candidates.isEmpty else { return self }
        let ordered = candidates.sorted { $0.toCanonical < $1.toCanonical }
        let canonical = canonicalAmount
        var pick = ordered.first ?? unit
        for candidate in ordered where canonical / candidate.toCanonical >= 1 {
            pick = candidate
        }
        return converted(to: pick) ?? self
    }

    private static func displayCandidates(for kind: MeasurementKind, system: UnitSystem) -> [RecipeUnit] {
        switch (kind, system) {
        case (.mass, .metric): [.grams, .kilograms]
        case (.mass, .imperial): [.ounces, .pounds]
        case (.volume, .metric): [.milliliters, .liters]
        case (.volume, .imperial): [.teaspoons, .tablespoons, .fluidOunces, .cups, .pints, .quarts, .gallons]
        case (.count, _): [.count]
        }
    }
}

enum AmountFormatter {
    static func string(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "—" }
        let rounded = (value * 100).rounded() / 100
        if rounded == rounded.rounded() {
            return String(Int(rounded))
        }
        return String(format: "%.2f", rounded)
            .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
    }

    static func string(_ quantity: Quantity) -> String {
        let amount = string(quantity.amount)
        let label = quantity.unit.shortLabel
        return label.isEmpty ? amount : "\(amount) \(label)"
    }
}
