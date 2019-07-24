//
//  RingBuffer.swift
//  WaveLabs
//
//  Created by Vlad Gorlov on 31.05.16.
//  Copyright © 2016 WaveLabs. All rights reserved.
//  Modified by Roman Kisil on 20.01.18

import CoreAudio

// region MARK: - Supporting Definitions

// Next power of two greater or equal to x
private func nextPowerOfTwo(_ value: UInt32) -> UInt32 {
    // TODO: Performance optimization required. See: http://stackoverflow.com/questions/466204/rounding-up-to-nearest-power-of-2
    var power: UInt32 = 1
    while power < value {
        power *= 2
    }
    return power
}

public typealias SampleTime = Int64

private let kGeneralRingTimeBoundsQueueSize: UInt32 = 32
private let kGeneralRingTimeBoundsQueueMask: Int32 = Int32(kGeneralRingTimeBoundsQueueSize) - 1

private struct RingBufferTimeBounds {
    var mStartTime: SampleTime = 0
    var mEndTime: SampleTime = 0
    var mUpdateCounter: UInt32 = 0
}

public enum RingBufferError: Int32 {
    case noError = 0
    /// Fetch start time is earlier than buffer start time and fetch end time is later than buffer end time
    case tooMuch = 3
    /// The reader is unable to get enough CPU cycles to capture a consistent snapshot of the time bounds
    case CPUOverload = 4
}

// endregion

public final class RingBuffer<T> {

    fileprivate var mTimeBoundsQueue = ContiguousArray<RingBufferTimeBounds>(repeating: RingBufferTimeBounds(),
                                                                               count: Int(kGeneralRingTimeBoundsQueueSize))
    fileprivate var mTimeBoundsQueueCurrentIndex: Int32 = 0

    public var numberOfChannels: UInt32 {
        return mNumberChannels
    }

    fileprivate let mNumberChannels: UInt32
    // FIXME: Rename it and make public.
    /// Per channel capacity, must be a power of 2.
    fileprivate let mCapacityFrames: UInt32
    /// Used to for index calculation.
    fileprivate let mCapacityFramesMask: UInt32
    fileprivate let mCapacityBytes: UInt32
    fileprivate let mBytesPerFrame: UInt32
    /// Number of allocated elements in buffer for all channels.
    fileprivate let mBuffersLength: UInt32
    fileprivate let mBuffer: UnsafeMutablePointer<T>
    /// Buffer pointer just for debug purpose.
    fileprivate var mBufferPointer: UnsafeMutableBufferPointer<T> {
        return UnsafeMutableBufferPointer(start: mBuffer, count: Int(mBuffersLength))
    }

    /// Buffer array just for debug purpose.
    fileprivate var mBufferArray: [T] {
        return Array(mBufferPointer)
    }

    /// **Note** CapacityFrames will be rounded up to a power of 2
    /// - parameter numberOfChannels: Number of channels (non-interleaved).
    /// - parameter capacityFrames: Capacity per every channel.
    public init(numberOfChannels: UInt32, capacityFrames: UInt32) {
        mNumberChannels = numberOfChannels
        mCapacityFrames = nextPowerOfTwo(capacityFrames)
        mCapacityFramesMask = mCapacityFrames - 1
        mBuffersLength = mCapacityFrames * numberOfChannels
        mBuffer = UnsafeMutablePointer<T>.allocate(capacity: Int(mBuffersLength))
        mBytesPerFrame = UInt32(MemoryLayout<T>.stride)
        mCapacityBytes = mBytesPerFrame * mCapacityFrames
    }

    deinit {
        mBuffer.deallocate()
    }
}

extension RingBuffer {

    /// Copy framesToWrite of data into the ring buffer at the specified sample time.
    /// The sample time should normally increase sequentially, though gaps
    /// are filled with zeroes. A sufficiently large gap effectively empties
    /// the buffer before storing the new data.
    /// If startWrite is less than the previous frame number, the behavior is undefined.
    /// Return false for failure (buffer not large enough).
    /// - parameter abl: Source AudioBufferList.
    /// - parameter framesToWrite: Frames to write.
    /// - parameter startWrite: Absolute time.
    /// - returns: Operation status code.
    public func store(_ abl: UnsafePointer<AudioBufferList>, framesToWrite: UInt32, startWrite: SampleTime) -> RingBufferError {
        return store(framesToWrite: framesToWrite, startWrite: startWrite) { [unowned self] srcOffset, destOffset, numberOfBytes in
            self.storeABL(self.mBuffer, destOffset: destOffset, abl: abl, srcOffset: srcOffset, numberOfBytes: numberOfBytes)
        }
    }

