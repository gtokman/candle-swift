import SwiftUI

struct DetailRow: View {
    let viewModel: DetailViewModel

    var body: some View {
        HStack {
            Image(systemName: viewModel.iconName)
                .font(.system(size: 17))
                .opacity(0.75)
            Text(viewModel.label)
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .opacity(0.75)
            Spacer()
            Text(viewModel.value)
                .font(.subheadline)
                .foregroundColor(.gray)
                .textSelection(.enabled)
        }
        .padding(.medium)
        .background(
            RoundedRectangle(cornerRadius: .medium, style: .continuous)
                .fill(viewModel.showBackground ? Color.gray.opacity(0.1) : Color.clear)
        )
        .frame(height: .huge)
    }
}
