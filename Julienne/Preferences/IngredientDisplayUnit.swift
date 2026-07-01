import Foundation

enum IngredientDisplayUnit {
    private static func key(for id: UUID) -> String {
        "ingredientDisplayUnit.\(id.uuidString)"
    }

    static func read(for id: UUID) -> RecipeUnit? {
        guard let raw = UserDefaults.standard.string(forKey: key(for: id)) else { return nil }
        return RecipeUnit(rawValue: raw)
    }

    static func write(_ unit: RecipeUnit, for id: UUID) {
        UserDefaults.standard.set(unit.rawValue, forKey: key(for: id))
    }
}
