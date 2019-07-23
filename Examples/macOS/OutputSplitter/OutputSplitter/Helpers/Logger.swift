//
//  Logger.swift
//  OutputSplitter
//
//  Created by Romans Kisils on 26/11/2018.
//  Copyright © 2018 Roman Kisil. All rights reserved.
//

import Foundation

@discardableResult
func checkErr(_ err : @autoclosure () -> OSStatus, file: String = #file, line: Int = #line) -> OSStatus! {
    let error = err()
    if (error != noErr) {
        print("Error: \(error) ->  \(file):\(line)\n")
        return error
    }

    return nil
}
