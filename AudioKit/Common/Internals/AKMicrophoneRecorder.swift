//
//  AKMicrophoneRecorder.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 5/18/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Simple microphone recorder class
public class AKMicrophoneRecorder {
    
    private var internalRecorder: AVAudioRecorder
    
    /// Initialize the recorder
    ///
    /// - parameter file: Path to the audio file
    /// - parameter settings: File format settings (defaults to WAV)
    ///
    public init(_ file: String, settings: [String: AnyObject] = AudioKit.format.settings) {
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        try! internalRecorder = AVAudioRecorder(URL: url, settings: settings)
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