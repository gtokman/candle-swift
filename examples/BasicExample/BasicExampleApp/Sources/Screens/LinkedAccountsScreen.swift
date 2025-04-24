import Candle
import SwiftUI

struct LinkedAccountsScreen: View {
    @Environment(CandleClient.self) private var client
    @Environment(\.colorScheme) var colorScheme

    @Binding var linkedAccounts: [Models.LinkedAccount]
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var isDataStale: Bool

    @State var accountToUnlink: LinkedAccountViewModel? = nil

    var gradientBackground: Color {
        colorScheme == .dark ? .black : .white
    }

    var viewModels: [LinkedAccountViewModel] {
        linkedAccounts.map { LinkedAccountViewModel(linkedAccount: $0) }
    }

    var body: some View {
        List {
            ForEach(viewModels) { linkedAccount in
                NavigationLink(
                    destination: DetailsView(
                        title: linkedAccount.title,
                        logoURL: linkedAccount.logoURL,
                        detailItems: linkedAccount.detailItems
                    )
                ) {
                    ItemRow(
                        title: linkedAccount.title,
                        subtitle: linkedAccount.subtitle,
                        value: linkedAccount.value,
                        logoURL: linkedAccount.logoURL
                    )
                }.swipeActions {
                    Button("Unlink") {
                        accountToUnlink = linkedAccount
                    }
                    .tint(.red)
                }
            }
        }
        .overlay(
            alignment: .bottom,
            content: {
                LinearGradient(
                    gradient: Gradient(colors: [
                        gradientBackground.opacity(0),
                        gradientBackground,
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ).frame(height: 50)
            }
        )
        .overlay {
            if isLoading {
                ProgressView {
                    Text("Loading...")
                }
            } else if linkedAccounts.isEmpty {
                ContentUnavailableView(
                    "No Linked Accounts",
                    systemImage: "exclamationmark.magnifyingglass",
                    description: Text("Tap \"Link Account\" to get started.")
                )
            }
        }
        .task(id: isDataStale) {
            guard isDataStale else { return }
            await getLinkedAccounts()
        }
        .refreshable {
            await getLinkedAccounts(showLoading: false)
        }
        .sensoryFeedback(.error, trigger: errorMessage) { $1 != nil }
        .confirmationDialog(
            "Unlink Account?",
            isPresented: .constant(accountToUnlink != nil),
            titleVisibility: .visible
        ) {
            Button(
                accountToUnlink?.title ?? "",  // NOTE: This scenario should never occur
                role: .destructive,
                action: {
                    if let accountToUnlink {
                        unlinkAccount(accountToUnlink)
                    } else {
                        errorMessage = "Something went wrong."
                    }
                    accountToUnlink = nil
                })
            Button("Cancel", role: .cancel) { accountToUnlink = nil }
        } message: {
            Text("Confirm your action to unlink the account.")
        }
        .navigationTitle("Linked Accounts")
    }

    private func unlinkAccount(_ linkedAccount: LinkedAccountViewModel) {
        Task {
            defer { isLoading = false }
            do {
                isLoading = true
                linkedAccounts = []
                try await client.unlinkAccount(linkedAccountID: linkedAccount.id)
                linkedAccounts = try await client.getLinkedAccounts()
            } catch {
                errorMessage = String(describing: error)
            }
        }
    }

    private func getLinkedAccounts(showLoading: Bool = true) async {
        defer { isLoading = false }
        do {
            isLoading = showLoading
            self.linkedAccounts = try await client.getLinkedAccounts()
            isDataStale = false
        } catch {
            errorMessage = String(describing: error)
        }
    }
}

#Preview {
    LinkedAccountsScreen(
        linkedAccounts: .constant([]), isLoading: .constant(false), errorMessage: .constant(nil),
        isDataStale: .constant(false)
    )
    .environment(
        CandleClient(appUser: .init(appKey: "DEBUG_APP_KEY", appSecret: "DEBUG_APP_SECRET")))
}
