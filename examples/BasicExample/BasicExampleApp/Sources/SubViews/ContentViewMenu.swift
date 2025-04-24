import SwiftUI

struct ContentViewMenu: View {

    @Binding var showOnboarding: Bool
    @Binding var showDeleteConfirmation: Bool

    var body: some View {
        Menu {
            Button(action: {
                showOnboarding = true
            }) {
                Label("Onboarding", systemImage: "platter.filled.bottom.iphone")
            }
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Label("Delete User", systemImage: "person.fill.xmark")
            }
        } label: {
            Label("Settings", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    ContentViewMenu(showOnboarding: .constant(false), showDeleteConfirmation: .constant(false))
}
