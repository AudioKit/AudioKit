// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit
import AVFoundation

/// Sampler's Audio Unit - not yet converted to an internal AU
extension AudioUnitBase {

    /// Assign a note number to a particular frequency
    /// - Parameters:
    ///   - noteNumber: MIDI Note number
    ///   - frequency: Frequency in Hertz
    public func setNoteFrequency(noteNumber: Int32, noteFrequency: Float) {
        akSamplerSetNoteFrequency(dsp, noteNumber, noteFrequency)
    }

    /// Create a simple key map
    public func buildSimpleKeyMap() {
        akSamplerBuildSimpleKeyMap(dsp)
    }

    /// Build key map
    public func buildKeyMap() {
        akSamplerBuildKeyMap(dsp)
    }

    /// Set Loop
    /// - Parameter thruRelease: Wether or not to loop before or after the release
    public func setLoop(thruRelease: Bool) {
        akSamplerSetLoopThruRelease(dsp, thruRelease)
    }

    /// Play the sampler
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity: Velocity of the note
    ///   - channel: MIDI Channel
    public func playNote(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        akSamplerPlayNote(dsp, noteNumber, velocity)
    }

    /// Stop the sampler playback of a specific note
    /// - Parameter noteNumber: MIDI Note number
    public func stopNote(noteNumber: MIDINoteNumber, immediate: Bool) {
        akSamplerStopNote(dsp, noteNumber, immediate)
    }

    /// Activate the sustain pedal
    /// - Parameter pedalDown: Wether the pedal is down (activated)
    public func sustainPedal(down: Bool) {
        akSamplerSustainPedal(dsp, down)
    }
}
