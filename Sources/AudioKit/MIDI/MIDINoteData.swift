// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Struct holding relevant data for MusicTrackManager note events
public struct MIDINoteData: CustomStringConvertible, Equatable {
    /// MIDI Note Number
    public var noteNumber: MIDINoteNumber

    /// MIDI Velocity
    public var velocity: MIDIVelocity

    /// MIDI Channel
    public var channel: MIDIChannel

    /// Note duration
    public var duration: Duration

    /// Note position as a duration from the start
    public var position: Duration

    /// Initialize the MIDI Note Data
    /// - Parameters:
    ///   - noteNumber: MID Note Number
    ///   - velocity: MIDI Velocity
    ///   - channel: MIDI Channel
    ///   - duration: Note duration
    ///   - position: Note position as a duration from the start
    public init(noteNumber: MIDINoteNumber,
                velocity: MIDIVelocity,
                channel: MIDIChannel,
                duration: Duration,
                position: Duration) {
        self.noteNumber = noteNumber
        self.velocity = velocity
        self.channel = channel
        self.duration = duration
        self.position = position
    }

    /// Pretty printout
    public var description: String {
        return """
        note: \(noteNumber)
        velocity: \(velocity)
        channel: \(channel)
        duration: \(duration.beats)
        position: \(position.beats)
        """
    }
}
