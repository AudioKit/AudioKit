//
//  AKAudioNodeRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Tweaked by Laurent Veliscek
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

import Foundation
import AVFoundation

/// Simple audio recorder class
public class AKNodeRecorder {

    // MARK: - Properties

    // The node we record from
    private var node: AKNode?

    // The file to record to
    private var internalAudioFile: AKAudioFile

    private var recording = false

    /// True if we are recording.
    public var isRecording: Bool {
        return recording
    }

    /// Duration of recording
    public var recordedDuration: Double {
        return internalAudioFile.duration
    }

    /// return the AKAudioFile for reading
    public var audioFile: AKAudioFile? {

        var internalAudioFileForReading: AKAudioFile
        do {
            internalAudioFileForReading = try AKAudioFile(forReading: internalAudioFile.url)
            return internalAudioFileForReading
        } catch let error as NSError {
            print ("Cannot create internal audio file for reading")
            print ("Error: \(error.localizedDescription)")
            return nil
        }

    }

    // MARK: - Initialization

    /// Initialize the node recorder
    ///
    /// Recording buffer size is defaulted to be AKSettings.bufferLength
    /// You can set a different value by setting an AKSettings.recordingBufferLength
    ///
    /// - Parameters:
    ///   - node: Node to record from
    ///   - file: Audio file to record to
    ///
    public init(node: AKNode = AudioKit.output!,
                file: AKAudioFile? = nil) throws {

        // AVAudioSession buffer setup

        if file == nil {
            // We create a record file in temp directory
            do {
                self.internalAudioFile = try AKAudioFile()
            } catch let error as NSError {
                print ("AKNodeRecorder Error: Cannot create an empty audio file")
                throw error
            }

        } else {

            do {
                // We initialize AKAudioFile for writing (and check that we can write to)
                self.internalAudioFile = try AKAudioFile(forWriting: file!.url, settings: file!.processingFormat.settings)
            } catch let error as NSError {
                print ("AKNodeRecorder Error: cannot write to \(file!.fileNamePlusExtension)")
                throw error
            }
        }
        self.node = node
    }

    // MARK: - Methods

    /// Start recording
    public func record() throws {
        if recording {
            print ("AKNodeRecorder Warning: already recording !")
            return
        }


        #if os(iOS)
            // requestRecordPermission...
            var permissionGranted: Bool = false
            
            AKSettings.session.requestRecordPermission() {
                (granted: Bool)-> Void in
                if granted {
                    permissionGranted = true
                } else {
                    permissionGranted = false
                }
            }

            if !permissionGranted {
                print("AKNodeRecorder Error: Permission to record not granted")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
            }

        // Sets AVAudioSession Category to be Play and Record

            // Here's the reason why I'd like to change record() to be a throwing method
            if (AKSettings.session != AKSettings.SessionCategory.PlayAndRecord.rawValue)
            {
                do {
                    try AKSettings.setSessionCategory(AKSettings.SessionCategory.PlayAndRecord)
                } catch let error as NSError {
                    print("AKNodeRecorder Error: Cannot set AVAudioSession Category to be .PlaybackAndRecord")
                    throw error
                }
            }
        #endif


        if  node != nil {

            let recordingBufferLength:AVAudioFrameCount = AKSettings.recordingBufferLength.samplesCount

            print ("recording")
            node!.avAudioNode.installTapOnBus(0, bufferSize: recordingBufferLength, format: internalAudioFile.processingFormat, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                do {
                    buffer.frameLength = recordingBufferLength
                    try self.internalAudioFile.writeFromBuffer(buffer)
                    self.recording = true
                    print("writing ( file duration:  \(self.internalAudioFile.duration) seconds)")
                } catch let error as NSError {
                    self.recording = false
                    print("Write failed: error -> \(error.localizedDescription)")
                }
            })
        } else {
            print ("AKNodeRecorder Error: input node is not available")
        }
    }

    /// Stop recording
    public func stop() {
        if !recording {
            print ("AKNodeRecorder Warning: Cannot stop recording, already stopped !")
            return
        }

        recording = false
        if  node != nil {
            node!.avAudioNode.removeTapOnBus(0)
            print("Recording Stopped.")
        } else {
            print ("AKNodeRecorder Error: input node is not available")
        }
    }


    /// Reset the AKAudioFile to clear previous recordings
    public func reset() throws {
        
        let settings = internalAudioFile.processingFormat.settings
        let url = internalAudioFile.url

        // Creates a blank new file
        do {
            internalAudioFile = try AKAudioFile(forWriting: url, settings: settings)
            print ("AKNodeRecorder: file has been cleared")
        } catch let error as NSError {
            print ("AKNodeRecorder Error: cannot record to file: \(internalAudioFile.fileNamePlusExtension)")
            throw error
        }
    }
    
}