    public func fetch(_ abl: UnsafeMutablePointer<AudioBufferList>, framesToRead: UInt32,
                      startRead: SampleTime) -> RingBufferError {
        return fetch(framesToRead: framesToRead, startRead: startRead, zeroProcedure: { destOffset, numberOfBytes in
            zeroABL(abl, destOffset: destOffset, nbytes: numberOfBytes)
        }) { srcOffset, destOffset, numberOfBytes in
            fetchABL(abl, destOffset: destOffset, buffers: mBuffer, srcOffset: srcOffset, nbytes: numberOfBytes)
        }
    }
}

extension RingBuffer {

    fileprivate typealias StoreProcedure = (_ srcOffset: SampleTime, _ destOffset: SampleTime, _ numberOfBytes: SampleTime) -> Void
    fileprivate typealias FetchProcedure = (_ srcOffset: SampleTime, _ destOffset: SampleTime, _ numberOfBytes: SampleTime) -> Void
    fileprivate typealias ZeroProcedure = (_ destOffset: SampleTime, _ numberOfBytes: SampleTime) -> Void

    fileprivate func frameOffset(_ frameNumber: SampleTime) -> SampleTime {
        return (frameNumber & SampleTime(mCapacityFramesMask)) * SampleTime(mBytesPerFrame)
    }

    fileprivate func store(framesToWrite: UInt32, startWrite: SampleTime, storeProcedure: StoreProcedure) -> RingBufferError {
        if framesToWrite == 0 {
            return .noError
        }

        if framesToWrite > mCapacityFrames {
            return .tooMuch
        }

        let endWrite = startWrite + SampleTime(framesToWrite)
        if startWrite < endTime() {
            // going backwards, throw everything out
            setTimeBounds(startTime: startWrite, endTime: startWrite)
        } else if endWrite - startTime() <= SampleTime(mCapacityFrames) {
            // the buffer has not yet wrapped and will not need to
        } else {
            // advance the start time past the region we are about to overwrite
            let newStart = endWrite - SampleTime(mCapacityFrames) // one buffer of time behind where we're writing
            let newEnd = max(newStart, endTime())
            setTimeBounds(startTime: newStart, endTime: newEnd)
        }

        let curEnd = endTime()
        var offset0: SampleTime
        var offset1: SampleTime
        var nbytes: SampleTime
        if startWrite > curEnd {
            // we are skipping some samples, so zero the range we are skipping
            offset0 = frameOffset(curEnd)
            offset1 = frameOffset(startWrite)
            if offset0 < offset1 {
                zeroBuffer(offset: offset0, nbytes: offset1 - offset0)
            } else {
                zeroBuffer(offset: offset0, nbytes: SampleTime(mCapacityBytes) - offset0)
                zeroBuffer(offset: 0, nbytes: offset1)
            }
            offset0 = offset1
        } else {
            offset0 = frameOffset(startWrite)
        }

        offset1 = frameOffset(endWrite)
        if offset0 < offset1 {
            storeProcedure(0, offset0, offset1 - offset0)
        } else {
            nbytes = SampleTime(mCapacityBytes) - offset0
            storeProcedure(0, offset0, nbytes)
            storeProcedure(nbytes, 0, offset1)
        }

        // now update the end time
        setTimeBounds(startTime: startTime(), endTime: endWrite)

        return .noError
    }

