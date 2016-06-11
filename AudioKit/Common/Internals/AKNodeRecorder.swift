//
//  AKNodeRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Simple audio recorder class
public class AKNodeRecorder {
    
    private var avAudioFile: AVAudioFile?
    private var settings: [String: AnyObject]
    private var format: AVAudioFormat
    private var url: NSURL
    private var node: AKNode?
    public var isRecording = false
    
    /// Initialize the recorder to record a node's output to a file
    ///
    /// - parameter file: Path to the audio file
    /// - parameter node: Node to record (Defaults to the overall output)
    ///
    public init(
        _ file: String,
          node: AKNode = AudioKit.output!) {
        self.node = node
        url = NSURL.fileURLWithPath(file, isDirectory: false)
        
        format = AudioKit.format
        settings = AudioKit.format.settings
        do {
            let audioFile = try AVAudioFile(forReading: url)
            format = audioFile.processingFormat
            settings = audioFile.processingFormat.settings
            settings[AVLinearPCMIsNonInterleaved] = false
        } catch {
            print("Could not open file for reading the format from.")
        }
    }
    
    private func prepareToRecord() {
        do {
            avAudioFile = try AVAudioFile(forWriting: url, settings: settings)
        } catch {
            print("Could not open the audio file for writing")
        }
    }
    
    /// Record audio
    public func record() {
        if isRecording { return }
        
        prepareToRecord()
        isRecording = true
        
        if let recordingNode = node {
            recordingNode.avAudioNode.installTapOnBus(0, bufferSize: 1024, format: format) {
                (buffer, time) in
                do {
                    try self.avAudioFile?.writeFromBuffer(buffer)
                    print (self.avAudioFile!.length)
                } catch {
                    print("Could not record.")
                }
            }
        }
        print("Started recording.")
    }
    
    /// Stop recording
    public func stop() {
        isRecording = false
        if let recordingNode = node {
            recordingNode.avAudioNode.removeTapOnBus(0)
            print("Stopped recording.")
        }
    }
}
