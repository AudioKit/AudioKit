import AVFoundation

public extension AudioBuffer {
    func clear() {
        bzero(mData, Int(mDataByteSize))
    }

    var frameCapacity: AVAudioFrameCount {
        mDataByteSize / UInt32(MemoryLayout<Float>.size)
    }
}
