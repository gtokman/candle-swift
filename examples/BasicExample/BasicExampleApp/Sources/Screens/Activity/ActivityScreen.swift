import Candle
import SwiftUI

struct ActivityScreen: View {

    @Environment(CandleClient.self) private var client

    @State private var errorMessage: String? = nil
    @State private var activityItems = [Models.PortfolioActivityItem]()
    @State private var isLoading = false
    @State private var query: Models.GetActivity.Input.Query = .init()
    @State private var searchText = ""

    let linkedAccounts: [Models.LinkedAccount]

    var filteredActivityItems: [Models.PortfolioActivityItem] {
        guard !searchText.isEmpty else { return activityItems }

        return activityItems.filter { item in
            switch item {
            case .OrderActivityItem(let order):
                return order.name.localizedCaseInsensitiveContains(searchText)
            case .TransactionActivityItem(let transaction):
                return transaction.counterparty.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

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
                    ForEach(filteredActivityItems) { item in
                        switch item {
                        case .OrderActivityItem(let order):
                            NavigationLink(destination: OrderDetails(order: order)) {
                                ItemRow(
                                    title: order.name,
                                    subtitle: order.symbol,
                                    value: order.details.value,
                                    logoURL: URL(string: order.logoURL)
                                )
                            }
                        case .TransactionActivityItem(let transaction):
                            NavigationLink(
                                destination: TransactionDetailsView(transaction: transaction)
                            ) {
                                ItemRow(
                                    title: transaction.counterparty.name,
                                    subtitle: transaction.counterparty.location?.localityName
                                        ?? "No Location",
                                    value: transaction.amount.usd,
                                    logoURL: URL(string: transaction.counterparty.logoURL)
                                )
                            }
                        }
                    }
                }
                .overlay {
                    if filteredActivityItems.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
                .searchable(text: $searchText, prompt: Text("Search by name"))
                .navigationTitle("Activity")
                .refreshable {
                    await loadActivity(query: query, showLoading: false)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            SpanMenu { value in
                                self.query = .init(
                                    linkedAccountIDs: query.linkedAccountIDs,
                                    assetKind: query.assetKind,
                                    span: value
                                )
                            }

                            AssetKindMenu { value in
                                self.query = .init(
                                    linkedAccountIDs: query.linkedAccountIDs,
                                    assetKind: value,
                                    span: query.span
                                )
                            }

                            LinkedAccountsMenu(
                                linkedAccounts: linkedAccounts,
                                errorMessage: $errorMessage
                            ) { value in
                                self.query = .init(
                                    linkedAccountIDs: value,
                                    assetKind: query.assetKind,
                                    span: query.span
                                )
                            }
                        } label: {
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                        }
                    }
                }
            }

        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"), message: Text(errorMessage ?? "No Message"),
                dismissButton: .cancel(Text("OK"), action: { errorMessage = nil }))
        }
        .task(id: query) {
            await loadActivity(query: query)
        }
        .sensoryFeedback(.error, trigger: errorMessage) { $1 != nil }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(.extraLarge)
    }

    private func loadActivity(
        query: Models.GetActivity.Input.Query = .init(), showLoading: Bool = true
    ) async {
        guard !isLoading else { return }
        isLoading = showLoading
        defer { isLoading = false }
        do {
            activityItems = try await client.getActivity(query: query)
        } catch {
            errorMessage = String(describing: error)
        }
    }
}

#Preview {
    ActivityScreen(linkedAccounts: [])
        .environment(
            CandleClient(appUser: .init(appKey: "DEBUG_APP_KEY", appSecret: "DEBUG_APP_SECRET")))
}
