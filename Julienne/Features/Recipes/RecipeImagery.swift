import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum RecipeEmoji {
    private static let mapping: [(String, String)] = [
        ("pasta", "🍝"), ("spaghetti", "🍝"), ("noodle", "🍜"), ("ramen", "🍜"),
        ("pizza", "🍕"), ("soup", "🍲"), ("stew", "🍲"), ("chili", "🌶️"),
        ("salad", "🥗"), ("cookie", "🍪"), ("brownie", "🍫"), ("cake", "🍰"),
        ("bread", "🍞"), ("toast", "🍞"), ("bagel", "🥯"), ("croissant", "🥐"),
        ("rice", "🍚"), ("sushi", "🍣"), ("fish", "🐟"), ("salmon", "🐟"),
        ("shrimp", "🦐"), ("chicken", "🍗"), ("turkey", "🦃"), ("steak", "🥩"),
        ("beef", "🥩"), ("pork", "🥓"), ("bacon", "🥓"),
        ("taco", "🌮"), ("burrito", "🌯"), ("burger", "🍔"), ("hotdog", "🌭"),
        ("curry", "🍛"), ("rice bowl", "🍚"), ("dumpling", "🥟"),
        ("egg", "🥚"), ("pancake", "🥞"), ("waffle", "🧇"),
        ("apple", "🍎"), ("lemon", "🍋"), ("tomato", "🍅"), ("avocado", "🥑"),
        ("smoothie", "🥤"), ("coffee", "☕️"), ("tea", "🍵"),
        ("ice cream", "🍨"), ("pie", "🥧"), ("donut", "🍩"),
    ]

    static func emoji(for title: String) -> String {
        let lower = title.lowercased()
        for (key, emoji) in mapping where lower.contains(key) {
            return emoji
        }
        return "🍽️"
    }
}

private enum RecipePalette {
    static let palettes: [[Color]] = [
        [Color(red: 0.95, green: 0.45, blue: 0.25), Color(red: 0.85, green: 0.20, blue: 0.30)],
        [Color(red: 0.20, green: 0.55, blue: 0.85), Color(red: 0.35, green: 0.30, blue: 0.75)],
        [Color(red: 0.20, green: 0.65, blue: 0.45), Color(red: 0.10, green: 0.40, blue: 0.55)],
        [Color(red: 0.95, green: 0.65, blue: 0.30), Color(red: 0.85, green: 0.35, blue: 0.20)],
        [Color(red: 0.80, green: 0.40, blue: 0.65), Color(red: 0.45, green: 0.25, blue: 0.55)],
        [Color(red: 0.30, green: 0.60, blue: 0.70), Color(red: 0.20, green: 0.35, blue: 0.55)],
        [Color(red: 0.85, green: 0.55, blue: 0.30), Color(red: 0.55, green: 0.25, blue: 0.20)],
    ]

    static func colors(for title: String) -> [Color] {
        let hash = abs(title.hashValue)
        return palettes[hash % palettes.count]
    }
}

struct RecipeSquircle: View {
    let recipe: Recipe
    var size: CGFloat? = 175

    var body: some View {
        SquircleBase(title: recipe.title, size: size) {
            RecipeBackground(recipe: recipe, emojiSize: 72)
        }
    }
}

struct CollectionSquircle: View {
    let collection: RecipeCollection
    var size: CGFloat? = 175

    private var coverRecipe: Recipe? {
        (collection.recipes ?? []).sorted { $0.title < $1.title }.first
    }

    var body: some View {
        SquircleBase(title: collection.name, size: size) {
            if let coverRecipe {
                RecipeBackground(recipe: coverRecipe, emojiSize: 72)
            } else {
                ZStack {
                    Color.gray.opacity(0.25)
                    Image(systemName: "folder.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

private struct SquircleBase<Background: View>: View {
    let title: String
    let size: CGFloat?
    @ViewBuilder let background: () -> Background

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            background()
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )
            Text(title.isEmpty ? "Untitled" : title)
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .shadow(color: .black.opacity(0.4), radius: 3)
        }
        .modifier(SquircleSize(size: size))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct SquircleSize: ViewModifier {
    let size: CGFloat?

    func body(content: Content) -> some View {
        if let size {
            content.frame(width: size, height: size)
        } else {
            content.aspectRatio(1, contentMode: .fit)
        }
    }
}

struct RecipeThumbnail: View {
    let recipe: Recipe?
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let recipe {
                RecipeBackground(recipe: recipe, emojiSize: size * 0.55)
            } else {
                ZStack {
                    Color.gray.opacity(0.25)
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct RecipeBackground: View {
    let recipe: Recipe
    let emojiSize: CGFloat

    var body: some View {
        ZStack {
            #if canImport(UIKit)
            if let data = recipe.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
            #else
            placeholder
            #endif
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: RecipePalette.colors(for: recipe.title),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text(RecipeEmoji.emoji(for: recipe.title))
                .font(.system(size: emojiSize))
        }
    }
}
