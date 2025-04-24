import Candle
import SwiftUI

struct LinkedAccountViewModel {
    let linkedAccount: Models.LinkedAccount

    var title: String {
        linkedAccount.service.name
    }

    var subtitle: String {
        linkedAccount.activeDetails?.legalName ?? "Inactive"
    }

    var value: String {
        ""  // FIXME: Make value optional
    }

    var logoURL: URL? {
        linkedAccount.service.logoURL
    }

    var detailItems: [DetailItem] {
        let detailsItems: [DetailItem]
        switch linkedAccount.details {
        case .ActiveLinkedAccountDetails(let activeDetails):
            detailsItems = [
                DetailItem(
                    label: "State",
                    value: activeDetails.state.rawValue,
                    iconName: "checkmark.circle"),
                DetailItem(
                    label: "Legal Name",
                    value: activeDetails.legalName,
                    iconName: "person.crop.circle"),
                activeDetails.username.map {
                    DetailItem(
                        label: "Username",
                        value: $0,
                        iconName: "person")
                },
                activeDetails.emailAddress.map {
                    DetailItem(
                        label: "Email Address",
                        value: $0,
                        iconName: "envelope")
                },
                activeDetails.accountOpened.map {
                    DetailItem(
                        label: "Account Opened",
                        value: $0.formattedToCustomDate,
                        iconName: "calendar")
                },
            ].compactMap { $0 }
        case .InactiveLinkedAccountDetails(let inactiveDetails):
            detailsItems = [
                DetailItem(
                    label: "State",
                    value: inactiveDetails.state.rawValue,
                    iconName: "xmark.circle")
            ]
        }

        return [
            DetailItem(
                label: "Linked Account ID",
                value: linkedAccount.linkedAccountID,
                iconName: "link"),
            DetailItem(
                label: "Service User ID",
                value: linkedAccount.serviceUserID,
                iconName: "number"),
            DetailItem(
                label: "Service",
                value: linkedAccount.service.rawValue,
                iconName: "line.3.horizontal.decrease.circle"),
        ]
            + detailsItems.map {
                DetailItem(
                    label: "Details: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
    }
}

extension LinkedAccountViewModel: Identifiable {
    var id: String { linkedAccount.id }
}
