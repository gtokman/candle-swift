import Candle
import SwiftUI

struct FiatAccountRow: View {
    let account: Models.PrimaryFiatHoldingAccount

    private var service: String {
        switch account.details {
        case .LinkFiatHoldingAccountDetails(let details):
            return details.service?.name ?? "unknown"
        case .OwnerFiatHoldingAccountDetails(let details):
            return details.service.name
        }
    }

    private var logoURL: URL? {
        switch account.details {
        case .LinkFiatHoldingAccountDetails(let details):
            return details.service?.logoURL ?? URL(fileURLWithPath: "https://candle.fi/error")
        case .OwnerFiatHoldingAccountDetails(let details):
            return details.service.logoURL
        }
    }

    private var balanceText: String {
        switch account.details {
        case .LinkFiatHoldingAccountDetails:
            return "$--.--"
        case .OwnerFiatHoldingAccountDetails(let details):
            return details.availableCashValue.usd
        }
    }

    enum Clipboard {
        static func copy(_ string: String) {
            #if os(iOS)
                UIPasteboard.general.string = string
            #elseif os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(string, forType: .string)
            #endif
        }
    }

    @ViewBuilder
    func copyButton(label: String, text: String) -> some View {
        Button {
            Clipboard.copy(text)
        } label: {
            Label(label, systemImage: "document.on.document.fill")
        }
    }

    var detailItems: [DetailItem] {
        var items: [DetailItem] = [
            .init(
                label: "Nickname",
                value: account.nickname,
                iconName: "person.fill"
            ),
            .init(
                label: "Service Account ID",
                value: account.serviceFiatHoldingAccountID,
                iconName: "barcode"
            ),
            .init(
                label: "Legal Account Kind",
                value: account.legalAccountKind.rawValue,
                iconName: "info.circle"
            ),
            .init(
                label: "Secondary References",
                value: account.secondaryRefs.map {
                    "\($0.linkedAccountID) \($0.serviceFiatHoldingAccountID) \($0.refKind.rawValue)"
                }.joined(separator: ", "),
                iconName: "link"
            ),
        ]

        if let wire = account.wire {
            items.append(
                .init(
                    label: "Wire Routing Number",
                    value: wire.routingNumber,
                    iconName: "arrow.left.arrow.right"
                ))
            items.append(
                .init(
                    label: "Wire Account Number",
                    value: wire.accountNumber,
                    iconName: "creditcard.fill"
                ))
        }

        if let ach = account.ach {
            items.append(
                .init(
                    label: "ACH Account Kind",
                    value: ach.accountKind.rawValue,
                    iconName: "doc.text.fill"
                ))
            items.append(
                .init(
                    label: "ACH Account Number",
                    value: ach.accountNumber,
                    iconName: "creditcard.fill"
                ))
            items.append(
                .init(
                    label: "ACH Routing Number",
                    value: ach.routingNumber,
                    iconName: "arrow.left.arrow.right"
                ))
        }

        switch account.details {
        case .LinkFiatHoldingAccountDetails(let details):
            items.append(
                .init(
                    label: "Ref Kind",
                    value: details.refKind.rawValue,
                    iconName: "tag.fill"
                ))
            items.append(
                .init(
                    label: "Service",
                    value: details.service?.rawValue ?? "unknown",
                    iconName: "line.3.horizontal.decrease.circle"
                ))
        case .OwnerFiatHoldingAccountDetails(let details):
            items.append(
                .init(
                    label: "Ref Kind",
                    value: details.refKind.rawValue,
                    iconName: "tag.fill"
                ))
            items.append(
                .init(
                    label: "Available Cash",
                    value: details.availableCashValue.usd,
                    iconName: "dollarsign.circle.fill"
                ))
            items.append(
                .init(
                    label: "Linked Account ID",
                    value: details.linkedAccountID,
                    iconName: "barcode"
                ))
            items.append(
                .init(
                    label: "Service",
                    value: details.service.rawValue,
                    iconName: "line.3.horizontal.decrease.circle"
                ))
        }

        return items.enumerated().map { (index, item) in
            DetailItem(
                label: item.label,
                value: item.value,
                iconName: item.iconName,
                showBackground: index % 2 == 0
            )
        }
    }

    var body: some View {
        NavigationLink(
            destination:
                DetailView(
                    detailItems: detailItems,
                    title: account.nickname,
                    logoURL: logoURL
                )
        ) {
            ItemRow(
                title: account.nickname,
                subtitle: service,
                value: balanceText,
                logoURL: logoURL
            )
        }
        .contextMenu {
            if let info = account.ach {
                copyButton(
                    label: "ACH Routing Number: \(info.routingNumber)",
                    text: info.routingNumber)
                copyButton(
                    label: "ACH Account Number: \(info.accountNumber)",
                    text: info.accountNumber)
            }
            if let wire = account.wire {
                copyButton(
                    label: "Wire Routing Number: \(wire.routingNumber)", text: wire.routingNumber)
                copyButton(
                    label: "Wire Account Number: \(wire.accountNumber)", text: wire.accountNumber)
            }
        }
    }
}

#Preview {
    FiatAccountRow(
        account: .init(
            serviceFiatHoldingAccountID: UUID().uuidString, nickname: "Savings",
            legalAccountKind: .individual, secondaryRefs: .init(),
            details: .OwnerFiatHoldingAccountDetails(
                .init(
                    refKind: .owner_banking, service: .cashApp, availableCashValue: 324.123,
                    linkedAccountID: UUID().uuidString))))
}
