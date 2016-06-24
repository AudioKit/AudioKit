//
//  AKMicrophoneRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Simple microphone recorder class
public class AKMicrophoneRecorder {
    
    private var internalRecorder: AVAudioRecorder
    
#if os(iOS)
    private var recordingSession: AVAudioSession
#endif
    
    /// Initialize the recorder
    ///
    /// - parameter file: Path to the audio file
    /// - parameter settings: File format settings (defaults to WAV)
    ///
    public init(_ file: AKAudioFile, settings: [String: AnyObject] = AudioKit.format.settings) {

        #if os(iOS)
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker)
            try recordingSession.setActive(true)
        } catch {
            print("lacking permission to record!\n")
        }
        #endif
        
        try! internalRecorder = AVAudioRecorder(URL: file.url, settings: settings)
    }
    
    /// Record audio
    public func record() {
        if internalRecorder.recording == false {
            internalRecorder.prepareToRecord()
            internalRecorder.record()
        }
    }
    
    /// Stop recording
    public func stop() {
        if internalRecorder.recording == true {
            internalRecorder.stop()
        }
    }
}