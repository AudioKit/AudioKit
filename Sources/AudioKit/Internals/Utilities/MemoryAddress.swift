// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public struct MemoryAddress: CustomStringConvertible {
    let opaquePointerAddress: Int

    public var description: String {
        let size = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(size)p", opaquePointerAddress)
    }

   public  init(of classInstance: AnyObject) {
        opaquePointerAddress = Int(bitPattern: Unmanaged.passUnretained(classInstance).toOpaque())
    }
}
