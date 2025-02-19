import Candle

extension Models.LinkedAccount {
    var activeDetails: Models.ActiveLinkedAccountDetails? {
        switch self.details {
        case .ActiveLinkedAccountDetails(let value):
            return value
        case .InactiveLinkedAccountDetails:
            return nil
        }
    }
}
