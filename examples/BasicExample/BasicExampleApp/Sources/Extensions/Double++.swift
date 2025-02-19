import Foundation

extension Double {
    var usd: String {
        return self.formatted(.currency(code: "USD"))
    }
}
