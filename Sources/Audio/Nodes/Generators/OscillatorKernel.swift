// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioUnit
import CoreAudio
import Foundation
import Utilities

class OscillatorKernel {
    var bypassed = false

    private var currentPhase: Double = 0.0

    /// Pitch in Hz
    private var frequency: AUValue = 440

    private var amplitude: AUValue = 1

    private var table = Vec<Float>(count: 0, { _ in 0.0 })

    var sampleRate = 44100.0

    func processEvents(events: UnsafePointer<AURenderEvent>?) {
        process(events: events,
                sysex: { event in
                    var command: TestOscillatorCommand = .table(nil)

                    decodeSysex(event, &command)
                    switch command {
                        case let .table(ptr):
                            table = ptr?.pointee ?? Vec<Float>(count: 0, { _ in 0.0 })
                    }
                }, param: { event in
                    let paramEvent = event.pointee
                    switch paramEvent.parameterAddress {
                        case 0: frequency = paramEvent.value
                        case 1: amplitude = paramEvent.value
                        default: break
                    }
                })
    }

    func render(frameCount: AUAudioFrameCount, outputBufferList: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus {
        let ablPointer = UnsafeMutableAudioBufferListPointer(outputBufferList)

        if bypassed {
            for buffer in ablPointer {
                buffer.clear()
            }
            return noErr
        }

        let twoPi: Double = .init(2 * Double.pi)
        let phaseIncrement = (twoPi / Double(sampleRate)) * Double(frequency)
        for frame in 0 ..< Int(frameCount) {
            // Get signal value for this frame at time.
            let index = Int(currentPhase / twoPi * Double(table.count))
            let value = table[index] * amplitude

            // Advance the phase for the next frame.
            currentPhase += phaseIncrement
            if currentPhase >= twoPi { currentPhase -= twoPi }
            if currentPhase < 0.0 { currentPhase += twoPi }
            // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
            for buffer in ablPointer {
                let buf = UnsafeMutableBufferPointer<Float>(buffer)
                assert(frame < buf.count)
                buf[frame] = value
            }
        }

        return noErr
    }
}
