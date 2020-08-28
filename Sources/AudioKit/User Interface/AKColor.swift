// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS) || targetEnvironment(macCatalyst)
import Foundation
import UIKit

extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage / 100, 1.0),
                           green: min(g + percentage / 100, 1.0),
                           blue: min(b + percentage / 100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
}

#endif