    fileprivate func fetch(framesToRead: UInt32, startRead: SampleTime, zeroProcedure: ZeroProcedure,
                           fetchProcedure: FetchProcedure) -> RingBufferError {
        if framesToRead == 0 {
            return .noError
        }

        var startRead = max(0, startRead)

        var endRead = startRead + Int64(framesToRead)

        let startRead0 = startRead
        let endRead0 = endRead

        let err = clipTimeBounds(startRead: &startRead, endRead: &endRead)
        if err != .noError {
            return err
        }

        if startRead == endRead {
            zeroProcedure(0, Int64(framesToRead * mBytesPerFrame))
            return .noError
        }

        let byteSize = (endRead - startRead) * Int64(mBytesPerFrame)

        let destStartByteOffset = max(0, (startRead - startRead0) * Int64(mBytesPerFrame))

        if destStartByteOffset > 0 {
            zeroProcedure(0, min(Int64(framesToRead * mBytesPerFrame), destStartByteOffset))
        }

        let destEndSize = max(0, endRead0 - endRead)
        if destEndSize > 0 {
            zeroProcedure(destStartByteOffset + byteSize, destEndSize * Int64(mBytesPerFrame))
        }

        let offset0 = frameOffset(startRead)
        let offset1 = frameOffset(endRead)
        var nbytes: SampleTime = 0

        if offset0 < offset1 {
            nbytes = offset1 - offset0
            fetchProcedure(offset0, destStartByteOffset, nbytes)
        } else {
            nbytes = Int64(mCapacityBytes) - offset0
            fetchProcedure(offset0, destStartByteOffset, nbytes)
            fetchProcedure(0, destStartByteOffset + nbytes, offset1)
            nbytes += offset1
        }

        // FIXME: Do we really need to update mDataByteSize?.
        //      let ablPointer = UnsafeMutableAudioBufferListPointer(abl)
        //      for channel in 0..<ablPointer.count {
        //         var dest = ablPointer[channel]
        //         if dest.mData != nil {
        // FIXME: This should be in sync with AVAudioPCMBuffer (Vlad Gorlov, 2016-06-12).
        //            dest.mDataByteSize = UInt32(nbytes)
        //         }
        //      }

        return .noError
    }

    fileprivate func storeABL(_ buffers: UnsafeMutablePointer<T>, destOffset: SampleTime, abl: UnsafePointer<AudioBufferList>,
                              srcOffset: SampleTime, numberOfBytes: SampleTime) {

        let advanceOfSource = Int(srcOffset) / Int(mBytesPerFrame)
        let advanceOfDestination = Int(destOffset) / Int(mBytesPerFrame)
        let ablPointer = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer<AudioBufferList>(mutating: abl))
        let numberOfChannels = max(ablPointer.count, Int(mNumberChannels))
        for channel in 0 ..< numberOfChannels {
            guard channel < Int(mNumberChannels) else { // Ring buffer has less channels than input buffer
                continue
            }
            let positionWrite = buffers.advanced(by: advanceOfDestination + channel * Int(mCapacityFrames))
            if channel < ablPointer.count {
                let channelBuffer = ablPointer[channel]
                assert(channelBuffer.mNumberChannels == 1) // Supporting non interleaved channels at the moment
                if srcOffset > Int64(channelBuffer.mDataByteSize) {
                    continue
                }
                guard let channelBufferData = channelBuffer.mData else {
                    continue
                }
                let channelData = channelBufferData.assumingMemoryBound(to: T.self)
                let positionRead = channelData.advanced(by: advanceOfSource)
                let numberOfBytes = min(Int(numberOfBytes), Int(channelBuffer.mDataByteSize) - Int(srcOffset))
                memcpy(positionWrite, positionRead, numberOfBytes)
            } else {
                memset(positionWrite, 0, Int(numberOfBytes))
            }
        }
    }

    fileprivate func fetchABL(_ abl: UnsafeMutablePointer<AudioBufferList>, destOffset: SampleTime,
                              buffers: UnsafeMutablePointer<T>, srcOffset: SampleTime, nbytes: SampleTime) {

        let advanceOfSource = Int(srcOffset) / Int(mBytesPerFrame)
        let advanceOfDestination = Int(destOffset) / Int(mBytesPerFrame)
        let ablPointer = UnsafeMutableAudioBufferListPointer(abl)
        let numberOfChannels = ablPointer.count
        for channel in 0 ..< numberOfChannels {
            let channelBuffer = ablPointer[channel]
            assert(channelBuffer.mNumberChannels == 1) // Supporting non interleaved channels at the moment
            if destOffset > Int64(channelBuffer.mDataByteSize) {
                continue
            }
            guard let channelBufferData = channelBuffer.mData else {
                continue
            }
            let channelData = channelBufferData.assumingMemoryBound(to: T.self)
            let positionWrite = channelData.advanced(by: advanceOfDestination)
            let numberOfBytes = min(Int(nbytes), Int(channelBuffer.mDataByteSize) - Int(destOffset))
            if channel < Int(mNumberChannels) { // Ring buffer has less channels than output buffer
                let positionRead = buffers.advanced(by: advanceOfSource + channel * Int(mCapacityFrames))
                memcpy(positionWrite, positionRead, numberOfBytes)
            } else {
                memset(positionWrite, 0, numberOfBytes)
            }
        }
    }

    fileprivate func zeroABL(_ abl: UnsafeMutablePointer<AudioBufferList>, destOffset: SampleTime, nbytes: SampleTime) {
        let advanceDistance = Int(destOffset) / Int(mBytesPerFrame)
        let ablPointer = UnsafeMutableAudioBufferListPointer(abl)
        let numberOfChannels = ablPointer.count
        for channel in 0 ..< numberOfChannels {
            let channelBuffer = ablPointer[channel]
            assert(channelBuffer.mNumberChannels == 1) // Supporting non interleaved channels at the moment
            if destOffset > Int64(channelBuffer.mDataByteSize) {
                continue
            }
            guard let channelBufferData = channelBuffer.mData else {
                continue
            }
            let channelData = channelBufferData.assumingMemoryBound(to: T.self)
            let positionWrite = channelData.advanced(by: advanceDistance)
            let numberOfBytes = min(Int(nbytes), Int(channelBuffer.mDataByteSize) - Int(destOffset))
            memset(positionWrite, 0, numberOfBytes)
        }
    }

    fileprivate func zeroBuffer(offset: SampleTime, nbytes: SampleTime) {
        let advanceDistance = Int(offset) / Int(mBytesPerFrame)
        assert(UInt32(offset + nbytes) <= mCapacityBytes)
        for channel in 0 ..< mNumberChannels {
            let positionWrite = mBuffer.advanced(by: advanceDistance + Int(channel * mCapacityFrames))
            memset(positionWrite, 0, Int(nbytes))
        }
    }
}

