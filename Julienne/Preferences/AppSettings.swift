import SwiftUI

@Observable
final class AppSettings {
    @MainActor static let shared = AppSettings()

    var unitSystem: UnitSystem {
        didSet {
            UserDefaults.standard.set(unitSystem.rawValue, forKey: Keys.unitSystem)
        }
    }

    var accentColor: Color {
        didSet {
            let (r, g, b) = accentColor.rgbComponents
            let defaults = UserDefaults.standard
            defaults.set(r, forKey: Keys.accentR)
            defaults.set(g, forKey: Keys.accentG)
            defaults.set(b, forKey: Keys.accentB)
        }
    }

    private enum Keys {
        static let unitSystem = "unitSystem"
        static let accentR = "accentColorR"
        static let accentG = "accentColorG"
        static let accentB = "accentColorB"
    }

    private init() {
        let defaults = UserDefaults.standard
        let raw = defaults.string(forKey: Keys.unitSystem) ?? UnitSystem.metric.rawValue
        unitSystem = UnitSystem(rawValue: raw) ?? .metric
        if defaults.object(forKey: Keys.accentR) != nil {
            accentColor = Color(
                red: defaults.double(forKey: Keys.accentR),
                green: defaults.double(forKey: Keys.accentG),
                blue: defaults.double(forKey: Keys.accentB)
            )
        } else {
            accentColor = Color(red: 0.0, green: 0.478, blue: 1.0)
        }
    }
}

extension Color {
    var rgbComponents: (Double, Double, Double) {
        let resolved = self.resolve(in: EnvironmentValues())
        return (Double(resolved.red), Double(resolved.green), Double(resolved.blue))
    }
}
