import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    let iconName: String
    let showBackground: Bool

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 17))
                .opacity(0.75)
            Text(label)
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .opacity(0.75)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
                .textSelection(.enabled)
        }
        .padding(.medium)
        .background(
            RoundedRectangle(cornerRadius: .medium, style: .continuous)
                .fill(showBackground ? Color.gray.opacity(0.1) : Color.clear)
        )
        .frame(height: .huge)
    }
}
