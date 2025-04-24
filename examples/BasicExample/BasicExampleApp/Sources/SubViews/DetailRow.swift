import SwiftUI

struct DetailRowView: View {
    let visualDetailItem: VisualDetailItem

    var body: some View {
        HStack {
            Image(systemName: visualDetailItem.iconName)
                .font(.system(size: 17))
                .opacity(0.75)
            Text(visualDetailItem.label)
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .opacity(0.75)
            Spacer()
            Text(visualDetailItem.value)
                .font(.subheadline)
                .foregroundColor(.gray)
                .textSelection(.enabled)
        }
        .padding(.medium)
        .background(
            RoundedRectangle(cornerRadius: .medium, style: .continuous)
                .fill(visualDetailItem.showBackground ? Color.gray.opacity(0.1) : Color.clear)
        )
        .frame(height: .huge)
    }
}
