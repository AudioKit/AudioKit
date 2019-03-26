//
//  AKAKMIDIFileChunk.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/1/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public protocol AKMIDIFileChunk {
    var typeData: [UInt8] { get set }
    var lengthData: [UInt8] { get set }
    var data: [UInt8] { get set }
    init()
    init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8])
}

extension AKMIDIFileChunk {

    public init(typeData: [UInt8], lengthData: [UInt8], data: [UInt8]) {
        self.init()
        self.typeData = typeData
        self.lengthData = lengthData
        self.data = data
        if !isValid {
            fatalError("Type and length must be 4 bytes long")
        }
    }

    public var isValid: Bool {
        return typeData.count == 4 && lengthData.count == 4 && data.count == combine(bytes: lengthData)
    }

    public var length: Int {
        return combine(bytes: lengthData)
    }

    public var type: MIDIFileChunkType? {
        return MIDIFileChunkType.init(data: typeData)
    }

    public var isHeader: Bool {
        return type == .header
    }

    public var isTrack: Bool {
        return type == .track
    }

    func combine(bytes: [UInt8]) -> Int {
        return Int(bytes.map(String.init).joined()) ?? 0
    }
}

public enum MIDIFileChunkType: String {
    case track
    case header
    
    init?(data: [UInt8]) {
        let text = String(data.map({ Character(UnicodeScalar($0)) }))
        self.init(text: text)
    }

    init?(text: String) {
        if text == MIDIFileChunkType.headerText {
            self = MIDIFileChunkType.header
        } else if text == MIDIFileChunkType.trackText {
            self = MIDIFileChunkType.track
        }
        return nil
    }

    public var text: String {
        switch self {
        case .track:
            return MIDIFileChunkType.trackText
        case .header:
            return MIDIFileChunkType.headerText
        }
    }

    static var headerText = "MThd"
    static var trackText = "MTrk"
}
