// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

class Time {
    static var unix: Int {
        get {
            return Int(Date().timeIntervalSince1970 * 1_000)
        }
    }
}
