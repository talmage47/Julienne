import SwiftData
import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSupport.container())
}
