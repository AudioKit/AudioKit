//
//  AKAudioFile+Peripherals.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Laurent Veliscek, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension AKAudioFile {

    /// Create an AKAppleSampler loaded with the current AKAudioFile
    public var sampler: AKAppleSampler? {
        let fileSampler = AKAppleSampler()
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
            AKLog("Cannot create sampler: " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }
        return fileSampler
    }

    /// Create an AKMIDISampler loaded with the current AKAudioFile
    public var midiSampler: AKMIDISampler? {
        let fileSampler = AKMIDISampler()
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
            AKLog("Cannot create sampler: " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }
        return fileSampler
    }

    /// Create an AKAudioPlayer to play the current AKAudioFile
    public var player: AKPlayer {
        return AKPlayer(audioFile: self)
    }

}
