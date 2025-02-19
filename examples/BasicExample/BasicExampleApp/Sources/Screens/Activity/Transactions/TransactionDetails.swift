import Candle
import SwiftUI

struct TransactionDetailsView: View {

    let transaction: Models.TransactionActivityItem

    var detailItems: [DetailItem] {
        var items: [DetailItem] = [
            DetailItem(
                label: "Activity Kind",
                value: transaction.activityKind.rawValue,
                iconName: "arrow.up.arrow.down.circle"
            ),
            DetailItem(
                label: "Service Transaction ID",
                value: transaction.serviceTransactionID,
                iconName: "number"
            ),
            DetailItem(
                label: "Date & Time",
                value: transaction.dateTime.formattedToCustomDate,
                iconName: "clock"
            ),
            DetailItem(
                label: "State",
                value: transaction.state.rawValue,
                iconName: "flag.fill"
            ),
            DetailItem(
                label: "Amount",
                value: transaction.amount.usd,
                iconName: "dollarsign.circle"
            ),
            DetailItem(
                label: "Service",
                value: transaction.service.rawValue,
                iconName: "line.3.horizontal.decrease.circle"
            ),
            DetailItem(
                label: "Counterparty Name",
                value: transaction.counterparty.name,
                iconName: "person.circle"
            ),
            DetailItem(
                label: "Logo URL",
                value: transaction.counterparty.logoURL,
                iconName: "person.circle"
            ),
        ]

        if let location = transaction.counterparty.location {
            items.append(contentsOf: [
                DetailItem(
                    label: "Country",
                    value: location.countryCode,
                    iconName: "globe"
                ),
                DetailItem(
                    label: "Country Subdivision",
                    value: location.countrySubdivisionCode,
                    iconName: "mappin.and.ellipse"
                ),
                DetailItem(
                    label: "Locality Name",
                    value: location.localityName,
                    iconName: "building.columns"
                ),
            ])
        }

        items.append(
            DetailItem(
                label: "Linked Account ID",
                value: transaction.linkedAccountID,
                iconName: "link.circle"
            )
        )
        return items.enumerated().map { (index, item) in
            .init(
                label: item.label,
                value: item.value,
                iconName: item.iconName,
                showBackground: index % 2 == 0
            )
        }
    }

    var body: some View {
        DetailView(
            detailItems: detailItems, title: transaction.counterparty.name,
            logoURL: URL(string: transaction.counterparty.logoURL))
    }
}

#Preview {
    NavigationStack {
        TransactionDetailsView(
            transaction: .init(
                activityKind: .transaction,
                serviceTransactionID: UUID().uuidString,
                dateTime: Date().description,
                state: .success,
                amount: 400,
                counterparty: .init(
                    name: "Blue Bottle",
                    location: .init(
                        countryCode: "US",
                        countrySubdivisionCode: "NY",
                        localityName: "New York"
                    ),
                    logoURL: "https://institution-logos.s3.us-east-1.amazonaws.com/robinhood.png"
                ),
                linkedAccountID: UUID().uuidString,
                service: .robinhood
            )
        )
    }
}
