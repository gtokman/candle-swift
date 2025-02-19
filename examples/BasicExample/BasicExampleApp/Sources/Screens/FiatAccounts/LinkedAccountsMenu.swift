import Candle
import SwiftUI

struct LinkedAccountsMenu: View {
    @State private var selectedLinkedAccounts: [Models.LinkedAccount] = []

    let linkedAccounts: [Models.LinkedAccount]
    @Binding var errorMessage: String?
    let action: (String?) -> Void

    var formattedLinkedAccountIDs: String? {
        linkedAccounts.isEmpty
            ? nil : selectedLinkedAccounts.map(\.linkedAccountID).joined(separator: ",")
    }

    var body: some View {
        Menu("Linked Accounts") {
            ForEach(linkedAccounts) { account in
                Button(action: {
                    if selectedLinkedAccounts.contains(account) {
                        selectedLinkedAccounts.removeAll { $0 == account }
                    } else if linkedAccounts.count > 1 {
                        selectedLinkedAccounts.append(account)
                    } else {
                        errorMessage = "Must have more than 1 linked account to filter."
                    }
                }) {
                    Label(
                        "\(account.service.name) (\(account.activeDetails?.username ?? "inactive"))",
                        systemImage: selectedLinkedAccounts.contains(account)
                            || selectedLinkedAccounts.isEmpty ? "checkmark" : ""
                    )
                }
            }
        }
        .onChange(of: formattedLinkedAccountIDs) { _, newValue in
            action(newValue)
        }
    }
}
