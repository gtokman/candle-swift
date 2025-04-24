import Candle
import SwiftUI

struct LinkedAccountsMenu: View {
    let linkedAccounts: [Models.LinkedAccount]

    @Binding var selectedLinkedAccounts: [Models.LinkedAccount]

    var body: some View {
        Menu("Linked Accounts") {
            ForEach(linkedAccounts) { linkedAccount in
                Button(action: {
                    if let index = selectedLinkedAccounts.firstIndex(of: linkedAccount) {
                        selectedLinkedAccounts.remove(at: index)
                    } else {
                        selectedLinkedAccounts.append(linkedAccount)
                    }
                }) {
                    Label(
                        [
                            // FIXME: Use LinkedAccountViewModel instead
                            linkedAccount.service.name,
                            "("
                                + (linkedAccount.activeDetails.map { $0.username ?? $0.legalName }
                                    ?? "inactive")
                                + ")",
                        ].joined(separator: " "),
                        systemImage: selectedLinkedAccounts.contains(linkedAccount)
                            ? "checkmark" : ""
                    )
                }
            }
        }
    }
}
