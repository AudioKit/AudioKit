//
//  AKAKMIDIFileChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

protocol AKMIDIFileChunk {
    var typeData: [UInt8] { get set }
    var lengthData: [UInt8] { get set }
    var data: [UInt8] { get set }
    init()
    init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8])
}

extension AKMIDIFileChunk {

    init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8]) {
        self.init()
        self.typeData = typeData
        self.lengthData = lengthData
        self.data = data
        if !isValid {
            fatalError("Type and length must be 4 bytes long")
        }
    }

    var isValid: Bool {
        return typeData.count == 4 && lengthData.count == 4 &&
            data.count == combine(bytes: lengthData) && (isHeader || isTrack)
    }

    var length: Int {
        return combine(bytes: lengthData)
    }

    var type: String {
        return String(self.typeData.map({ Character(UnicodeScalar($0)) }))
    }

    var isHeader: Bool {
        return type == "MThd"
    }

    var isTrack: Bool {
        return type == "MTrk"
    }

    func combine(bytes: [UInt8]) -> Int {
        return Int(bytes.map(String.init).joined()) ?? 0
    }
}
