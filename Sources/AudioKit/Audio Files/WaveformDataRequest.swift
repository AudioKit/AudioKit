// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

/// Request to get data out of an audio file
public class WaveformDataRequest {
    /// Audio file get data from
    public private(set) var audioFile: AVAudioFile?

    private let abortWaveformDataQueue = DispatchQueue(label: "WaveformDataRequest.abortWaveformDataQueue",
                                                       attributes: .concurrent)

    private var _abortGetWaveformData: Bool = false
    /// Should we abort the waveform data
    public var abortGetWaveformData: Bool {
        get { _abortGetWaveformData }
        set {
            abortWaveformDataQueue.async(flags: .barrier) {
                self._abortGetWaveformData = newValue
            }
        }
    }

    /// Initialize with audio file
    /// - Parameter audioFile: AVAudioFile to start with
    public init(audioFile: AVAudioFile) {
        self.audioFile = audioFile
    }

    /// Initialize with URL
    /// - Parameter url: URL of audio file
    /// - Throws: Error if URL doesn't point to an audio file
    public init(url: URL) throws {
        audioFile = try AVAudioFile(forReading: url)
    }

    deinit {
        Log("* { WaveformDataRequest }")
        audioFile = nil
    }

    /// Get waveform data asynchronously
    /// - Parameters:
    ///   - samplesPerPixel: Number of samples you want per point
    ///   - offset: optional start offset to retrieve samples (default 0 : from 0, nil or minus : from currentFrame)
    ///   - length: optional length of retrieve samples (default is full length or remains)
    ///   - queue: Optional dispatch Queue to use, defaults to global user initiated queue
    ///   - completionHandler: Code to call when the process is done
    public func getDataAsync(with samplesPerPixel: Int,
                             offset: Int? = 0,
                             length: UInt? = nil,
                             queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
                             completionHandler: @escaping ((FloatChannelData?) -> Void))
    {
        queue.async {
            completionHandler(self.getData(with: samplesPerPixel, offset: offset, length: length))
        }
    }

    /// Get waveform data
    /// - Parameters:
    ///   - samplesPerPixel: Number of samples you want per point
    ///   - offset: optional start offset to retrieve samples (default 0 : from 0, nil or minus : from currentFrame)
    ///   - length: optional length of retrieve samples (default is full length or remains)
    /// - Returns: An array of array of floats, one for each channel
    public func getData(with samplesPerPixel: Int,
                        offset: Int? = 0,
                        length: UInt? = nil) -> FloatChannelData?
    {
        guard let audioFile = audioFile else { return nil }

        // prevent division by zero, + minimum resolution
        let samplesPerPixel = max(64, samplesPerPixel)

        // store the current frame
        let currentFrame = audioFile.framePosition

        let totalFrameCount = AVAudioFrameCount(audioFile.length)
        var framesPerBuffer: AVAudioFrameCount = totalFrameCount / AVAudioFrameCount(samplesPerPixel)

        guard let rmsBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                               frameCapacity: AVAudioFrameCount(framesPerBuffer)) else { return nil }

        let channelCount = Int(audioFile.processingFormat.channelCount)
        var data = Array(repeating: [Float](zeros: samplesPerPixel), count: channelCount)

        var start: Int
        if let offset = offset, offset >= 0 {
            start = offset
        } else {
            // offset == nil or minus case. read from the currentFrame
            start = Int(currentFrame / Int64(framesPerBuffer))
            if let offset = offset, offset < 0 {
                start += offset
            }
            // check start offset
            if start < 0 {
                start = 0
            }
        }
        var startFrame: AVAudioFramePosition = offset == nil ? currentFrame : Int64(start * Int(framesPerBuffer))

        var end = samplesPerPixel
        if let length = length {
            end = start + Int(length)
        }
        // check end
        if end > samplesPerPixel {
            end = samplesPerPixel
        }
        if start > end {
            Log("offset is larger than total length.")
            return nil
        }

        for i in start ..< end {
            if abortGetWaveformData {
                // return the file to frame is was on previously
                audioFile.framePosition = currentFrame
                abortGetWaveformData = false
                Log("* Aborting waveform data get *", type: .error)
                return nil
            }

            do {
                audioFile.framePosition = startFrame
                try audioFile.read(into: rmsBuffer, frameCount: framesPerBuffer)

            } catch let err as NSError {
                Log("Error: Couldn't read into buffer. \(err)", log: .fileHandling, type: .error)
                return nil
            }

            guard let floatData = rmsBuffer.floatChannelData else { return nil }

            for channel in 0 ..< channelCount {
                var rms: Float = 0.0
                vDSP_rmsqv(floatData[channel], 1, &rms, vDSP_Length(rmsBuffer.frameLength))
                data[channel][i] = rms
            }

            startFrame += AVAudioFramePosition(framesPerBuffer)

            if startFrame + AVAudioFramePosition(framesPerBuffer) > totalFrameCount {
                framesPerBuffer = totalFrameCount - AVAudioFrameCount(startFrame)
                if framesPerBuffer <= 0 { break }
            }
        }

        // return the file to frame is was on previously
        audioFile.framePosition = currentFrame

        return data
    }

    /// Abort getting the waveform data
    public func cancel() {
        abortGetWaveformData = true
    }
}
