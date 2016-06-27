//
//  AKAudioNodeRecorder2.swift
//  AudioKit For iOS
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

    // The node we record from
    private var node: AKNode?
    
    // The file to record to
    private var internalAudioFile: AKAudioFile

    // the size of the recording buffer
    // Not tested, default is 1024
    private var bufferSize: AVAudioFrameCount
    private var recording = false


    private var previousAVAudioSessionCategory: String?

    /// Initialize the node recorder
    ///
    /// - parameter node:       Node to record from
    /// - parameter file:       Audio file to record to
    /// - parameter bufferSize: Size of the buffer to use
    ///
    public init(node: AKNode = AudioKit.output!,
                file: AKAudioFile? = nil,
                buffer bufferSize: UInt32 = 1024  ) throws {


        // requestRecordPermission...
        var permissionGranted: Bool = false
        #if os(iOS)

            self.previousAVAudioSessionCategory = AVAudioSession.sharedInstance().category

            AVAudioSession.sharedInstance().requestRecordPermission() {
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
        #endif

        // AVAudioSession buffer setup

        self.bufferSize = bufferSize
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
                self.internalAudioFile = try AKAudioFile(writeAVAudioFile: file!)
            } catch let error as NSError {
                print ("AKNodeRecorder Error: cannot write to \(file!.fileNamePlusExtension)")
                throw error
            }
        }
        self.node = node
    }


    // Record !
    public func record() {
        if recording {
            print ("AKNodeRecorder Warning: already recording !")
            return
        }

        // Sets AVAudioSession Category to be Play and Record
        #if os(iOS)
            do {
                let session = AVAudioSession.sharedInstance()
                let ioBufferDuration: NSTimeInterval = Double(bufferSize) / 44100.0
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.setPreferredIOBufferDuration(ioBufferDuration)
                try session.setActive(true)
            } catch {
                assertionFailure("AKAudioFileRecorder Error: AVAudioSession setup error: \(error)")
            }
        #endif




        if  node != nil {
            recording = true
            print ("recording")
            node!.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: internalAudioFile.processingFormat, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                do {
                    try self.internalAudioFile.writeFromBuffer(buffer)
                    print("writing ( file duration:  \(self.internalAudioFile.duration) seconds)")
                } catch let error as NSError {
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

        // Revert AVAudioSession Category to previous settings
        #if os(iOS)
            do {
                if previousAVAudioSessionCategory != nil {
                    try AVAudioSession.sharedInstance().setCategory(previousAVAudioSessionCategory!)
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                    print ("AKNodeRecorder Error: previousAVAudioSessionCategory is nil !")
                    print ("AKNodeRecorder: AVAudioSession Category set to \"Ambient\".")
                }
            } catch {
                assertionFailure("AKAudioFileRecorder Error: AVAudioSession setup error: \(error)")
            }
        #endif




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

        // Delete the current file audio file
        let fileManager = NSFileManager.defaultManager()
        let url = internalAudioFile.url
        let settings = internalAudioFile.processingFormat.settings

        do {
            try fileManager.removeItemAtPath(internalAudioFile.url.absoluteString)
        } catch let error as NSError {
            print ("AKNodeRecorder Error: cannot delete Recording file:  \(internalAudioFile.fileNamePlusExtension)")
            throw error
        }

        // Creates a blank new file
        do {
            internalAudioFile = try AKAudioFile(forWriting: url, settings: settings)
            print ("AKNodeRecorder: file has been cleared")
        } catch let error as NSError {
            print ("AKNodeRecorder Error: cannot record to file: \(internalAudioFile.fileNamePlusExtension)")
            throw error
        }
    }

    // MARK: - public vars
    
    /// True if we are recording.
    public var isRecording: Bool {
        return recording
    }

    // Duration of recording
    public var recordedDuration: Double {
        return internalAudioFile.duration
    }

    /// return the AKAudioFile for reading
    public var audioFile: AKAudioFile? {

        var internalAudioFileForReading: AKAudioFile
        do {
            internalAudioFileForReading = try AKAudioFile(readAVAudioFile: internalAudioFile)
            return internalAudioFileForReading
        } catch let error as NSError {
            print ("Cannot create internal audio file for reading")
            print ("Error: \(error.localizedDescription)")
            return nil
        }
        
    }
    
}