// region MARK: - Time Bounds Queue
extension RingBuffer {

    fileprivate func setTimeBounds(startTime: SampleTime, endTime: SampleTime) {
        let nextAbsoluteIndex = mTimeBoundsQueueCurrentIndex + 1 // Always increasing
        // Index always in range [0, kGeneralRingTimeBoundsQueueSize - 1]
        let elementIndex = Int(nextAbsoluteIndex & kGeneralRingTimeBoundsQueueMask)
        mTimeBoundsQueue[elementIndex].mStartTime = startTime
        mTimeBoundsQueue[elementIndex].mEndTime = endTime
        mTimeBoundsQueue[elementIndex].mUpdateCounter = UInt32(nextAbsoluteIndex)

        let status = OSAtomicCompareAndSwap32Barrier(mTimeBoundsQueueCurrentIndex, nextAbsoluteIndex,
                                                     &mTimeBoundsQueueCurrentIndex)
        assert(status)
    }

    public func getTimeBounds(startTime: inout SampleTime, endTime: inout SampleTime) -> RingBufferError {
        // Fail after a few tries.
        for _ in 0 ..< 8 {
            let curPtr = mTimeBoundsQueueCurrentIndex
            let index = curPtr & kGeneralRingTimeBoundsQueueMask
            let bounds = mTimeBoundsQueue[Int(index)]

            startTime = bounds.mStartTime
            endTime = bounds.mEndTime
            let newPtr = Int32(bounds.mUpdateCounter)

            if newPtr == curPtr {
                return .noError
            }
        }
        return .CPUOverload
    }
}

extension RingBuffer {

    /// **Note!** Should only be called from Store.
    /// - returns: Start time from the Time bounds queue at current index.
    fileprivate func startTime() -> SampleTime {
        return mTimeBoundsQueue[Int(mTimeBoundsQueueCurrentIndex & kGeneralRingTimeBoundsQueueMask)].mStartTime
    }

    /// **Note!** Should only be called from Store.
    /// - returns: End time from the Time bounds queue at current index.
    fileprivate func endTime() -> SampleTime {
        return mTimeBoundsQueue[Int(mTimeBoundsQueueCurrentIndex & kGeneralRingTimeBoundsQueueMask)].mEndTime
    }

    fileprivate func clipTimeBounds(startRead: inout SampleTime, endRead: inout SampleTime) -> RingBufferError {
        var startTime: SampleTime = 0
        var endTime: SampleTime = 0

        let err = getTimeBounds(startTime: &startTime, endTime: &endTime)
        if err != .noError {
            return err
        }

        if startRead > endTime || endRead < startTime {
            endRead = startRead
            return .noError
        }

        startRead = max(startRead, startTime)
        endRead = min(endRead, endTime)
        endRead = max(endRead, startRead)

        return .noError
    }
}

// endregion
