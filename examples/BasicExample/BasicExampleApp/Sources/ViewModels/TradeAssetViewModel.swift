import Candle

struct TradeAssetViewModel {
    let tradeAsset: Models.TradeAsset

    var detailItems: [DetailItem] {
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
                    label: "Name",
                    value: transportAsset.name,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Description",
                    value: transportAsset.description,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Seats",
                    value: transportAsset.seats.formatted(),
                    iconName: "number"
                ),
                DetailItem(
                    label: "Image URL",
                    value: transportAsset.imageURL,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Service Asset ID",
                    value: transportAsset.serviceAssetID,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Service Trade ID",
                    value: transportAsset.serviceTradeID,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Origin Address",
                    value: transportAsset.originAddress.value,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Origin Coordinates: Latitude",
                    value: transportAsset.originCoordinates.latitude.formatted(),
                    iconName: "number"
                ),
                DetailItem(
                    label: "Origin Coordinates: Longitude",
                    value: transportAsset.originCoordinates.longitude.formatted(),
                    iconName: "number"
                ),
                DetailItem(
                    label: "Destination Address",
                    value: transportAsset.destinationAddress.value,
                    iconName: "number"
                ),
                DetailItem(
                    label: "Destination Coordinates: Latitude",
                    value: transportAsset.destinationCoordinates.latitude.formatted(),
                    iconName: "number"
                ),
                DetailItem(
                    label: "Destination Coordinates: Longitude",
                    value: transportAsset.destinationCoordinates.longitude.formatted(),
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
}
