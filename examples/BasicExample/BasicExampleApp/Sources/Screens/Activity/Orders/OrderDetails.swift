import Candle
import SwiftUI

struct OrderDetails: View {
    let order: Models.OrderActivityItem

    var detailItems: [DetailItem] {
        [
            DetailItem(
                label: "Service Order ID",
                value: order.serviceOrderID,
                iconName: "number",
                showBackground: true),
            DetailItem(
                label: "Order Kind",
                value: order.orderKind.rawValue,
                iconName: "tag",
                showBackground: false),
            DetailItem(
                label: "Asset Kind",
                value: order.assetKind.rawValue,
                iconName: "bitcoinsign.circle",
                showBackground: true),
            DetailItem(
                label: "Linked Account ID",
                value: order.linkedAccountID,
                iconName: "link",
                showBackground: false),
            DetailItem(
                label: "Date & Time",
                value: order.dateTime.formattedToCustomDate,
                iconName: "calendar",
                showBackground: true),
            DetailItem(
                label: "Amount",
                value: String(order.amount),
                iconName: "dollarsign.circle",
                showBackground: false),
            DetailItem(
                label: "Details State",
                value: order.details.state,
                iconName: "list.bullet",
                showBackground: true),
            DetailItem(
                label: "Details Value",
                value: order.details.value,
                iconName: "list.bullet",
                showBackground: true),
            DetailItem(
                label: "Symbol",
                value: order.symbol,
                iconName: "chart.bar",
                showBackground: false),
            DetailItem(
                label: "Service Asset ID",
                value: order.serviceAssetID,
                iconName: "barcode",
                showBackground: true),
            DetailItem(
                label: "Service Asset Holding Account ID",
                value: order.serviceAssetHoldingAccountID,
                iconName: "tray.full",
                showBackground: false),
            DetailItem(
                label: "Service",
                value: order.service.rawValue,
                iconName: "line.3.horizontal.decrease.circle",
                showBackground: true),
            DetailItem(
                label: "Color",
                value: order.color,
                iconName: "paintpalette",
                showBackground: false),
            DetailItem(
                label: "Name",
                value: order.name,
                iconName: "person.crop.artframe",
                showBackground: true),
        ]
    }

    var body: some View {
        DetailView(detailItems: detailItems, title: order.name, logoURL: URL(string: order.logoURL))
    }
}

#Preview {
    NavigationView {
        OrderDetails(
            order: .init(
                activityKind: .order,
                serviceOrderID: UUID().uuidString,
                orderKind: .fiat,
                assetKind: .crypto,
                linkedAccountID: UUID().uuidString,
                dateTime: Date().description,
                amount: 200,
                details: .OrderValueDetails(.init(state: .success, value: 2342)),
                symbol: "AAPL",
                serviceAssetID: UUID().uuidString,
                serviceAssetHoldingAccountID: UUID().uuidString,
                service: .robinhood,
                name: "Apple",
                color: "#000000",
                logoURL: "https://candle-stock-images.s3.amazonaws.com/AAPL.png"
            )
        )
    }
}
