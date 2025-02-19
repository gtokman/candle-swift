import Candle
import SwiftUI

struct AssetKindMenu: View {
    let action: (Models.AssetKind?) -> Void
    @State private var selectedAssetKind: Models.AssetKind?

    var body: some View {
        Menu("Asset Kind") {
            ForEach(Models.AssetKind.allCases, id: \.self) { assetKind in
                Button(action: {
                    let newSelectedAssetKind = (selectedAssetKind == assetKind) ? nil : assetKind
                    self.selectedAssetKind = newSelectedAssetKind
                    action(newSelectedAssetKind)
                }) {
                    Label(
                        assetKind.rawValue.capitalized,
                        systemImage: selectedAssetKind == assetKind || selectedAssetKind == nil
                            ? "checkmark" : "")
                }
            }
        }
    }
}
