//
//  AKAudioFile+Peripherals.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Laurent Veliscek on 7/4/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension AKAudioFile {

    /// Create an AKSampler loaded with the current AKAudioFile
    public var sampler: AKSampler? {
        let fileSampler = AKSampler()
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
            AKLog("ERROR AKAudioFile: cannot create sampler: \(error)")
        }
        return fileSampler
    }

    /// Create an AKMIDISampler loaded with the current AKAudioFile
    public var midiSampler: AKMIDISampler? {
        let fileSampler = AKMIDISampler()
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
            AKLog("ERROR AKAudioFile: cannot create sampler: \(error)")
        }
        return fileSampler
    }

    /// Create an AKAudioPlayer to play the current AKAudioFile
    public var player: AKPlayer {
        return AKPlayer(audioFile: self)
    }

}
