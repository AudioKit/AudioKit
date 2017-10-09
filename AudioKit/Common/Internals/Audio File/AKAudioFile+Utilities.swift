//
//  AKAudioFile+Utilities.swift
//  AudioKit
//
//  Created by Laurent Veliscek on 7/4/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKAudioFile {

    /// Returns a silent AKAudioFile with a length set in samples.
    ///
    /// For a silent file of one second, set samples value to 44100...
    ///
    /// - Parameters:
    ///   - samples: the number of samples to generate (equals length in seconds multiplied by sample rate)
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp
    ///   - name: the name of the file without its extension (String).
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    static public func silent(samples: Int64,
                              baseDir: BaseDirectory = .temp,
                              name: String = "") throws -> AKAudioFile {

        if samples < 0 {
            AKLog("ERROR AKAudioFile: cannot create silent AKAUdioFile with negative samples count")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        } else if samples == 0 {
            let emptyFile = try AKAudioFile(writeIn: baseDir, name: name)
            // we return it as a file for reading
            return try AKAudioFile(forReading: emptyFile.url)
        }

        let zeros = [Float](zeros: Int(samples))
        let silentFile = try AKAudioFile(createFileFromFloats: [zeros, zeros], baseDir: baseDir, name: name)

        return try AKAudioFile(forReading: silentFile.url)
    }

    /// Returns the time of the peak of the buffer
    /// - Parameters:
    ///   - pcmBuffer: A valid AVAudioPCMBuffer
    /// - Returns: The time in seconds or 0 if it failed
    static public func findPeak( pcmBuffer: AVAudioPCMBuffer ) -> Double {
        guard pcmBuffer.frameLength > 0 else { return 0 }
        guard let floatData = pcmBuffer.floatChannelData else { return 0 }

        var framePosition = 0
        var position = 0
        var lastPeak: Float = -10_000.0
        let frameLength = 512
        let channelCount = Int(pcmBuffer.format.channelCount)

        while true {
            if position + frameLength >= pcmBuffer.frameLength {
                break
            }
            for channel in 0 ..< channelCount {
                var block = Array(repeating: Float(0), count: frameLength)

                // fill the block with frameLength samples
                for i in 0 ..< block.count {
                    block[i] = floatData[channel][i + position]
                }
                // scan the block
                let peak = AKAudioFile.getPeak(from: block)

                if peak > lastPeak {
                    framePosition = position
                    lastPeak = peak
                }
                position += block.count
            }
        }

        let time = Double(framePosition / pcmBuffer.format.sampleRate)
        return time
    }

    /// return the highest level in the given collection of floats
    static private func getPeak(from buffer: [Float]) -> Float {
        // create variable with very small value to hold the peak value
        var peak: Float = -10_000.0

        for i in 0 ..< buffer.count {
            // store the absolute value of the sample
            let absSample = abs(buffer[i])

            if absSample > peak {
                peak = absSample
            }
        }
        return peak
    }

}
