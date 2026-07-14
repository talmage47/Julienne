import SwiftUI

struct CookingBar: View {
    @Environment(CookingSession.self) private var session
    @Environment(AppSettings.self) private var settings
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(settings.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.recipe?.title ?? "")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if session.totalSteps > 0 {
                        Text("Step \(session.stepIndex + 1) of \(session.totalSteps) · \(session.currentStepText)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.up")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    let session = CookingSession()
    let recipe = Recipe(title: "Pasta al Limone", yield: 4)
    recipe.steps = [
        RecipeStep(text: "Boil water and cook pasta.", sortOrder: 0),
        RecipeStep(text: "Toss with lemon and parmesan.", sortOrder: 1),
    ]
    session.start(recipe: recipe)
    return VStack {
        Spacer()
        CookingBar(onTap: {})
    }
    .background(Color.black)
    .environment(session)
    .environment(AppSettings.shared)
}
