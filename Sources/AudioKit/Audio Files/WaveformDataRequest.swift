// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

public class AKWaveformDataRequest {
    public private(set) var audioFile: AVAudioFile?

    private let abortWaveformDataQueue = DispatchQueue(label: "WaveformDataRequest.abortWaveformDataQueue",
                                                       attributes: .concurrent)

    private var _abortGetWaveformData: Bool = false
    public var abortGetWaveformData: Bool {
        get { _abortGetWaveformData }
        set {
            abortWaveformDataQueue.async(flags: .barrier) {
                self._abortGetWaveformData = newValue
            }
        }
    }

    public init(audioFile: AVAudioFile) {
        self.audioFile = audioFile
    }

    public init(url: URL) throws {
        self.audioFile = try AVAudioFile(forReading: url)
    }

    deinit {
        AKLog("* { WaveformDataRequest }")
        audioFile = nil
    }

    /// will be returned on the queue you pass in or the global queue
    public func getDataAsync(with samplesPerPixel: Int,
                             queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
                             completionHandler: @escaping ((FloatChannelData?) -> Void)) {
        queue.async {
            completionHandler(self.getData(with: samplesPerPixel))
        }
    }

    public func getData(with samplesPerPixel: Int) -> FloatChannelData? {
        guard let audioFile = audioFile else { return nil }

        // prevent division by zero, + minimum resolution
        let samplesPerPixel = max(64, samplesPerPixel)

        // store the current frame
        let currentFrame = audioFile.framePosition

        let totalFrames = AVAudioFrameCount(audioFile.length)
        var framesPerBuffer: AVAudioFrameCount = totalFrames / AVAudioFrameCount(samplesPerPixel)

        guard let rmsBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                               frameCapacity: AVAudioFrameCount(framesPerBuffer)) else { return nil }

        let channelCount = Int(audioFile.processingFormat.channelCount)
        var data = Array(repeating: [Float](zeros: samplesPerPixel), count: channelCount)

        var startFrame: AVAudioFramePosition = 0

        for i in 0 ..< samplesPerPixel {
            if abortGetWaveformData {
                // return the file to frame is was on previously
                audioFile.framePosition = currentFrame
                abortGetWaveformData = false
                AKLog("* Aborting waveform data get *", type: .error)
                return nil
            }

            do {
                audioFile.framePosition = startFrame
                try audioFile.read(into: rmsBuffer, frameCount: framesPerBuffer)

            } catch let err as NSError {
                AKLog("Error: Couldn't read into buffer. \(err)", log: .fileHandling, type: .error)
                return nil
            }

            guard let floatData = rmsBuffer.floatChannelData else { return nil }

            for channel in 0 ..< channelCount {
                var rms: Float = 0.0
                vDSP_rmsqv(floatData[channel], 1, &rms, vDSP_Length(rmsBuffer.frameLength))
                data[channel][i] = rms
            }

            startFrame += AVAudioFramePosition(framesPerBuffer)

            if startFrame + AVAudioFramePosition(framesPerBuffer) > totalFrames {
                framesPerBuffer = totalFrames - AVAudioFrameCount(startFrame)
                if framesPerBuffer <= 0 { break }
            }
        }

        // return the file to frame is was on previously
        audioFile.framePosition = currentFrame

        return data
    }

    public func cancel() {
        abortGetWaveformData = true
    }
}
