import Foundation
import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat? = nil) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        if hexSanitized.count == 6 {
            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)
            let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            let blue = CGFloat(rgb & 0xFF) / 255.0
            let finalAlpha = alpha ?? 1.0
            self.init(red: red, green: green, blue: blue, alpha: finalAlpha)
        } else {
            self.init(white: 0.0, alpha: 1.0)
        }
    }
}

