import SwiftUI

enum PreferenceKey {
    static let unitSystem = "unitSystem"
}

extension UnitSystem {
    static let storageKey = PreferenceKey.unitSystem
}

@propertyWrapper
struct UnitSystemPreference: DynamicProperty {
    @AppStorage(PreferenceKey.unitSystem) private var rawValue: String = UnitSystem.metric.rawValue

    var wrappedValue: UnitSystem {
        get { UnitSystem(rawValue: rawValue) ?? .metric }
        nonmutating set { rawValue = newValue.rawValue }
    }

    var projectedValue: Binding<UnitSystem> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
