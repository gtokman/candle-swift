import Foundation

protocol ItemViewModel {
    var title: String { get }
    var subtitle: String { get }
    var value: String { get }
    var logoURL: URL? { get }
    var details: [Detail] { get }

    mutating func reload() async throws(ItemReloadError)
}

extension ItemViewModel {
    var detailViewModels: [DetailViewModel] {
        details.enumerated().map {
            .init(detail: $0.element, showBackground: $0.offset % 2 == 0)
        }
    }
}
