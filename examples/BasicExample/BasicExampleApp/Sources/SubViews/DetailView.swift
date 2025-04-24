import SwiftUI

struct DetailsView: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    let logoURL: URL?
    let detailItems: [DetailItem]

    var visualDetailItems: [VisualDetailItem] {
        .init(detailItems: detailItems)
    }

    var body: some View {
        ScrollView {
            Spacer(minLength: .extraLarge)
            AsyncImageWithPlaceholder(logoURL: logoURL, size: .init(width: 72, height: 72))

            Spacer(minLength: .extraLarge)

            VStack(alignment: .leading, spacing: .small) {
                ForEach(visualDetailItems) { visualDetailItem in
                    DetailRowView(visualDetailItem: visualDetailItem)
                }
            }
            .padding(.horizontal, .extraLarge)
        }
        .navigationTitle(title)
    }
}

#Preview {
    DetailsView(
        title: "Thing",
        logoURL: .init(string: "https://institution-logos.s3.useast-1.amazonaws.com/cash_app.png"),
        detailItems: [
            .init(label: "Kind", value: "thing", iconName: "checkmark"),
            .init(label: "Kind", value: "thing", iconName: "checkmark"),
        ]
    )
}
