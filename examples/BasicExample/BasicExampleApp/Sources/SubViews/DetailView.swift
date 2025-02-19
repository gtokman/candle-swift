import SwiftUI

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme

    let detailItems: [DetailItem]
    let title: String
    let logoURL: URL?

    var body: some View {
        ScrollView {
            Spacer(minLength: .extraLarge)
            AsyncImageWithPlaceholder(logoURL: logoURL, size: .init(width: 72, height: 72))

            Spacer(minLength: .extraLarge)

            VStack(alignment: .leading, spacing: .small) {
                ForEach(detailItems) { item in
                    DetailRow(
                        label: item.label,
                        value: item.value,
                        iconName: item.iconName,
                        showBackground: item.showBackground
                    )
                }
            }
            .padding(.horizontal, .extraLarge)
        }
        .navigationTitle(title)
    }
}

#Preview {
    DetailView(
        detailItems: [
            .init(label: "Kind", value: "thing", iconName: "checkmark", showBackground: true),
            .init(label: "Kind", value: "thing", iconName: "checkmark", showBackground: false),
        ], title: "Thing",
        logoURL: .init(string: "https://institution-logos.s3.useast-1.amazonaws.com/cash_app.png"))
}
