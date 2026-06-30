import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(AppSettings.self) private var settings

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
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSupport.container())
        .environment(AppSettings.shared)
}
