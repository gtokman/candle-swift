import SwiftUI

struct SpanMenu: View {

    enum AvailableSpan: String, CaseIterable, Identifiable {
        case pt3h = "PT3H"
        case pt6h = "PT6H"
        case pt12h = "PT12H"
        case p1d = "P1D"
        case p7d = "P7D"
        case p1m = "P1M"
        case p6m = "P6M"
        case p1y = "P1Y"
        case all = "All"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .pt3h: return "3 Hours"
            case .pt6h: return "6 Hours"
            case .pt12h: return "12 Hours"
            case .p1d: return "1 Day"
            case .p7d: return "7 Days"
            case .p1m: return "1 Month"
            case .p6m: return "6 Months"
            case .p1y: return "1 Year"
            case .all: return "All Time"
            }
        }
    }

    @State var selectedSpan: AvailableSpan? = .p1d
    let action: (String?) -> Void

    var body: some View {
        Menu("Span") {
            ForEach(AvailableSpan.allCases) { span in
                Button(action: {
                    let newSelectedSpan = span == .all ? nil : span
                    self.selectedSpan = newSelectedSpan
                    action(newSelectedSpan?.rawValue)
                }) {
                    Label(span.title, systemImage: selectedSpan == span ? "checkmark" : "")
                }
            }
        }
    }
}
