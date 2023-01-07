// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioUnit
import AVFoundation
import Audio
import Utilities

public class TapNode: Node {
    public let connections: [Node] = []

    public let avAudioNode: AVAudioNode

    let tapAU: TapAudioUnit

    public init(_ tapBlock: @escaping ([Float], [Float]) async -> Void) {

        let componentDescription = AudioComponentDescription(effect: "tapn")

        AUAudioUnit.registerSubclass(TapAudioUnit.self,
                                     as: componentDescription,
                                     name: "Tap AU",
                                     version: .max)
        avAudioNode = instantiate(componentDescription: componentDescription)
        tapAU = avAudioNode.auAudioUnit as! TapAudioUnit
        tapAU.tapBlock = tapBlock
    }
}

class TapAudioUnit: AUAudioUnit {

    private var inputBusArray: AUAudioUnitBusArray!
    private var outputBusArray: AUAudioUnitBusArray!

    let inputChannelCount: NSNumber = 2
    let outputChannelCount: NSNumber = 2

    let ringBufferL = RingBuffer<Float>()
    let ringBufferR = RingBuffer<Float>()

    var tapBlock: ([Float], [Float]) async -> Void = { _,_  in }
    var semaphore = DispatchSemaphore(value: 0)
    var run = true

    override public var channelCapabilities: [NSNumber]? {
        return [inputChannelCount, outputChannelCount]
    }

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {

        try super.init(componentDescription: componentDescription, options: options)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        inputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [])
        outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [try AUAudioUnitBus(format: format)])

        _ = Thread {
            while true {
                self.semaphore.wait()

                if !self.run {
                    return
                }

                var left = [Float](repeating: 0.0, count: 256)
                var right = [Float](repeating: 0.0, count: 256)

                left.withUnsafeMutableBufferPointer { ptr in
                    _ = self.ringBufferL.pop(to: ptr)
                }

                right.withUnsafeMutableBufferPointer { ptr in
                     _ = self.ringBufferR.pop(to: ptr)
                }

                // XXX: what if we can only pop one channel?
                // gotta interleave

                let left2 = left
                let right2 = right

                Task {
                    await self.tapBlock(left2, right2)
                }
            }
        }
    }

    override var inputBusses: AUAudioUnitBusArray {
        inputBusArray
    }

    override var outputBusses: AUAudioUnitBusArray {
        outputBusArray
    }

    override func allocateRenderResources() throws {}

    override func deallocateRenderResources() {}

    override var internalRenderBlock: AUInternalRenderBlock {

        let ringBufferL = self.ringBufferL
        let ringBufferR = self.ringBufferR
        let semaphore = self.semaphore

        return { (actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
           timeStamp: UnsafePointer<AudioTimeStamp>,
           frameCount: AUAudioFrameCount,
           outputBusNumber: Int,
           outputBufferList: UnsafeMutablePointer<AudioBufferList>,
           renderEvents: UnsafePointer<AURenderEvent>?,
           inputBlock: AURenderPullInputBlock?) in

            let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

            // Better be stereo.
            assert(ablPointer.count == 2)

            // Check that buffers are the correct size.
            if ablPointer[0].frameCapacity < frameCount {
                print("output buffer 1 too small: \(ablPointer[0].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            if ablPointer[1].frameCapacity < frameCount {
                print("output buffer 2 too small: \(ablPointer[1].frameCapacity), expecting: \(frameCount)")
                return kAudio_ParamError
            }

            var inputFlags: AudioUnitRenderActionFlags = []
            _ = inputBlock?(&inputFlags, timeStamp, frameCount, 0, outputBufferList)

            let outBufL = UnsafeBufferPointer<Float>(ablPointer[0])
            let outBufR = UnsafeBufferPointer<Float>(ablPointer[1])

            // We are assuming there is enough room in the ring buffer
            // for the all the samples. If not there's nothing we can do.
            _ = ringBufferL.push(from: outBufL)
            _ = ringBufferR.push(from: outBufR)
            semaphore.signal()

            return noErr
        }
    }

}

