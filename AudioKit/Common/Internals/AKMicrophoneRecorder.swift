//
//  AKMicrophoneRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Laurent Veliscek,
//  revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Simple microphone recorder class
public class AKMicrophoneRecorder: AKNodeRecorder {
    public convenience init(file: AKAudioFile? = nil) throws {
        let mic = AKMicrophone()
        let mixer = AKMixer(mic)
        try self.init(node: mixer, file: file)
    }
}