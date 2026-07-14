import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(CookingSession.self) private var cookingSession
    @State private var showingCookingMode = false

    var body: some View {
        TabView {
            Tab("Collections", systemImage: "folder") {
                CollectionsRootView()
            }
            Tab("Plan", systemImage: "calendar") {
                PlanRootView()
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchRootView()
            }
        }
        .tint(settings.accentColor)
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if cookingSession.isActive {
                CookingBar(onTap: { showingCookingMode = true })
            }
        }
        .animation(.easeInOut(duration: 0.25), value: cookingSession.isActive)
        .onChange(of: cookingSession.isActive) { _, active in
            if active { showingCookingMode = true }
        }
        .fullScreenCover(isPresented: $showingCookingMode) {
            CookingModeView()
                .environment(cookingSession)
                .environment(settings)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSupport.container())
        .environment(AppSettings.shared)
        .environment(CookingSession())
}
