// STEP 1: Import Candle (Visit App.swift for Pre-requisites) or docs (https://docs.candle.fi/quick-start)
import Candle
import SwiftUI

struct ContentView: View {
    @Environment(CandleClient.self) private var client

    @AppStorage("showOnboarding", store: .standard) var showOnboarding = true

    // STEP 2: Create state to show link sheet
    @State var showLinkSheet = false
    @State var showTrades = false
    @State var showAssetAccounts = false
    @State var showTradeQuotes = false
    @State var showDeleteConfirmation = false
    @State var linkedAccounts: [Models.LinkedAccount] = []
    @State var isDataStale = true

    @State var errorMessage: String? = nil
    @State var isLoading = true

    @ViewBuilder
    func actionButtons() -> some View {
        Button(
            action: { showAssetAccounts = true },
            label: {
                Text("Get Asset Accounts")
                    .candleSecondaryButtonStyle()
            })
        Button(
            action: { showTrades = true },
            label: {
                Text("Get Trades")
                    .candleSecondaryButtonStyle()
            })
        Button(
            action: { showTradeQuotes = true },
            label: {
                Text("Get Trade Quotes")
                    .candleSecondaryButtonStyle()
            })
    }

    var body: some View {
        NavigationStack {
            LinkedAccountsScreen(
                linkedAccounts: $linkedAccounts,
                isLoading: $isLoading,
                errorMessage: $errorMessage,
                isDataStale: $isDataStale
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ContentViewMenu(
                        showOnboarding: $showOnboarding,
                        showDeleteConfirmation: $showDeleteConfirmation
                    )
                }
            }
            Spacer()
            VStack(spacing: .mediumPlus) {
                // STEP 3: Show link sheet on action
                Button(action: { showLinkSheet = true }) {
                    Text("Link Account")
                        .candlePrimaryButtonStyle(color: Color(.candlePrimary))
                }
                #if DEBUG
                    actionButtons()
                #else
                    if linkedAccounts.count > 0 {
                        actionButtons()
                    }
                #endif
            }
            .animation(.bouncy(duration: 0.33), value: linkedAccounts)
            .padding([.horizontal, .bottom], .extraLarge)
        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"), message: Text(errorMessage ?? "No Message"),
                dismissButton: .cancel(Text("OK"), action: { errorMessage = nil }))
        }
        .confirmationDialog(
            "Delete User?", isPresented: $showDeleteConfirmation, titleVisibility: .visible
        ) {
            Button("Delete User", role: .destructive, action: { deleteUser() })
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Proceed with caution! This action is permanent and cannot be reverted.")
        }
        .sheet(isPresented: $showAssetAccounts) {
            AssetAccountsScreen(linkedAccounts: linkedAccounts)
        }
        .sheet(isPresented: $showTrades) {
            TradesScreen(linkedAccounts: linkedAccounts)
        }
        .fullScreenCover(isPresented: $showTradeQuotes) {
            TradeQuotesScreen(linkedAccounts: linkedAccounts)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingScreen(
                photos: [
                    .init(resource: .link1),
                    .init(resource: .link7),
                    .init(resource: .link2),
                    .init(resource: .link6),
                    .init(resource: .link3),
                    .init(resource: .link4),
                    .init(resource: .link5),
                ],
                title: "Welcome to",
                product: "Candle",
                caption: "Explore the functionality of the Candle SDK",
                ctaText: "Get Started"
            ) {
                showOnboarding = false
            }
        }
        // STEP 4: Link sheet is presented and and a onChange callback will contain the newly linked account model
        .candleLinkSheet(
            isPresented: $showLinkSheet,
            customerName: "Acme Inc.",
            services: .supported + [.sandbox],
            presentationStyle: .fullScreen,
            presentationBackground: AnyShapeStyle(.thickMaterial)
        ) { account in
            // STEP 5: 🎉
            self.isDataStale = true
        }
        .sensoryFeedback(.selection, trigger: showOnboarding)
        .sensoryFeedback(.selection, trigger: showAssetAccounts)
        .sensoryFeedback(.selection, trigger: showTrades)
    }

    private func deleteUser() {
        Task {
            defer { isLoading = false }
            do {
                isLoading = true
                try await client.deleteUser()
                linkedAccounts = try await client.getLinkedAccounts()
            } catch {
                errorMessage = String(describing: error)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            CandleClient(appUser: .init(appKey: "DEBUG_APP_KEY", appSecret: "DEBUG_APP_SECRET")))
}
