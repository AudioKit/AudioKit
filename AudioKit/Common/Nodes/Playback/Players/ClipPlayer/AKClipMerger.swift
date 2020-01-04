//
//  AKClipMerger.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2017 Audive Inc. All rights reserved.
//

/// The protocol for the AKClipMerger's delegate
/// It is the responsibility of the delegate to create a new clip when a an existing clip
/// has been altered or split.
@objc public protocol ClipMergeDelegate: AnyObject {

    /// A new clip, derived from an existing clip, with specified values.
    ///
    /// - Parameters:
    ///   - clip: The existing clip that the new clip should be derived from.
    ///   - time: The newly created clip's time.
    ///   - offset: The newly created clip's time.
    ///   - duration: The newly created clip's time.
    ///
    /// - Return A newly created clip with time, offset, and duration set to provided values.
    ///
    @objc func newClip(from clip: AKClip, time: Double, offset: Double, duration: Double) -> AKClip?

    /// Called when an existing clip will be removed as a result of merging in a new clip.
    @objc optional func clipWillBeRemoved(_ clip: AKClip)
}

public enum ClipMergeError: Error {
    case clipInvalid
    case clipsOverlap
}

/// AKClipMerger merges new clips into an existing array of validated clips and returns a
/// new array of validated clips including the new clip.
///
/// ## Validation rules:
/// - The clip itself must be valid as defined by the clip's isValid function.
/// - The clips in the array must not overlap each other (clip.time + clip.duration <= nextClip.time).
///
/// The strategy used when a new clip overlaps an existing clip is last-in precedence.  Existing
/// clips will shortened, split, or removed in order to make room for the new clip.  Since clips
/// can be split or removed, merging a clip may result in the clip count decreasing when a clip is
/// merged, or increasing by more than 1.  This behavior requires that the clip merger create clips,
/// so to facilitate this need it uses a delegate.  When a clip is to be shortened, it is removed
/// from the existing clips, and a new clip is created using the delegate's newClip function.  When
/// a clip is to be split, the original is removed and newClip will be called twice.  When a clip is
/// removed, the delegate's clipWillBeRemoved function will be called (if implemented).
///
open class AKClipMerger: NSObject {

    /// The delegate used for clip editing and creation.
    open weak var mergeDelegate: ClipMergeDelegate?

    /// Creates a validated array of clips with the new clip merged into an array of validated clips.
    /// - Parameters:
    ///   - clip: The clip to be merged
    ///   - clips: A validated clip array.
    ///
    /// - Returns: A validated array of clips containing the new clip merged with clips.
    ///
    @objc open func merge(clip: AKClip, clips: [AKClip]) -> [AKClip] {

        guard clip.isValid else {
            AKLog("AudioSequence.add - clip invalid")
            return clips
        }
        var merged = [clip]
        for existingClip in clips {
            if clip.overlaps(existingClip) {
                let overlapsBeginning = clip.time <= existingClip.time
                let overlapsEnd = clip.endTime >= existingClip.endTime
                let overlapsMiddle = !overlapsBeginning && !overlapsEnd

                if overlapsBeginning && overlapsEnd {
                    mergeDelegate?.clipWillBeRemoved?(existingClip)
                    continue
                }

                if overlapsBeginning || overlapsMiddle {
                    let diff = clip.endTime - existingClip.time
                    let time = existingClip.time + diff
                    let offset = existingClip.offset + diff
                    let duration = existingClip.duration - diff

                    if let editedClip = mergeDelegate?.newClip(from: existingClip,
                                          time: time,
                                          offset: offset,
                                          duration: duration) {
                        if editedClip.isValid &&
                            editedClip.time == time &&
                            editedClip.offset == offset &&
                            editedClip.duration == duration {
                            merged.append(editedClip)
                        } else {
                            AKLog("mergeDelegate not setting correct values, existing clip was removed")
                        }
                    } else {
                        AKLog(mergeDelegate == nil ? "No mergeDelegate" : " No clip returned from mergeDelegate")
                    }
                }
                if overlapsEnd || overlapsMiddle {

                    let time = existingClip.time
                    let offset = existingClip.offset
                    let duration = clip.time - existingClip.time

                    if let editedClip = mergeDelegate?.newClip(from: existingClip,
                                                               time: time,
                                                               offset: offset,
                                                               duration: duration) {
                        if editedClip.isValid &&
                            editedClip.time == time &&
                            editedClip.offset == offset &&
                            editedClip.duration == duration {
                            merged.append(editedClip)
                        } else {
                            AKLog("mergeDelegate not setting correct values, existing clip was removed")
                        }
                    } else {
                        AKLog(mergeDelegate == nil ? "No mergeDelegate" : " No clip returned from mergeDelegate")
                    }
                }
            } else {
                merged.append(existingClip)
            }
        }
        merged.sort { (a, b) -> Bool in
            a.time < b.time
        }
        return merged
    }

    /// Validate an array of clips
    /// - Parameter clips: An array of clips to be validated.
    /// - Returns: The input array un-altered if valid.
    /// - Throws: ClipMergeError if clips are not valid.
    ///
    open class func validateClips(_ clips: [AKClip]) throws -> [AKClip] {

        let sorted = clips.sorted { (a, b) -> Bool in
            return a.time < b.time
        }
        var lastEndTime: Double = 0
        for clip in sorted {
            if clip.isValid == false {
                throw ClipMergeError.clipInvalid
            }
            if clip.time < lastEndTime {
                throw ClipMergeError.clipsOverlap
            }

            lastEndTime = clip.endTime
        }
        return sorted
    }
}

/// A class that manages the merging of AKFileClips.
open class AKFileClipSequence: NSObject, ClipMergeDelegate {

    /// Clip merger delegate function
    @objc open func newClip(from clip: AKClip, time: Double, offset: Double, duration: Double) -> AKClip? {
        guard let oldClip = clip as? AKFileClip else {
            return nil
        }
        return AKFileClip(audioFile: oldClip.audioFile, time: time, offset: offset, duration: duration)
    }

    // The internal clip merger.
    private let clipMerger = AKClipMerger()

    // Internal clips storage.
    private var _clips = [AKFileClip]()

    /// A validated array of file clips.  Fails if setting an invalid array of clips.
    @objc open var clips: [AKFileClip] {
        get {
            return _clips
        }
        set {
            do {
                let clips = try AKClipMerger.validateClips(newValue) as! [AKFileClip]
                _clips = clips
            } catch {
                AKLog(error.localizedDescription)
            }
        }
    }

    /// Merges a clip into existing clips.  Fails if clip is invalid.
    @objc open func add(clip: AKFileClip) {
        _clips = clipMerger.merge(clip: clip, clips: _clips) as! [AKFileClip]
    }

    /// Initialize a clip sequence with an array of clips.
    /// - Parameter clips: An array of file clips.  Will not be set if clips are invalid.
    ///
    @objc public init(clips: [AKFileClip]) {
        super.init()
        clipMerger.mergeDelegate = self
        self.clips = clips
    }
}
