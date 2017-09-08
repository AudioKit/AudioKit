//
//  AKClip.swift
//  AudioKit
//
//  Created by David O'Neill on 6/9/17.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// A protocol containing timing information for scheduling audio clips in a timeline.  All 
/// properties are time values in seconds, relative to a zero based timeline.
@objc public protocol AKClip: class {

    /// The time in the timeline that the clip should begin playing.
    var time: Double { get }

    /// The offset into the clip's audio (where to start playing from within the clip).
    var offset: Double { get }

    /// The duration of playback.
    var duration: Double { get }
}

extension AKClip {

    /// Returns true is overlaps other clip.
    public func overlaps(_ otherClip: AKClip) -> Bool {
        return time < otherClip.endTime && endTime > otherClip.time
    }

    /// Default implementation is very basic.  Implementers of AKClip should implement this 
    /// to ensure that enough information is available to ensure playback (eg. source file exists)
    public var isValid: Bool {
        return time >= 0 &&
            offset >= 0 &&
            duration > 0
    }

    /// Convenience to get clip end time.
    public var endTime: Double {
        return time + duration
    }
}

/// A file based AKClip
@objc public protocol FileClip: AKClip {
    var audioFile: AKAudioFile { get }
}

/// A FileClip implementation, used by AKClipPlayer.
open class AKFileClip: NSObject, FileClip {

    /// The audio file that will be read.
    open var audioFile: AKAudioFile

    /// The time in the timeline that the clip should begin playing.
    open var time: Double

    /// The offset into the clip's audio (where to start playing from within the clip).
    open var offset: Double

    /// The duration of playback.
    open var duration: Double

    /// Create a new file clip.
    ///
    /// - Parameters:
    ///   - audioFile: The audio file that will be read.
    ///   - time: The time in the timeline that the clip should begin playing.
    ///   - offset: The offset into the clip's audio (where to start playing from within the clip).
    ///   - duration: The duration of playback.
    ///
    public init(audioFile: AKAudioFile,
                time: Double = 0,
                offset: Double = 0,
                duration: Double = 0) {

        self.audioFile = audioFile
        self.time = time
        self.offset = offset
        self.duration = duration == 0 ? audioFile.duration : duration
    }

    /// Init a file clip from a url with time and offset at zero, and duration set to file duration.
    public convenience init?(url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        do {
            let audioFile = try AKAudioFile(forReading: url)
            self.init(audioFile: audioFile)
            return
        } catch {
            print(error)
        }
        return nil
    }

}
