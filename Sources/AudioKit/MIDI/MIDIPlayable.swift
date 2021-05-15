// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import CAudioKit

// TODO: think of a different name. This may be confusing with MIDIPlayer
/// A protocol for start and stop with MIDI notes
protocol MIDIPlayable {
    /// Start a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to play
    ///   - velocity:   Velocity at which to play the note (0 - 127)
    ///   - channel:    Channel on which to play the note
    ///
    func start(noteNumber: MIDINoteNumber,
               velocity: MIDIVelocity,
               channel: MIDIChannel,
               timeStamp: MIDITimeStamp?)
    
    /// Stop a note
    ///
    /// - Parameters:
    ///   - noteNumber: Note number to stop
    ///   - channel:    Channel on which to stop the note
    ///
    func stop(noteNumber: MIDINoteNumber,
              channel: MIDIChannel,
              timeStamp: MIDITimeStamp?)
}

