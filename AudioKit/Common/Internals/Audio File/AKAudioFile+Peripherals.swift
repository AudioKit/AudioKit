//
//  AKAudioFile+Peripherals.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka and Laurent Veliscek on 7/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//


import Foundation
import AVFoundation

extension AKAudioFile {

    /// Create an AKSampler loaded with the current AKAudioFile
    public var sampler: AKSampler? {
        let fileSampler = AKSampler()
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
        print( "ERROR AKAudioFile: cannot create sampler: \(error)")
        }
        return fileSampler
    }

    /// Create an AKAudioPlayer to play the current AKAudioFile
    public var player: AKAudioPlayer? {
        var filePlayer: AKAudioPlayer?

        do {
            try filePlayer = AKAudioPlayer(file: self)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot create player: \(error)")
        }
        return filePlayer
    }
    

}
