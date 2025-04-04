import Candle
import SwiftUI

struct LinkedAccountRow: View {
    let linkedAccount: Models.LinkedAccount

    private func formattedName(_ legalName: String) -> String {
        let components = legalName.split(separator: " ")
        guard let first = components.first, let last = components.last else { return legalName }
        return "\(first.prefix(1)). \(last)"
    }

    private var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var logoURL: URL? {
        linkedAccount.service.logoURL
    }

    var detailItems: [DetailItem] {
        let baseItems: [DetailItem] = [
            DetailItem(
                label: "Linked Account ID",
                value: linkedAccount.linkedAccountID,
                iconName: "link",
                showBackground: true),
            DetailItem(
                label: "Service User ID",
                value: linkedAccount.serviceUserID,
                iconName: "number",
                showBackground: false),
            DetailItem(
                label: "Service",
                value: linkedAccount.service.rawValue,
                iconName: "line.3.horizontal.decrease.circle",
                showBackground: true),
        ]

        let additionalItems: [DetailItem] = {
            if let details = linkedAccount.activeDetails {
                return [
                    DetailItem(
                        label: "State",
                        value: "Active",
                        iconName: "checkmark.circle",
                        showBackground: false),
                    DetailItem(
                        label: "Legal Name",
                        value: details.legalName,
                        iconName: "person.crop.circle",
                        showBackground: true),
                    details.username.map {
                        DetailItem(
                            label: "Username",
                            value: $0,
                            iconName: "person",
                            showBackground: false)
                    },
                    details.emailAddress.map {
                        DetailItem(
                            label: "Email Address",
                            value: $0,
                            iconName: "envelope",
                            showBackground: false)
                    },
                    details.accountOpened.map {
                        DetailItem(
                            label: "Account Opened",
                            value: $0.formattedToCustomDate,
                            iconName: "calendar",
                            showBackground: true)
                    },
                ].compactMap { $0 }
            } else {
                return [
                    DetailItem(
                        label: "State",
                        value: "Inactive",
                        iconName: "xmark.circle",
                        showBackground: false)
                ]
            }
        }()

        return baseItems + additionalItems
    }

    var body: some View {
        NavigationLink(
            destination: DetailView(
                detailItems: detailItems,
                title: linkedAccount.service.name,
                logoURL: logoURL
            )
        ) {
            ItemRow(
                title: formattedName(linkedAccount.activeDetails?.legalName ?? "N/A"),
                subtitle: linkedAccount.service.name,
                value: "",
                logoURL: logoURL
            )
        }
    }
}

#Preview {
    LinkedAccountRow(
        linkedAccount: .init(
            linkedAccountID: UUID().uuidString, service: .cashApp,
            serviceUserID: UUID().uuidString,
            details: .ActiveLinkedAccountDetails(
                .init(
                    accountOpened: "2025-02-07T17:59:31.000Z", username: "Gary",
                    emailAddress: "gary@trycandle.com", legalName: "Gary Tokman"))))
}
