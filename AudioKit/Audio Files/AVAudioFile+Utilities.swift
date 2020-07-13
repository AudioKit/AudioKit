// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate

public typealias FloatChannelData = [[Float]]

extension AVAudioFile {
    /// Get a 2d array of Floats suitable for passing to AKWaveformLayer or other visualization classes
    public func getWaveformData(with samplesPerPixel: Int) -> FloatChannelData? {
        let totalFrames = AVAudioFrameCount(length)
        let framesPerBuffer: AVAudioFrameCount = totalFrames / AVAudioFrameCount(samplesPerPixel)

        guard let rmsBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat,
                                               frameCapacity: AVAudioFrameCount(framesPerBuffer)) else { return nil }

        let channelCount = Int(processingFormat.channelCount)
        var data = Array(repeating: [Float](zeros: samplesPerPixel), count: channelCount)
        var startFrame: AVAudioFramePosition = 0

        for i in 0 ..< samplesPerPixel {
            do {
                framePosition = startFrame
                try read(into: rmsBuffer, frameCount: framesPerBuffer)

            } catch let err as NSError {
                AKLog("Error: Couldn't read into buffer. \(err)", log: .fileHandling, type: .error)
                return nil
            }

            guard let floatData = rmsBuffer.floatChannelData else { return nil }

            for c in 0 ..< channelCount {
                var rms: Float = 0.0
                vDSP_rmsqv(floatData[c], 1, &rms, vDSP_Length(rmsBuffer.frameLength))
                data[c][i] = rms
            }
            startFrame += AVAudioFramePosition(framesPerBuffer)
        }
        return data
    }
}
