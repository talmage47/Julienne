import SwiftUI

struct PlanRootView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Plan coming soon",
                systemImage: "calendar",
                description: Text("Weekly meal planning lands in Phase 2.")
            )
            .navigationTitle("Plan")
            .settingsToolbar()
        }
    }
}

#Preview {
    PlanRootView()
}
