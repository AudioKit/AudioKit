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
    private var tape: AKAudioFile

    // the size of the recording buffer
    // Not tested, default is 1024
    private var bufferSize: AVAudioFrameCount
    private var recording = false

    public init(node: AKNode = AudioKit.output!, file: AKAudioFile? = nil, buffer bufferSize: UInt32 = 1024  ) throws {


        // requestRecordPermission...
        var permissionGranted: Bool = false
#if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            if granted {
                permissionGranted = true
            } else {
                permissionGranted = false
            }
        })

        if !permissionGranted {
            print("AKNodeRecorder Error: Permission to record not granted")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
        }
#endif
        
        // AVAudioSession setup

        self.bufferSize = bufferSize
        let ioBufferDuration: NSTimeInterval = Double(bufferSize) / 44100.0

#if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
        } catch {
            assertionFailure("AKAudioFileRecorder Error: AVAudioSession setup error: \(error)")
        }
#endif

        if file == nil {
            // We create a record file in temp directory
            do {
                self.tape = try AKAudioFile()
            } catch let error as NSError {
                print ("AKNodeRecorder Error: Cannot create an empty tape")
                throw error
            }

        } else {

            do {
                // We initialize tape AKAudioFile for writing (and check that we can write to)
                self.tape = try AKAudioFile(forWritingFromAVAudioFile: file!)
            } catch let error as NSError {
                print ("AKNodeRecorder Error: cannot write to \(file!.fileNameWithExtension)")
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

        if  node != nil {
            recording = true

            print ("recording")
            node!.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: tape.processingFormat, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                do {
                    try self.tape.writeFromBuffer(buffer)
                    print("writing ( file duration:  \(self.tape.duration) seconds)")
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

        // Delete the current file tape
        let fileManager = NSFileManager.defaultManager()
        let url = tape.url
        let settings = tape.processingFormat.settings

        do {
            try fileManager.removeItemAtPath(tape.url.absoluteString)
        } catch let error as NSError {
            print ("AKNodeRecorder Error: cannot delete Recording file:  \(tape.fileNameWithExtension)")
            throw error
        }

        // Creates a blanck new tape
        do {
            tape = try AKAudioFile(forWriting: url, settings: settings)
            print ("AKNodeRecorder: tape has been cleared")
        } catch let error as NSError {
            print ("AKNodeRecorder Error: cannot create an new tape from file:  \(tape.fileNameWithExtension)")
            throw error
        }
    }

    // MARK: - public vars
    // True if we are recording.
    public var isRecording: Bool {
        return recording
    }

    // True if we are recording.
    public var recordedDuration: Double {
        return tape.duration
    }

    // return the tape as an AKAudioFile for reading
    public var audioFile: AKAudioFile? {

        var tapeForReading: AKAudioFile
        do {
            tapeForReading = try AKAudioFile(forReadingFromAVAudioFile: tape)
             return tapeForReading
        } catch let error as NSError {
            print ("Cannot create readingTape")
            print ("Error: \(error.localizedDescription)")
            return nil
        }

    }

}