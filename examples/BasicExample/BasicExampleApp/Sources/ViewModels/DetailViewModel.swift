struct DetailViewModel {
    let label: String
    let value: String
    let iconName: String  // FIXME: Make this type-safe
    let showBackground: Bool

    init(detail: Detail, showBackground: Bool) {
        self.label = detail.label
        self.value = detail.value
        self.iconName = detail.iconName
        self.showBackground = showBackground
    }
}

extension DetailViewModel: Identifiable {
    var id: String { label }
}
