import Foundation

extension String {
    /// Converts an ISO8601 date string (with fractional seconds) into a custom format.
    /// Expected input: "2023-12-12T15:13:09.296-05:00"
    /// Desired output example: "Dec 12, 2023 5:10pm"
    var formattedToCustomDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: self) else { return self }
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        outputFormatter.dateFormat = "MMM dd, yyyy h:mma Z"
        outputFormatter.amSymbol = "AM"
        outputFormatter.pmSymbol = "PM"
        return outputFormatter.string(from: date)
    }
}
