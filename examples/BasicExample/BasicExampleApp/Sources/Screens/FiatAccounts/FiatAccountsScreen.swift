import Candle
import SwiftUI

struct FiatAccountsScreen: View {
    @Environment(CandleClient.self) private var client

    @State var errorMessage: String? = nil
    @State var fiatAccounts = [Models.PrimaryFiatHoldingAccount]()
    @State private var query: Models.GetFiatAccounts.Input.Query = .init()
    @State var isLoading = false

    let linkedAccounts: [Models.LinkedAccount]

    var body: some View {
        NavigationStack {
            if isLoading {
                Spacer()
                ProgressView {
                    Text("Loading...")
                }
                Spacer()
            } else {
                List {
                    ForEach(fiatAccounts) { account in
                        FiatAccountRow(account: account)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            LinkedAccountsMenu(
                                linkedAccounts: linkedAccounts,
                                errorMessage: $errorMessage
                            ) { value in
                                self.query = .init(linkedAccountIDs: value)
                            }
                        } label: {
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                        }
                    }
                }
                .overlay {
                    if fiatAccounts.isEmpty {
                        ContentUnavailableView(
                            "No Fiat Accounts",
                            systemImage: "exclamationmark.magnifyingglass",
                            description: Text(
                                "Please pull to refresh or try again later."
                            )
                        )
                    }
                }
                .navigationTitle("Fiat Accounts")
            }
        }
        .sensoryFeedback(.error, trigger: errorMessage) { $1 != nil }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"), message: Text(errorMessage ?? "No Message"),
                dismissButton: .cancel(Text("OK"), action: { errorMessage = nil }))
        }
        .task(id: query) {
            await loadFiatAccounts(query: query)
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(.extraLarge)
    }

    private func loadFiatAccounts(query: Models.GetFiatAccounts.Input.Query) async {
        defer { isLoading = false }
        do {
            isLoading = true
            fiatAccounts = try await client.getFiatAccounts(query: query)
        } catch {
            errorMessage = String(describing: error)
        }
    }
}

#Preview {
    FiatAccountsScreen(linkedAccounts: [])
}
