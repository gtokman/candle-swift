import Candle
import SwiftUI

struct AssetAccountViewModel {
    let assetAccount: Models.AssetAccount

    var title: String {
        assetAccount.nickname
    }

    var subtitle: String {
        switch assetAccount.details {
        case .FiatAccountDetails(let fiatAccountDetails):
            return fiatAccountDetails.service.name
        case .MarketAccountDetails(let marketAccountDetails):
            return marketAccountDetails.service.name
        }
    }

    var value: String {
        switch assetAccount.details {
        case .FiatAccountDetails(let fiatAccountDetails):
            fiatAccountDetails.balance?.formatted(.currency(code: fiatAccountDetails.currencyCode))
                ?? "N/A"
        case .MarketAccountDetails(let marketAccountDetails):
            // FIXME: Expose other information
            marketAccountDetails.assetKind.rawValue
        }
    }

    var logoURL: URL? {
        switch assetAccount.details {
        case .FiatAccountDetails(let fiatAccountDetails):
            return fiatAccountDetails.service.logoURL
        case .MarketAccountDetails(let marketAccountDetails):
            return marketAccountDetails.service.logoURL
        }
    }

    var detailItems: [DetailItem] {
        let detailsItems: [DetailItem]
        switch assetAccount.details {
        case .FiatAccountDetails(let fiatAccountDetails):
            let wireItems =
                fiatAccountDetails.wire.map { wire -> [DetailItem] in
                    [
                        .init(
                            label: "Routing Number",
                            value: wire.routingNumber,
                            iconName: "arrow.left.arrow.right"
                        ),
                        .init(
                            label: "Account Number",
                            value: wire.accountNumber,
                            iconName: "creditcard.fill"
                        ),
                    ]
                } ?? []

            let achItems =
                fiatAccountDetails.ach.map { ach -> [DetailItem] in
                    [
                        .init(
                            label: "Account Kind",
                            value: ach.accountKind.rawValue,
                            iconName: "doc.text.fill"
                        ),
                        .init(
                            label: "Account Number",
                            value: ach.accountNumber,
                            iconName: "creditcard.fill"
                        ),
                        .init(
                            label: "Routing Number",
                            value: ach.routingNumber,
                            iconName: "arrow.left.arrow.right"
                        ),
                    ]
                } ?? []

            detailsItems =
                [
                    .init(
                        label: "Asset Kind",
                        value: fiatAccountDetails.assetKind.rawValue,
                        iconName: "info.circle"
                    ),
                    .init(
                        label: "Service Account ID",
                        value: fiatAccountDetails.serviceAccountID,
                        iconName: "barcode"
                    ),
                    // FIXME: Display currencyCode regardless (or don't return it?)
                    fiatAccountDetails.balance.map {
                        .init(
                            label: "Balance",
                            value: $0.formatted(
                                .currency(code: fiatAccountDetails.currencyCode)),
                            iconName: "info.circle"
                        )
                    },
                    .init(
                        label: "Linked Account ID",
                        value: fiatAccountDetails.linkedAccountID,
                        iconName: "info.circle"
                    ),
                    .init(
                        label: "Service",
                        value: fiatAccountDetails.service.rawValue,
                        iconName: "info.circle"
                    ),
                    //                .init(
                    //                    label: "Secondary References",
                    //                    value: account.secondaryRefs.map {
                    //                        "\($0.linkedAccountID) \($0.serviceFiatHoldingAccountID) \($0.refKind.rawValue)"
                    //                    }.joined(separator: ", "),
                    //                    iconName: "link"
                    //                ),
                ].compactMap { $0 }
                + wireItems.map {
                    DetailItem(
                        label: "Wire: " + $0.label, value: $0.value, iconName: $0.iconName)
                }
                + achItems.map {
                    DetailItem(
                        label: "ACH: " + $0.label, value: $0.value, iconName: $0.iconName)
                }
        case .MarketAccountDetails(let marketAccountDetails):
            detailsItems = [
                .init(
                    label: "Asset Kind",
                    value: marketAccountDetails.assetKind.rawValue,
                    iconName: "info.circle"
                ),
                .init(
                    label: "Service Account ID",
                    value: marketAccountDetails.serviceAccountID,
                    iconName: "barcode"
                ),
                .init(
                    label: "Linked Account ID",
                    value: marketAccountDetails.linkedAccountID,
                    iconName: "info.circle"
                ),
            ]
        }
        return [
            .init(
                label: "Nickname",
                value: assetAccount.nickname,
                iconName: "person.fill"
            ),
            .init(
                label: "Legal Account Kind",
                value: assetAccount.legalAccountKind.rawValue,
                iconName: "info.circle"
            ),
        ]
            + detailsItems.map {
                DetailItem(
                    label: "Details: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
    }

}

extension AssetAccountViewModel: Identifiable {
    var id: String { assetAccount.id }
}
