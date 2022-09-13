// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CoreAudio

let twoPi = 2 * Float.pi

/// Pure Swift oscillator
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public class PlaygroundOscillator: Node {
    fileprivate lazy var sourceNode = AVAudioSourceNode { [self] _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

        if self.isStarted {
            let phaseIncrement = (twoPi / Float(Settings.sampleRate)) * self.frequency
            for frame in 0 ..< Int(frameCount) {
                // Get signal value for this frame at time.
                let index = Int(self.currentPhase / twoPi * Float(self.waveform!.count))
                let value = self.waveform![index] * self.amplitude

                // Advance the phase for the next frame.
                self.currentPhase += phaseIncrement
                if self.currentPhase >= twoPi { self.currentPhase -= twoPi }
                if self.currentPhase < 0.0 { self.currentPhase += twoPi }
                // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = value
                }
            }
        } else {
            for frame in 0 ..< Int(frameCount) {
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = 0
                }
            }
        }
        return noErr
    }

    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { sourceNode }

    private var currentPhase: Float = 0

    fileprivate var waveform: Table?

    /// Pitch in Hz
    public var frequency: Float = 440

    /// Volume usually 0-1
    public var amplitude: AUValue = 1

    /// Initialize the pure Swift oscillator, suitable for Playgrounds
    /// - Parameters:
    ///   - waveform: Shape of the oscillator waveform
    ///   - frequency: Pitch in Hz
    ///   - amplitude: Volume, usually 0-1
    public init(waveform: Table = Table(.sine), frequency: AUValue = 440, amplitude: AUValue = 1) {
        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude

        stop()
    }
}
