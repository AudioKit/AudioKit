// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

private extension UInt8 {
    init(highNibble: UInt8, lowNibble: UInt8) {
        self = highNibble << 4 + lowNibble & 0x0F
    }
    var highNibble: UInt8 {
        self >> 4
    }
    var lowNibble: UInt8 {
        self & 0x0F
    }
}

// simple convenience struct for creating ump sysex for testing
struct UMPSysex {

    enum UMPType: UInt8 {
        // from Universal MIDI Packet (UMP) Format spec
        case utility = 0            // 1 word
        case system = 1             // 1 word
        case channelVoice1 = 2      // 1 word
        case sysex = 3              // 2 words
        case channelVoice2 = 4      // 2 words
        case data128 = 5            // 4 words
        case reserved6 = 6          // 1 word
        case reserved7 = 7          // 1 word
        case reserved8 = 8          // 2 words
        case reserved9 = 9          // 2 words
        case reserved10 = 10        // 2 words
        case reserved11 = 11        // 3 words
        case reserved12 = 12        // 3 words
        case reserved13 = 13        // 4 words
        case reserved14 = 14        // 4 words
        case reserved15 = 15        // 4 words

        init(_ byte0: UInt8) {
            self = UMPType(rawValue: byte0.highNibble)!
        }
    }

    enum UMPSysexType: UInt8 {
        // from Universal MIDI Packet (UMP) Format spec
        case complete = 0
        case start = 1
        case `continue` = 2
        case end = 3
    }
    struct UMP64 {
        var word0: UInt32 = 0
        var word1: UInt32 = 0
    }
    let umpBigEndian: UMP64

    init(group: UInt8 = 0, type: UMPSysexType, data: [UInt8]) {
        var ump = UMP64()

        let numBytes = min(data.count, 6)
        let dataRange = 2..<2+numBytes

        withUnsafeMutableBytes(of: &ump) {
            $0[0] = .init(highNibble: UMPType.sysex.rawValue, lowNibble: group)
            $0[1] = .init(highNibble: type.rawValue, lowNibble: UInt8(numBytes))
            let buffer = UnsafeMutableRawBufferPointer(rebasing: $0[dataRange])
            buffer.copyBytes(from: data[0..<numBytes])
        }
        self.umpBigEndian = ump
    }

    init(word0: UInt32, word1: UInt32) {
        umpBigEndian = .init(word0: .init(bigEndian:word0),
                             word1: .init(bigEndian:word1))
    }

    var umpType: UMPType {
        withUnsafeBytes(of: umpBigEndian) { UMPType($0[0]) }
    }

    var group: UInt8 {
        withUnsafeBytes(of: umpBigEndian) { $0[0].lowNibble }
    }

    var status: UMPSysexType {
        withUnsafeBytes(of: umpBigEndian) {
            UMPSysexType(rawValue: $0[1].highNibble)!
        }
    }

    var numDataBytes: Int {
        withUnsafeBytes(of: umpBigEndian) { Int($0[1].lowNibble) }
    }

    var dataRange: Range<Int> {
        2..<2+numDataBytes
    }

    var data: [UInt8] {
        withUnsafeBytes(of: umpBigEndian) { .init($0[dataRange]) }
    }

    var word0: UInt32 {
        .init(bigEndian: umpBigEndian.word0)
    }

    var word1: UInt32 {
        .init(bigEndian: umpBigEndian.word1)
    }

    var words: [UInt32] {
        [word0, word1]
    }

    static func sysexComplete(group: UInt8 = 0, data: [UInt8]) -> Self {
        .init(group: group, type: .complete, data: data)
    }

    static func sysexStart(group: UInt8 = 0, data: [UInt8]) -> Self {
        .init(group: group, type: .start, data: data)
    }

    static func sysexContinue(group: UInt8 = 0, data: [UInt8]) -> Self {
        .init(group: group, type: .continue, data: data)
    }

    static func sysexEnd(group: UInt8 = 0, data: [UInt8]) -> Self {
        .init(group: group, type: .end, data: data)
    }
}
