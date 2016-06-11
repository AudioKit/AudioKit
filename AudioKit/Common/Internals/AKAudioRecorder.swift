//
//  AKAudioRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Simple audio recorder class
public class AKAudioRecorder {
    
    public var internalRecorder: AVAudioRecorder
    
    /// Initialize the recorder
    ///
    /// - parameter file: Path to the audio file
    ///
    public init(_ file: String) {
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        try! internalRecorder = AVAudioRecorder(URL: url, settings: [:])
    }
    
    /// Record audio
    public func record() {
        internalRecorder.prepareToRecord()
        internalRecorder.record()
    }
    
    /// Stop recording
    public func stop() {
        internalRecorder.stop()
    }
}
