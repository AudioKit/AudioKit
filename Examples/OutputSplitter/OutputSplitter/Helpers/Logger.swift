// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
