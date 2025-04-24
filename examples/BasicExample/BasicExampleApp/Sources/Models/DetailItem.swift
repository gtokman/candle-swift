import Foundation

struct DetailItem {
    let label: String
    let value: String
    let iconName: String  // FIXME: Make this type-safe

    init(label: String, value: String, iconName: String) {
        self.label = label
        self.value = value
        self.iconName = iconName
    }
}

// FIXME: Model [DetailItem] as [String: Omit<DetailItem, 'label'>] so that the compiler guarantees this is a unique ID
extension DetailItem: Identifiable {
    var id: String { label }
}

struct VisualDetailItem {
    let label: String
    let value: String
    let iconName: String  // FIXME: Make this type-safe
    let showBackground: Bool

    fileprivate init(detailItem: DetailItem, showBackground: Bool) {
        self.label = detailItem.label
        self.value = detailItem.value
        self.iconName = detailItem.iconName
        self.showBackground = showBackground
    }
}

extension VisualDetailItem: Identifiable {
    var id: String { label }
}

extension [VisualDetailItem] {
    init(detailItems: [DetailItem]) {
        self = detailItems.enumerated().map {
            VisualDetailItem(detailItem: $0.element, showBackground: $0.offset % 2 == 0)
        }
    }
}
