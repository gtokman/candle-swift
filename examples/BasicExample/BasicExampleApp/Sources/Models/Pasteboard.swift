#if os(iOS)
    import UIKit
#endif

enum Pasteboard {
    static func setString(_ string: String) {
        #if os(iOS)
            UIPasteboard.general.string = string
        #elseif os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(string, forType: .string)
        #endif
    }
}
