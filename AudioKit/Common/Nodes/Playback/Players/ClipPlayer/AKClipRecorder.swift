//
//  AKClipRecorder.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// A closure that will be called when the clip is finished recording.
/// Result will be an error or a clip. ClipRecording.url is the location
/// of the recording in the temporary diretory, it should be moved or copied
/// from this location within this closure, it will be deleted after.
/// startTime and duration may be different than parameters given in recordClip().
///
public typealias ClipRecordingCompletion = (ClipRecordingResult) -> Void

public struct ClipRecording {
    public let url: URL
    public let startTime: Double
    public let duration: Double
}
public enum ClipRecordingResult {
    case clip(ClipRecording)
    case error(Error)
}

open class AKClipRecorder {

    open var node: AKOutput
    private let timing: AKNodeTiming
    fileprivate var clips = [AKClipRecording]()

    /// Initialize a recorder with a node.
    ///
    /// - Parameter node: The node that audio will be recorded from
    ///
    @objc public init(node: AKOutput) {
        self.node = node
        timing = AKNodeTiming(node: node)
        node.outputNode.installTap(onBus: 0, bufferSize: 256, format: nil, block: self.audioTap)
    }
    deinit {
        node.outputNode.removeTap(onBus: 0)
    }

    /// Starts the internal timeline.
    open func start() {
        start(at: nil)
    }

    /// Starts the internal timeline from audioTime.
    ///
    /// - Parameter audioTime: An time in the audio render context.
    ///
    open func start(at audioTime: AVAudioTime?) {
        if isStarted {
            return
        }
        for clip in clips where clip.endTime <= timing.currentTime {
            finalize(clip: clip, error: ClipRecordingError.timingError)
        }
        timing.start(at: audioTime)
    }

    /// The current time of the internal timeline.  Setting will call stop().
    open var currentTime: Double {
        get { return timing.currentTime }
        set { timing.currentTime = newValue }
    }

    /// Stops internal timeline and finalizes any clips that are recording.
    ///
    /// Will stop immediately, clips may finish recording after stop returns.
    ///
    /// - Parameter completion: a closure that will be called after all clips have benn finalized.
    ///
    open func stop(_ completion: (() -> Void)? = nil) {
        if !isStarted {
            return
        }
        timing.stop()
        for clip in clips {
            finalize(clip: clip, error: nil, completion: completion)
        }
    }

