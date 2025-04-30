import SwiftUI

struct ItemScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: ItemViewModel
    @State var itemReloadError: ItemReloadError? = nil

    var body: some View {
        ScrollView {
            Spacer(minLength: .extraLarge)
            AsyncImageWithPlaceholder(
                logoURL: viewModel.logoURL, size: .init(width: 72, height: 72))

            Spacer(minLength: .extraLarge)

            VStack(alignment: .leading, spacing: .small) {
                ForEach(viewModel.detailViewModels) { detailViewModel in
                    DetailRow(viewModel: detailViewModel)
                }
            }
            .padding(.horizontal, .extraLarge)
        }
        .navigationTitle(viewModel.title)
        .refreshable {
            do throws(ItemReloadError) {
                try await viewModel.reload()
            } catch {
                itemReloadError = error
            }
        }
        .alert(isPresented: .constant(itemReloadError != nil)) {
            Alert(
                title: itemReloadError.map { Text($0.title) } ?? Text("N/A"),
                message: itemReloadError.map { Text($0.description) },
                dismissButton: .cancel(Text("OK"), action: { itemReloadError = nil }))
        }
    }
}
