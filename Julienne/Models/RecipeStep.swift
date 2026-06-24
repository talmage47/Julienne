import Foundation
import SwiftData

@Model
final class RecipeStep {
    var id: UUID = UUID()
    var text: String = ""
    var sortOrder: Int = 0

    var recipe: Recipe?

    init(text: String = "", sortOrder: Int = 0) {
        self.text = text
        self.sortOrder = sortOrder
    }
}
