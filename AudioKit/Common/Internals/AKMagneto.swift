//
//  AKMagneto.swift
//  AudioKit For iOS
//
//  Created by Laurent Veliscek on 16/06/2016.
//  Copyright © 2016 AudioKit. All rights reserved.
//
//  A recorder you can attach to any AKNode, with auto-input
//  (if set to true, input audio pass thru while you don't play back the recorded audio)
//
//  It is still a BETA !
//
//  Please send an email before attempting to modify or add some features
//  laurent.veliscek@gmail.com

import Foundation


public class AKMagneto {


    // The file to record to
    private var tape:AKAudioFile
    // The file to read when playing back
    // Must be different to avoid framePosition conflicts
    private var readingTape:AKAudioFile?

    private var node:AKNode
    private var internalPlayer:AKAudioPlayer

    // mix input and playback to feed the output
    private var mixer:AKDryWetMixer

    // The balance between player and node input audio
    // If 0, input is passed thru. If 1, input is muted
    private var idleBalance: Double = 0

    // the size of the recording buffer
    // Not tested, default is 1024
    private var bufferSize:AVAudioFrameCount
    private var recording = false

    // CallBack triggered when playback ends to play
    // can be set during init or later...
    public var callBack:AKCallback?

    // If true, input sound is passed thru
    // while playback is not playing...
    public var autoInput = true {

        willSet {
            if newValue == true {
                idleBalance = 0
            }
            else {
                idleBalance = 1
            }
            self.mixer.balance = idleBalance
        }
    }


    public init(node:AKNode = AudioKit.output! , tape:AKAudioFile? = nil, callBack:AKCallback? = nil, buffer bufferSize:UInt32 = 1024  ) throws
    {
        self.callBack = callBack


        // requestRecordPermission...
        var permissionGranted: Bool = false
        AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            if granted {
                permissionGranted = true
            } else {
                permissionGranted = false
            }
        })

        if !permissionGranted {
            print("Permission to record not granted")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
        } else  {
            print("Permission to record granted ! ")
        }

        self.node = node

        if tape == nil {
            // We create a record file in temp directory
            do {
                self.tape = try AKAudioFile() }
            catch let error as NSError {
                print ("AKMagneto Error: Cannot create an empty tape")
                throw error
            }
        } else {
            do {
                // We initialize tape AKAudioFile for writing
                self.tape = try AKAudioFile(forWritingAVAudioFile: tape!)
            } catch let error as NSError {
                print ("AKMagneto Error: cannot write to \(tape?.fileNameWithExtension)")
                throw error
            }
        }

        self.bufferSize = bufferSize
        let ioBufferDuration:NSTimeInterval = Double(bufferSize) / 44100.0

        // AVAudioSession setup
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(ioBufferDuration)
        } catch {
            assertionFailure("AKAudioFileRecorder Error: AVAudioSession setup error: \(error)")
        }

        readingTape = try AKAudioFile(forReadingAVAudioFile: self.tape)
        do {
            internalPlayer = try AKAudioPlayer(AKAudioFile: readingTape!)
        } catch let error as NSError {

            print ("AKMagneto Error: cannot create an internal player with \(tape?.fileNameWithExtension)")
            throw error
        }

        mixer = AKDryWetMixer(node,internalPlayer,balance: idleBalance)
    }

    // used to balance the dry/wet mix (auto-input)
    private func internalCallback(){
        self.mixer.balance = idleBalance
        callBack?()
        print ("replay ended")
    }

    private func refreshTapeForReading() throws
    {
        // It seems that we have to reinstantiate the file to
        // get the correct data about length
        do {
            readingTape = try AKAudioFile(forReadingAVAudioFile: tape)
        } catch let error as NSError {
            throw error
        }

        internalPlayer.replaceAKAudioFile(readingTape!)


    }

    // PlayBack what was recorded
    public func replay(){
        if internalPlayer.isPlaying
        { return }

        if tape.samplesCount > 0 {

            do {
                try refreshTapeForReading()
            } catch let error as NSError {
                print ("Cannot create readingTape")
                print ("Error: \(error.localizedDescription)")
            }


            mixer.balance = 1
            internalPlayer.completionHandler  = internalCallback
            internalPlayer.play()
        } else {
            print ("AKMagneto Error: Nothing to play, tape is empty")
        }
    }

    // Stop to replay
    public func stopReplay(){
        if internalPlayer.isPlaying {
            internalPlayer.stop()
        } else {
            print ("AKMagneto Error: Cannot stop, AKMagneto is not replaying!")
        }
    }

    public var output:AKDryWetMixer {
        return mixer
    }

    // return the tape as an AKAudioFile for reading
    public var audioFile : AKAudioFile {
        // update before returning the file
        do {
            try refreshTapeForReading()


        } catch let error as NSError {
            print ("Cannot create readingTape")
            print ("Error: \(error.localizedDescription)")
        }
        return internalPlayer.audioFile

    }

    // Record !
    public func record() {
        if isRecording { return }

        recording = true

        node.avAudioNode.installTapOnBus(0, bufferSize: bufferSize, format: tape.processingFormat, block:
            { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                do{
                    try self.tape.writeFromBuffer(buffer)
                    print("writing ( file duration:  \(self.tape.duration) seconds)")
                }
                catch let error as NSError{
                    print("Write failed: error -> \(error.localizedDescription)")
                }
        })
    }


    /// Stop recording
    public func stopRecord() {
        if !recording { return }
        recording = false
        node.avAudioNode.removeTapOnBus(0)
        print("Recording Stopped.")
    }

    // Reset the tape (erase the recording file)
    public func reset() throws
    {

        if internalPlayer.isPlaying
        {
            internalPlayer.stop()
        }

        // Delete the file tape
        let fileManager = NSFileManager.defaultManager()
        let url = tape.url
        let settings = tape.processingFormat.settings

        do {
            try fileManager.removeItemAtPath(tape.url.absoluteString)
        }
        catch let error as NSError {
            print ("AKMagneto Error: cannot delete Recording file:  \(tape.fileNameWithExtension)")
            throw error
        }

        // create a new AVFile to write to...

        let avTape: AVAudioFile
        do {
            avTape = try AVAudioFile(forWriting: url, settings: settings)}
        catch let error as NSError {
            print ("AKMagneto Error: cannot delete AVAudioFile from file:  \(tape.fileNameWithExtension)")
            throw error
        }

        do {
            tape = try AKAudioFile(forWritingAVAudioFile: avTape) }
        catch let error as NSError {
            print ("AKMagneto Error: cannot delete AKAudioFile from file:  \(tape.fileNameWithExtension)")
            throw error
        }
    }
    
    // MARK: - public vars
    // True if we are recording.
    public var isRecording:Bool{
        return recording
    }
}


