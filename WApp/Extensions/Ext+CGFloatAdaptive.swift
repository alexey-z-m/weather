import UIKit

extension CGFloat {
    static func adaptive(_ iPhone: Self, _ iPad: Self) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGFloat(iPad * (UIScreen.main.bounds.width / 810))
        } else {
            return CGFloat(iPhone * (UIScreen.main.bounds.height / 812))
        }
    }
}

extension UIColor {
    func interpolate(to color: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(
            red: r1 + (r2 - r1) * fraction,
            green: g1 + (g2 - g1) * fraction,
            blue: b1 + (b2 - b1) * fraction,
            alpha: 1
        )
    }
}
extension String {
    func toDate(format: String = "yyyy-MM-dd HH:mm") -> Date? { //"2026-02-20"
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter.date(from: self)
        }
}


extension UIImageView {
    func loadImage(from urlString: String) {
        let fixedURL = urlString.hasPrefix("//") ? "https:" + urlString : urlString
        guard let url = URL(string: fixedURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
