import Candle

extension Models.OrderDetails {

    var state: String {
        switch self {
        case .OrderEmptyDetails(let empty):
            empty.state.rawValue
        case .OrderValueDetails(let value):
            value.state.rawValue
        }
    }

    var value: String {
        switch self {
        case .OrderEmptyDetails:
            "$--.--"
        case .OrderValueDetails(let value):
            value.value.usd
        }
    }
}
