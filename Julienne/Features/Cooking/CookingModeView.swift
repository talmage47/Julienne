import SwiftData
import SwiftUI

struct CookingModeView: View {
    @Environment(CookingSession.self) private var session
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @UnitSystemPreference private var unitSystem

    var body: some View {
        NavigationStack {
            Group {
                if let recipe = session.recipe {
                    content(recipe: recipe)
                } else {
                    ContentUnavailableView("Not Cooking", systemImage: "flame")
                }
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Minimize")
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            session.stop()
                            dismiss()
                        } label: {
                            Label("End Session", systemImage: "stop.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.white)
                    }
                }
            }
            .navigationTitle(session.recipe?.title ?? "")
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            #if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
        }
        .onDisappear {
            #if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = false
            #endif
        }
    }

    @ViewBuilder
    private func content(recipe: Recipe) -> some View {
        let steps = recipe.orderedSteps
        VStack(spacing: 0) {
            progressBar

            TabView(selection: bindingForStep) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    stepPage(step: step, index: index, total: steps.count, recipe: recipe)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            navigationControls(total: steps.count)
        }
    }

    private var bindingForStep: Binding<Int> {
        Binding(
            get: { session.stepIndex },
            set: { session.jump(to: $0) }
        )
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                Rectangle()
                    .fill(settings.accentColor)
                    .frame(width: max(0, proxy.size.width * session.progress))
                    .animation(.easeInOut(duration: 0.25), value: session.progress)
            }
        }
        .frame(height: 3)
    }

    private func stepPage(step: RecipeStep, index: Int, total: Int, recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Step \(index + 1) of \(total)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(settings.accentColor)
                    Spacer()
                }

                Text(step.text)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                if !recipe.orderedIngredients.isEmpty {
                    Divider().background(Color.white.opacity(0.15))
                    ingredientsBlock(recipe: recipe)
                }
            }
            .padding(24)
        }
    }

    private func ingredientsBlock(recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)
                .foregroundStyle(.white)
            ForEach(recipe.orderedIngredients) { ingredient in
                HStack(alignment: .firstTextBaseline) {
                    Text(ingredient.name)
                        .foregroundStyle(.white)
                    Spacer(minLength: 12)
                    Text(displayString(for: ingredient))
                        .monospacedDigit()
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    private func displayString(for ingredient: Ingredient) -> String {
        let canonical = ingredient.amount * session.scale * ingredient.unit.toCanonical
        let base = Quantity(amount: ingredient.amount * session.scale, unit: ingredient.unit)
        let displayed = base.displayed(in: unitSystem)
        let unit = displayed.unit
        let converted = canonical / unit.toCanonical
        return "\(AmountFormatter.string(converted)) \(unit.fullName(for: converted))"
    }

    private func navigationControls(total: Int) -> some View {
        HStack(spacing: 16) {
            Button {
                session.retreat()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.bordered)
            .tint(.white)
            .disabled(session.stepIndex <= 0)

            if session.stepIndex >= total - 1 {
                Button {
                    session.stop()
                    dismiss()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(settings.accentColor)
            } else {
                Button {
                    session.advance()
                } label: {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(settings.accentColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

#Preview {
    let session = CookingSession()
    let container = PreviewSupport.container()
    let recipe = (try? container.mainContext.fetch(FetchDescriptor<Recipe>()))?.first ?? Recipe(title: "Sample")
    session.start(recipe: recipe)
    return CookingModeView()
        .environment(session)
        .environment(AppSettings.shared)
        .modelContainer(container)
}
