//
//  AKAudioRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Simple audio recorder class
public class AKAudioRecorder {
    
    private var avAudioFile: AVAudioFile?
    private var node: AKNode?
    
    /// Initialize the recorder to record a node's output to a file
    ///
    /// - parameter file: Path to the audio file
    /// - parameter node: Node to record (Defaults to the overall output)
    ///
    public init(_ file: String, node: AKNode = AudioKit.output!) {
        self.node = node
        let url = NSURL.fileURLWithPath(file, isDirectory: false)
        do {
            let audioFile = try! AVAudioFile(forReading: url)
            var settings = audioFile.processingFormat.settings
            settings[AVLinearPCMIsNonInterleaved] = false
            avAudioFile = try AVAudioFile(forWriting: url, settings: settings)
        } catch {
            print("Could not open file.")
        }

    }
    
    /// Record audio
    public func record() {
        if let recordingNode = node {
            recordingNode.avAudioNode.installTapOnBus(0, bufferSize: 1024, format: AudioKit.format) { (buffer, time) in
                do {
                    try self.avAudioFile?.writeFromBuffer(buffer)
                } catch {
                    print("Could not record.")
                }
            }
        }
    }
    
    /// Stop recording
    public func stop() {
        if let recordingNode = node {
            recordingNode.avAudioNode.removeTapOnBus(0)
        }
    }
}
