import Foundation

struct DetailItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let iconName: String
    let showBackground: Bool

    init(label: String, value: String, iconName: String, showBackground: Bool = false) {
        self.label = label
        self.value = value
        self.iconName = iconName
        self.showBackground = showBackground
    }
}
