import Foundation
import SwiftData

@MainActor
enum MockData {
    static func seed(into context: ModelContext) {
        let pasta = Recipe(title: "Pasta al Limone", yield: 4, notes: "Bright and quick.")
        pasta.isPinned = true
        pasta.pinOrder = 0
        pasta.ingredients = [
            Ingredient(name: "Spaghetti", amount: 400, unit: .grams, sortOrder: 0),
            Ingredient(name: "Lemons", amount: 2, unit: .count, sortOrder: 1),
            Ingredient(name: "Parmesan", amount: 100, unit: .grams, sortOrder: 2),
            Ingredient(name: "Olive oil", amount: 60, unit: .milliliters, sortOrder: 3),
        ]
        pasta.steps = [
            RecipeStep(text: "Boil salted water; cook pasta to al dente.", sortOrder: 0),
            RecipeStep(text: "Zest and juice the lemons.", sortOrder: 1),
            RecipeStep(text: "Toss pasta with oil, juice, zest, and cheese.", sortOrder: 2),
        ]

        let soup = Recipe(title: "Tomato Soup", yield: 6, notes: "Weeknight comfort.")
        soup.isPinned = true
        soup.pinOrder = 1
        soup.ingredients = [
            Ingredient(name: "Tomatoes", amount: 1.5, unit: .kilograms, sortOrder: 0),
            Ingredient(name: "Onion", amount: 1, unit: .count, sortOrder: 1),
            Ingredient(name: "Garlic", amount: 3, unit: .count, sortOrder: 2),
            Ingredient(name: "Cream", amount: 200, unit: .milliliters, sortOrder: 3),
        ]
        soup.steps = [
            RecipeStep(text: "Sauté onion and garlic until soft.", sortOrder: 0),
            RecipeStep(text: "Add tomatoes and simmer 25 minutes.", sortOrder: 1),
            RecipeStep(text: "Blend smooth and stir in cream.", sortOrder: 2),
        ]

        let cookies = Recipe(title: "Chocolate Chip Cookies", yield: 24)
        cookies.isPinned = true
        cookies.pinOrder = 2
        cookies.ingredients = [
            Ingredient(name: "Butter", amount: 225, unit: .grams, sortOrder: 0),
            Ingredient(name: "Brown sugar", amount: 200, unit: .grams, sortOrder: 1),
            Ingredient(name: "Sugar", amount: 100, unit: .grams, sortOrder: 2),
            Ingredient(name: "Eggs", amount: 2, unit: .count, sortOrder: 3),
            Ingredient(name: "Flour", amount: 350, unit: .grams, sortOrder: 4),
            Ingredient(name: "Chocolate chips", amount: 300, unit: .grams, sortOrder: 5),
        ]
        cookies.steps = [
            RecipeStep(text: "Cream butter and sugars.", sortOrder: 0),
            RecipeStep(text: "Beat in eggs, then flour.", sortOrder: 1),
            RecipeStep(text: "Fold in chips. Bake 12 min at 180°C.", sortOrder: 2),
        ]

        let chicken = Recipe(title: "Sheet-Pan Chicken & Veggies", yield: 4)
        chicken.ingredients = [
            Ingredient(name: "Chicken thighs", amount: 8, unit: .count, sortOrder: 0),
            Ingredient(name: "Potatoes", amount: 700, unit: .grams, sortOrder: 1),
            Ingredient(name: "Broccoli", amount: 1, unit: .count, sortOrder: 2),
            Ingredient(name: "Olive oil", amount: 60, unit: .milliliters, sortOrder: 3),
        ]
        chicken.steps = [
            RecipeStep(text: "Toss everything with oil, salt, pepper.", sortOrder: 0),
            RecipeStep(text: "Roast 35 min at 220°C.", sortOrder: 1),
        ]

        let curry = Recipe(title: "Coconut Chicken Curry", yield: 4)
        curry.ingredients = [
            Ingredient(name: "Chicken breast", amount: 600, unit: .grams, sortOrder: 0),
            Ingredient(name: "Coconut milk", amount: 400, unit: .milliliters, sortOrder: 1),
            Ingredient(name: "Curry paste", amount: 3, unit: .tablespoons, sortOrder: 2),
            Ingredient(name: "Bell peppers", amount: 2, unit: .count, sortOrder: 3),
        ]
        curry.steps = [
            RecipeStep(text: "Fry curry paste, add chicken.", sortOrder: 0),
            RecipeStep(text: "Pour in coconut milk, simmer 15 min.", sortOrder: 1),
            RecipeStep(text: "Add peppers, cook 5 min more.", sortOrder: 2),
        ]

        let tacos = Recipe(title: "Carnitas Tacos", yield: 6)
        tacos.ingredients = [
            Ingredient(name: "Pork shoulder", amount: 1.5, unit: .kilograms, sortOrder: 0),
            Ingredient(name: "Orange", amount: 1, unit: .count, sortOrder: 1),
            Ingredient(name: "Corn tortillas", amount: 18, unit: .count, sortOrder: 2),
            Ingredient(name: "Cilantro", amount: 1, unit: .count, sortOrder: 3),
        ]
        tacos.steps = [
            RecipeStep(text: "Braise pork with orange and spices 3 hours.", sortOrder: 0),
            RecipeStep(text: "Shred and crisp in the pan.", sortOrder: 1),
            RecipeStep(text: "Pile onto tortillas; top with cilantro.", sortOrder: 2),
        ]

        let salad = Recipe(title: "Avocado Citrus Salad", yield: 2)
        salad.ingredients = [
            Ingredient(name: "Avocado", amount: 2, unit: .count, sortOrder: 0),
            Ingredient(name: "Grapefruit", amount: 1, unit: .count, sortOrder: 1),
            Ingredient(name: "Arugula", amount: 100, unit: .grams, sortOrder: 2),
            Ingredient(name: "Olive oil", amount: 30, unit: .milliliters, sortOrder: 3),
        ]
        salad.steps = [
            RecipeStep(text: "Segment the grapefruit.", sortOrder: 0),
            RecipeStep(text: "Toss with avocado, arugula, oil, salt.", sortOrder: 1),
        ]

        let pancakes = Recipe(title: "Buttermilk Pancakes", yield: 4)
        pancakes.ingredients = [
            Ingredient(name: "Flour", amount: 300, unit: .grams, sortOrder: 0),
            Ingredient(name: "Buttermilk", amount: 400, unit: .milliliters, sortOrder: 1),
            Ingredient(name: "Eggs", amount: 2, unit: .count, sortOrder: 2),
            Ingredient(name: "Butter", amount: 50, unit: .grams, sortOrder: 3),
        ]
        pancakes.steps = [
            RecipeStep(text: "Whisk dry, then add wet.", sortOrder: 0),
            RecipeStep(text: "Cook on a hot griddle until bubbles set.", sortOrder: 1),
        ]

        let ramen = Recipe(title: "Weeknight Miso Ramen", yield: 2)
        ramen.sourceOwnerID = "friend-alex"
        ramen.sharedOrder = 0
        ramen.sourceRecipeID = UUID()
        ramen.copiedAt = Date()
        ramen.ingredients = [
            Ingredient(name: "Ramen noodles", amount: 200, unit: .grams, sortOrder: 0),
            Ingredient(name: "Miso paste", amount: 3, unit: .tablespoons, sortOrder: 1),
            Ingredient(name: "Soft-boiled eggs", amount: 2, unit: .count, sortOrder: 2),
            Ingredient(name: "Scallions", amount: 3, unit: .count, sortOrder: 3),
        ]
        ramen.steps = [
            RecipeStep(text: "Simmer broth with miso.", sortOrder: 0),
            RecipeStep(text: "Cook noodles. Combine. Top with eggs and scallions.", sortOrder: 1),
        ]

        let pizza = Recipe(title: "Friday Night Pizza", yield: 2)
        pizza.sourceOwnerID = "friend-jules"
        pizza.sharedOrder = 1
        pizza.sourceRecipeID = UUID()
        pizza.copiedAt = Date()
        pizza.ingredients = [
            Ingredient(name: "Pizza dough", amount: 500, unit: .grams, sortOrder: 0),
            Ingredient(name: "Mozzarella", amount: 250, unit: .grams, sortOrder: 1),
            Ingredient(name: "Crushed tomatoes", amount: 200, unit: .grams, sortOrder: 2),
            Ingredient(name: "Basil", amount: 1, unit: .count, sortOrder: 3),
        ]
        pizza.steps = [
            RecipeStep(text: "Stretch dough; top with sauce and cheese.", sortOrder: 0),
            RecipeStep(text: "Bake hot, 8-10 min. Finish with basil.", sortOrder: 1),
        ]

        let weeknights = RecipeCollection(name: "Weeknights")
        weeknights.recipes = [pasta, soup, chicken, curry, ramen]

        let baking = RecipeCollection(name: "Baking")
        baking.recipes = [cookies, pancakes]

        let weekend = RecipeCollection(name: "Weekend Projects")
        weekend.recipes = [tacos, pizza]

        let lightAndFresh = RecipeCollection(name: "Light & Fresh")
        lightAndFresh.recipes = [salad, pasta]

        [pasta, soup, cookies, chicken, curry, tacos, salad, pancakes, ramen, pizza]
            .forEach { context.insert($0) }
        [weeknights, baking, weekend, lightAndFresh].forEach { context.insert($0) }
    }
}
