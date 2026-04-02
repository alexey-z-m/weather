import Foundation

extension String {
    func toDate(format: String = "yyyy-MM-dd HH:mm") -> Date? { //"2026-02-20"
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter.date(from: self)
        }
}
