//
//  Time.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 01/12/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation

class Time {
    static var unix: Int {
        get {
            return Int(Date().timeIntervalSince1970 * 1_000)
        }
    }
}