    /// Sets recording end time for any recording clips.
    ///
    /// Playback continues. If clips have an endTime less than endTime, they will be unaffected.
    ///
    /// - Parameters
    ///   - endTime: A time in the timeline that recording clips should end.
    ///   - completion: A closure that will be called after all clips' endTime
    /// has been reached and they have benn finalized.
    ///
    open func stopRecording(endTime: Double? = nil, _ completion: (() -> Void)? = nil) {

        let clipEndTime = endTime ?? currentTime
        guard let completion = completion else {
            for clip in clips {
                clip.endTime = clipEndTime
            }
            return
        }
        if clips.isEmpty {
            completion()
            return
        }
        let group = DispatchGroup()
        for clip in clips {
            group.enter()
            clip.endTime = clipEndTime
            clip.completion = doAfter(completion: clip.completion, action: {
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main, execute: completion)
    }
    private func doAfter(completion: @escaping ClipRecordingCompletion,
                         action: @escaping () -> Void) -> ClipRecordingCompletion {
        return { result in
            completion(result)
            action()
        }
    }

    /// True if there are any clips recording.
    open var isRecording: Bool {
        return !clips.isEmpty
    }

    /// Schedule an audio clip to record.
    ///
    /// Clips are recorded to an audio file in the tmp directory, they are accessed when the
    /// completeion block is called, if no error.
    ///
    /// - Parameters
    ///   - time: A time in the timeline that a clip should start recording, if timeline has
    /// surpassed the clip's start time, the start time will be adjusted.
    ///   - duration: The duration in seconds of the clip to record, will be adjusted if start time
    /// was adjusted.
    ///   - tap: An optional tap to access audio as it's being recorded.
    ///   - completion: A closure that will be called when the clip is finished recording. time and duration may be different in the result.
    ///
    public func recordClip(time: Double = 0,
                           duration: Double = Double.greatestFiniteMagnitude,
                           tap: AVAudioNodeTapBlock? = nil,
                           completion: @escaping ClipRecordingCompletion) throws {

        guard time >= 0, duration > 0, time + duration > timing.currentTime else {
            throw ClipRecordingError.invalidParameters
        }
        let clipRecording = AKClipRecording(start: time,
                                            end: time + duration,
                                            audioFile: nil,
                                            completion: completion)
        clipRecording.tap = tap
        clips.append(clipRecording)
    }

    private func finalize(clip: AKClipRecording, error: Error? = nil, completion: (() -> Void)? = nil) {
        if let index = clips.index(of: clip) {
            clips.remove(at: index)
        }

        guard let audioFile = clip.audioFile, audioFile.length > 0 else {
            clip.completion(ClipRecordingResult.error(error ?? ClipRecordingError.clipIsEmpty))
            completion?()
            return
        }

        let url = audioFile.url

        if clip.audioTimeStart != nil,
            let audioFile = clip.audioFile,
            audioFile.length > 0 {
            let duration = audioFile.duration
            clip.audioFile = nil
            clip.completion(ClipRecordingResult.clip(ClipRecording(url: url, startTime: clip.startTime, duration: duration)))
            completion?()
        } else {
            clip.completion(ClipRecordingResult.error(error ?? ClipRecordingError.timingError))
            completion?()
        }
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch let error {
                AKLog(error)
            }
        }
    }

    // Audio tap that is set on node.
    private func audioTap(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) {
        if !timing.isStarted {
            return
        }
        let timeIn = timing.position(at: audioTime)
        let timeOut = timeIn + Double(buffer.frameLength) / buffer.format.sampleRate
        for clip in clips {
            if clip.startTime < timeOut && clip.endTime > timeIn {
                var adjustedBuffer = buffer
                var adjustedAudioTme = audioTime
                if clip.audioTimeStart == nil {
                    print("clip.startTime \(clip.startTime)")
                    print("timeIn \(timeIn)")
                    clip.startTime = max(clip.startTime, timeIn)
                    print("= ip.startTime \(clip.startTime)")

                    guard let audioTimeStart = timing.audioTime(at: clip.startTime) else {
                        finalize(clip: clip, error: ClipRecordingError.timingError)
                        continue
                    }
                    clip.audioTimeStart = audioTimeStart
                    let timeOffset = clip.startTime - timeIn
                    let sampleOffset = AVAudioFrameCount(timeOffset * buffer.format.sampleRate)
                    if let partial = buffer.copyFrom(startSample: sampleOffset) {
                        adjustedBuffer = partial
                    }
                    adjustedAudioTme = audioTimeStart
                }
                let lastBuffer = timeOut > clip.endTime
                if lastBuffer {
                    let timeLeft = clip.endTime - timeIn
                    let samplesLeft = AVAudioFrameCount(timeLeft * buffer.format.sampleRate)
                    if let partial = buffer.copyTo(count: samplesLeft) {
                        adjustedBuffer = partial
                    }
                }
                do {
                    try clip.record(buffer: adjustedBuffer, audioTime: adjustedAudioTme)
                } catch let error {
                    finalize(clip: clip, error: error)
                }
                if lastBuffer {
                    finalize(clip: clip, error: nil)
                }

            }
        }
    }

}

extension AKClipRecorder: AKTiming {

    public var isStarted: Bool {
        return timing.isStarted
    }

    public func stop() {
        stop(nil)
    }

    public func setPosition(_ position: Double) {
        timing.setPosition(position)
    }

    public func position(at audioTime: AVAudioTime?) -> Double {
        return timing.position(at: audioTime)
    }

    public func audioTime(at position: Double) -> AVAudioTime? {
        return timing.audioTime(at: position)
    }
}

public enum ClipRecordingError: Error, LocalizedError {
    case timingError
    case invalidParameters
    case clipIsEmpty
    case formatError

    public var errorDescription: String? {
        switch self {
        case .timingError:
            return "Timing Error"
        case .invalidParameters:
            return "Invalid Parameters"
        case .clipIsEmpty:
            return "Clip is empty"
        case .formatError:
            return "Invalid format"
        }
    }
}

private class AKClipRecording: Equatable {
    var startTime: Double
    var endTime: Double
    var audioTimeStart: AVAudioTime?
    var audioFile: AKAudioFile?
    var completion: ClipRecordingCompletion
    var tap: AVAudioNodeTapBlock?
    init(start: Double = 0,
         end: Double = Double.greatestFiniteMagnitude,
         audioFile: AKAudioFile? = nil,
         completion: @escaping ClipRecordingCompletion) {

        startTime = start
        endTime = end
        var called = false
        self.completion = { result in
            if called {
                return
            }
            called = true
            completion(result)
        }
        self.audioFile = audioFile
    }
    func record(buffer: AVAudioPCMBuffer, audioTime: AVAudioTime) throws {
        if audioFile == nil {
            let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
            let url = tmp.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf").standardizedFileURL
            guard let fileFormat = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                           sampleRate: buffer.format.sampleRate,
                                           channels: buffer.format.channelCount,
                                           interleaved: true) else {
                                            throw ClipRecordingError.formatError
            }
            audioFile = try AKAudioFile(forWriting: url,
                                        settings: fileFormat.settings,
                                        commonFormat: buffer.format.commonFormat,
                                        interleaved: buffer.format.isInterleaved)
        }
        tap?(buffer, audioTime)
        try audioFile?.write(from: buffer)
    }
    static public func == (a: AKClipRecording, b: AKClipRecording) -> Bool {
        return a === b
    }
}
