import Candle
import Foundation

struct TradeViewModel {
    let trade: Models.Trade

    var searchTokens: [String] {
        let counterpartyNames: [String]
        switch trade.counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            counterpartyNames = [merchantCounterparty.name]
        case .ServiceCounterparty:
            counterpartyNames = []
        case .UserCounterparty(let userCounterparty):
            counterpartyNames = [userCounterparty.username, userCounterparty.legalName]
        }

        let lostAssetNames: [String]
        switch trade.lost {
        case .MarketTradeAsset(let marketTradeAsset):
            lostAssetNames = [marketTradeAsset.symbol]  // FIXME: Add name
        case .FiatAsset, .TransportAsset, .OtherAsset, .NothingAsset:
            lostAssetNames = []
        }

        let gainedAssetNames: [String]
        switch trade.gained {
        case .MarketTradeAsset(let marketTradeAsset):
            gainedAssetNames = [marketTradeAsset.symbol]  // FIXME: Add name
        case .FiatAsset, .TransportAsset, .OtherAsset, .NothingAsset:
            gainedAssetNames = []
        }

        return counterpartyNames + lostAssetNames + gainedAssetNames
    }

    var title: String {
        switch trade.counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            return merchantCounterparty.name
        case .UserCounterparty(let userCounterparty):
            return userCounterparty.legalName
        case .ServiceCounterparty(let serviceCounterparty):
            return serviceCounterparty.service.name
        }
    }

    var subtitle: String {
        trade.dateTime.formattedToCustomDate
    }

    var value: String {
        if case .FiatAsset(let fiatAsset) = trade.gained {
            return fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode))
        } else if case .FiatAsset(let fiatAsset) = trade.lost {
            return (-fiatAsset.amount).formatted(.currency(code: fiatAsset.currencyCode))
        } else {
            return "—"
        }
    }

    var logoURL: URL? {
        switch trade.counterparty {
        // FIXME: Log if URLs don't decode (or decode them earlier)
        case .MerchantCounterparty(let merchantCounterparty):
            return URL(string: merchantCounterparty.logoURL)
        case .UserCounterparty(let userCounterparty):
            return URL(string: userCounterparty.avatarURL)
        case .ServiceCounterparty(let serviceCounterparty):
            return serviceCounterparty.service.logoURL
        }
    }

    var detailItems: [DetailItem] {
        let counterpartyDetailItems: [DetailItem]

        switch trade.counterparty {
        case .MerchantCounterparty(let merchantCounterparty):
            let locationDetailItems: [DetailItem]
            if let location = merchantCounterparty.location {
                locationDetailItems = [
                    DetailItem(
                        label: "Country",
                        value: location.countryCode,
                        iconName: "globe"
                    ),
                    DetailItem(
                        label: "Country Subdivision Code",
                        value: location.countrySubdivisionCode,
                        iconName: "mappin.and.ellipse"
                    ),
                    DetailItem(
                        label: "Locality Name",
                        value: location.localityName,
                        iconName: "building.columns"
                    ),
                ]
            } else {
                locationDetailItems = []
            }
            counterpartyDetailItems =
                [
                    DetailItem(
                        label: "Kind",
                        value: merchantCounterparty.kind.rawValue,
                        iconName: "link.circle"
                    ),
                    DetailItem(
                        label: "Name",
                        value: merchantCounterparty.name,
                        iconName: "link.circle"
                    ),
                    DetailItem(
                        label: "Logo URL",
                        value: merchantCounterparty.logoURL,
                        iconName: "link.circle"
                    ),
                ]
                + locationDetailItems.map {
                    DetailItem(
                        label: "Location: " + $0.label, value: $0.value, iconName: $0.iconName)
                }
        case .UserCounterparty(let userCounterparty):
            counterpartyDetailItems = [
                DetailItem(
                    label: "Kind",
                    value: userCounterparty.kind.rawValue,
                    iconName: "person.circle"
                ),
                DetailItem(
                    label: "Username",
                    value: userCounterparty.username,
                    iconName: "person.circle"
                ),
                DetailItem(
                    label: "Legal Name",
                    value: userCounterparty.legalName,
                    iconName: "person.circle"
                ),
                DetailItem(
                    label: "Avatar URL",
                    value: userCounterparty.avatarURL,
                    iconName: "person.circle"
                ),
            ]
        case .ServiceCounterparty(let serviceCounterparty):
            counterpartyDetailItems = [
                DetailItem(
                    label: "Kind",
                    value: serviceCounterparty.kind.rawValue,
                    iconName: "person.circle"
                ),
                DetailItem(
                    label: "Service",
                    value: serviceCounterparty.service.rawValue,
                    iconName: "person.circle"
                ),
            ]
        }

        func detailItems(for tradeAsset: Models.TradeAsset) -> [DetailItem] {
            switch tradeAsset {
            case .FiatAsset(let fiatAsset):
                return [
                    DetailItem(
                        label: "Asset Kind",
                        value: fiatAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    ),
                    DetailItem(
                        label: "Linked Account ID",
                        value: fiatAsset.linkedAccountID,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service",
                        value: fiatAsset.service.rawValue,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service Account ID",
                        value: fiatAsset.serviceAccountID,
                        iconName: "number"
                    ),
                    fiatAsset.serviceTradeID.map {
                        DetailItem(
                            label: "Service Trade ID",
                            value: $0,
                            iconName: "number"
                        )
                    },
                    DetailItem(
                        label: "Amount",
                        value: fiatAsset.amount.formatted(.currency(code: fiatAsset.currencyCode)),
                        iconName: "dollarsign.circle"
                    ),
                ].compactMap { $0 }
            case .MarketTradeAsset(let marketTradeAsset):
                return [
                    DetailItem(
                        label: "Asset Kind",
                        value: marketTradeAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    ),
                    DetailItem(
                        label: "Linked Account ID",
                        value: marketTradeAsset.linkedAccountID,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service",
                        value: marketTradeAsset.service.rawValue,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service Account ID",
                        value: marketTradeAsset.serviceAccountID,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service Trade ID",
                        value: marketTradeAsset.serviceTradeID,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Serivce Asset ID",
                        value: marketTradeAsset.serviceAssetID,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Symbol",
                        value: marketTradeAsset.symbol,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Amount",
                        value: marketTradeAsset.amount.formatted(),
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Color",
                        value: marketTradeAsset.color,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Name",
                        value: marketTradeAsset.name,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Logo URL",
                        value: marketTradeAsset.logoURL,
                        iconName: "number"
                    ),
                ]
            case .TransportAsset(let transportAsset):
                return [
                    DetailItem(
                        label: "Asset Kind",
                        value: transportAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    ),
                    DetailItem(
                        label: "Linked Account ID",
                        value: transportAsset.linkedAccountID,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service",
                        value: transportAsset.service.rawValue,
                        iconName: "number"
                    ),
                    DetailItem(
                        label: "Service Trade ID",
                        value: transportAsset.serviceTradeID,
                        iconName: "number"
                    ),
                ]
            case .NothingAsset(let nothingAsset):
                return [
                    DetailItem(
                        label: "Asset Kind",
                        value: nothingAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    )
                ]
            case .OtherAsset(let otherAsset):
                return [
                    DetailItem(
                        label: "Asset Kind",
                        value: otherAsset.assetKind.rawValue,
                        iconName: "arrow.up.arrow.down.circle"
                    )
                ]
            }
        }

        return [
            DetailItem(
                label: "Date & Time",
                value: trade.dateTime.formattedToCustomDate,
                iconName: "calendar"),
            DetailItem(
                label: "State",
                value: trade.state.rawValue,
                iconName: "list.bullet"),
        ]
            + counterpartyDetailItems.map {
                DetailItem(
                    label: "Counterparty: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
            + detailItems(for: trade.lost).map {
                DetailItem(label: "Lost: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
            + detailItems(for: trade.gained).map {
                DetailItem(label: "Gained: " + $0.label, value: $0.value, iconName: $0.iconName)
            }
    }
}

extension TradeViewModel: Identifiable {
    var id: String { trade.id }
}
