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
    public init(_ file: String, settings: [String: AnyObject] = AudioKit.format.settings) {

        #if os(iOS)
        self.recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
            try recordingSession.setActive(true)
        } catch {
            print("lacking permission to record!\n")
        }
        #endif
        
        let url = URL.init(fileURLWithPath: file, isDirectory: false)
        try! internalRecorder = AVAudioRecorder(url: url, settings: settings)
    }
    
    /// Record audio
    public func record() {
        if internalRecorder.isRecording == false {
            internalRecorder.prepareToRecord()
            internalRecorder.record()
        }
    }
    
    /// Stop recording
    public func stop() {
        if internalRecorder.isRecording == true {
            internalRecorder.stop()
        }
    }
}
