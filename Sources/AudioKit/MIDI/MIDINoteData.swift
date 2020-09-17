// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Struct holding revelant data for MusicTrackManager note events
public struct MIDINoteData: CustomStringConvertible, Equatable {
    public var noteNumber: MIDINoteNumber
    public var velocity: MIDIVelocity
    public var channel: MIDIChannel
    public var duration: Duration
    public var position: Duration

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
