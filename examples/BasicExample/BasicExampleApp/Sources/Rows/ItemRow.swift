import SwiftUI

struct ItemRow: View {
    let viewModel: ItemViewModel

    var body: some View {
        HStack(spacing: .large) {
            AsyncImageWithPlaceholder(
                logoURL: viewModel.logoURL, size: .init(width: .extraHuge, height: .extraHuge))
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .lineLimit(1)
                    .font(.headline)
                Text(viewModel.subtitle)
                    .font(.subheadline)
            }
            Spacer()
            Text(viewModel.value)
        }
    }
}
