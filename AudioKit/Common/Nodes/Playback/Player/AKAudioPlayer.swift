//
//  AKAudioPlayer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka and Laurent Veliscek, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Not so simple audio playback class
open class AKAudioPlayer: AKNode, AKToggleable {
    
    // MARK: - Private variables
    
    fileprivate var internalAudioFile: AKAudioFile
    fileprivate var internalPlayer = AVAudioPlayerNode()
    fileprivate var audioFileBuffer: AVAudioPCMBuffer?
    fileprivate var totalFrameCount: UInt32 = 0
    fileprivate var startingFrame: UInt32 = 0
    fileprivate var endingFrame: UInt32 = 0
    fileprivate var framesToPlayCount: UInt32 = 0
    fileprivate var lastCurrentTime: Double = 0
    fileprivate var paused = false
    fileprivate var playing = false
    fileprivate var internalStartTime: Double = 0
    fileprivate var internalEndTime: Double = 0
    
    // MARK: - Properties
    
    /// Will be triggered when AKAudioPlayer has finished to play.
    /// (will not as long as loop is on)
    open var completionHandler: AKCallback?
    
    /// Boolean indicating whether or not to loop the playback
    open var looping: Bool = false
    
    
    /// return the current played AKAudioFile
    open var audioFile: AKAudioFile {
        return internalAudioFile
    }
    
    // path to the currently loaded AKAudioFile
    open var path: String {
        return audioFile.url.path
    }
    
    /// Total duration of one loop through of the file
    open var duration: Double {
        return Double(totalFrameCount) / Double(internalAudioFile.sampleRate)
    }
    
    /// Output Volume (Default 1)
    open var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            internalPlayer.volume = Float(volume)
        }
    }
    
    /// Whether or not the audio player is currently started
    open var isStarted: Bool {
        return  internalPlayer.isPlaying
    }
    
    
    /// Current playback time (in seconds)
    open var currentTime: Double {
        if playing {
            if let nodeTime = internalPlayer.lastRenderTime,
                let playerTime = internalPlayer.playerTime(forNodeTime: nodeTime) {
                //return   Double(Double(startingFrame) / sampleRate)  +  Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
                return Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
            }
            
        }
        return lastCurrentTime
    }
    
    /// Time within the audio file at the current time
    open var playhead: Double {
        
        let endTime = Double(Double(endingFrame) / internalAudioFile.sampleRate)
        let startTime = Double(Double(startingFrame) / internalAudioFile.sampleRate)
        
        if endTime > startTime {
            
            if looping {
                return  startTime + currentTime.truncatingRemainder(dividingBy: (endTime - startTime))
            } else {
                if currentTime > endTime {
                    return (startTime + currentTime).truncatingRemainder(dividingBy: (endTime - startTime))
                } else {
                    return (startTime + currentTime)
                }
            }
        } else {
            return 0
        }
    }
    
    /// Pan (Default Center = 0)
    open var pan: Double = 0.0 {
        didSet {
            pan = (-1...1).clamp(pan)
            internalPlayer.pan = Float(pan)
        }
    }
    
    /// sets the start time, If it is playing, player will
    /// restart playing from the start time each time end time is set
    open var startTime: Double {
        get {
            return Double(startingFrame) / internalAudioFile.sampleRate
            
        }
        set {
            //let wasPlaying = playing
            
            // since setting startTime will fill the buffer again, we only want to do this if the
            // data really needs to be updated
            if newValue == internalStartTime {
                //print("startTime is the same, so returning: \(newValue)")
                return
                
            } else if newValue > Double(endingFrame) / internalAudioFile.sampleRate && endingFrame > 0 {
                print("ERROR: AKAudioPlayer cannot set a startTime bigger than the endTime: \(Double(endingFrame) / internalAudioFile.sampleRate) seconds")
                
            } else {
                startingFrame = UInt32(newValue * internalAudioFile.sampleRate)
                
                Swift.print("AKAudioPlayer.startTime = \(newValue), startingFrame: \(startingFrame)")
                
                // now update the buffer
                updatePCMBuffer()
                //stop()
                
                // remember this value for ease of checking redundancy later
                internalStartTime = newValue
            }
            // RF: I don't think this is a good idea. There are many cases where you don't want it to restart on you without
            //explicitly meaning to.
            //            if wasPlaying {
            //                play()
            //            }
        }
    }
    
    /// sets the end time, If it is playing, player will
    /// restart playing from the start time each time end time is set
    open var endTime: Double {
        get {
            return Double(endingFrame) / internalAudioFile.sampleRate
            
        }
        set {
            //let wasPlaying = playing
            
            // since setting startTime will fill the buffer again, we only want to do this if the
            // data really needs to be updated
            if newValue == internalEndTime {
                //print("endTime is the same, so returning: \(newValue)")
                return
                
            } else if newValue == 0 {
                endingFrame = totalFrameCount
                
            } else if newValue < Double(startingFrame) / internalAudioFile.sampleRate
                || newValue > Double(Double(totalFrameCount) / internalAudioFile.sampleRate) {
                print("ERROR: AKAudioPlayer cannot set an endTime more than file's duration: \(duration) seconds or less than startTime: \(Double(startingFrame) / internalAudioFile.sampleRate) seconds")
            } else {
                endingFrame = UInt32(newValue * internalAudioFile.sampleRate)
                
                Swift.print("AKAudioPlayer.endTime = \(newValue), endingFrame: \(endingFrame)")
                
                // now update the buffer
                updatePCMBuffer()
                //stop()
                
                // remember this value for ease of checking redundancy later
                internalEndTime = newValue
            }
            //            if wasPlaying {
            //                play()
            //            }
        }
    }
    
    /// Sets the time in the future when playback will commence. For immediately playback, leave it 0.
    open var scheduledTime: Double = 0
    
    
    // MARK: - Initialization
    
    
    /// Initialize the audio player
    ///
    ///
    /// Notice that completionCallBack will be triggered from a
    /// background thread. Any UI update should be made using:
    ///
    /// ```
    /// Dispatch.main.async {
    ///    // UI updates...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - file: the AKAudioFile to play
    ///   - looping : will loop play if set to true, or stop when play ends, so it can trig the completionHandler callback. Default is false (non looping)
    ///   - completionHandler : AKCallback that will be triggered when the player end playing (useful for refreshing UI so we're not playing anymore, we stopped playing...
    ///
    /// - Returns: an AKAudioPlayer if init succeeds, or nil if init fails. If fails, errors may be catched as it is a throwing init.
    ///
    public init(file: AKAudioFile, looping:Bool = false, completionHandler: AKCallback? = nil) throws {
        
        let readFile:AKAudioFile
        
        // Open the file for reading to avoid a crash when setting frame position
        // if the file was instantiated for writing
        do {
            readFile = try AKAudioFile(forReading: file.url)
            
        } catch let error as NSError {
            print("AKAudioPlayer Error: cannot open file \(file.fileNamePlusExtension) for reading!...")
            print("Error: \(error)")
            throw error
        }
        self.internalAudioFile = readFile
        self.completionHandler = completionHandler
        self.looping = looping
        
        super.init()
        AudioKit.engine.attach(internalPlayer)
        let mixer = AVAudioMixerNode()
        AudioKit.engine.attach(mixer)
        let format = AVAudioFormat(standardFormatWithSampleRate: self.internalAudioFile.sampleRate, channels: self.internalAudioFile.channelCount)
        AudioKit.engine.connect(internalPlayer, to: mixer, format: format)
        self.avAudioNode = mixer
        internalPlayer.volume = 1.0
        
        initialize()
    }
    
    // MARK: - Methods
    
    /// Start playback
    open func start() {
        
        if !playing {
            if audioFileBuffer != nil {
                // schedule it at some point in the future / or immediately if 0
                scheduleBuffer( secondsToAVAudioTime(scheduledTime) )
                
                playing = true
                paused = false
                internalPlayer.play()
                
            } else {
                print("AKAudioPlayer Warning: cannot play an empty buffer!...")
            }
        } else {
            print("AKAudioPlayer Warning: already playing!...")
        }
    }
    
    /// Stop playback
    open func stop() {
        if !playing {
            return
        }
        
        print("AKAudioPlayer.stop()")
        
        lastCurrentTime = Double(startTime / internalAudioFile.sampleRate)
        playing = false
        paused = false
        internalPlayer.stop()
        
        //updatePCMBuffer()
        
        //if you pre-schedule the buffer it's not possible to schedule it in the future
        //scheduleBuffer()
    }
    
    /// Pause playback
    open func pause() {
        if playing {
            if !paused {
                lastCurrentTime = currentTime
                playing = false
                paused = true
                internalPlayer.pause()
            }
            else {
                print("AKAudioPlayer Warning: already paused!...")
            }
        } else {
            print("AKAudioPlayer Warning: Cannot pause when not playing!...")
        }
    }
    
    /// resets in and out times for playing
    open func reloadFile() throws {
        let wasPlaying  = playing
        if wasPlaying {
            stop()
        }
        var newAudioFile: AKAudioFile?
        
        do {
            newAudioFile = try AKAudioFile(forReading: internalAudioFile.url)
        } catch let error as NSError {
            print("AKAudioPlayer Error:Couldn't reLoadFile !...")
            print("Error: \(error)")
            throw error
        }
        
        internalAudioFile = newAudioFile!
        internalPlayer.reset()
        initialize()
        
        if wasPlaying {
            play()
        }
    }
    
    /// Replace player's file with a new AKAudioFile file
    open func replace(file: AKAudioFile) throws {
        internalAudioFile = file
        do {
            try reloadFile()
        } catch let error as NSError {
            print("AKAudioPlayer Error: Couldn't reload replaced File: \"\(file.fileNamePlusExtension)\" !...")
            print("Error: \(error)")
        }
        print("AKAudioPlayer -> File with \"\(internalAudioFile.fileNamePlusExtension)\" Reloaded")
    }

    /// Play the file back from a certain time, to an end time (if set). You can optionally set a scheduled time to play (in seconds).
    ///
    ///  - Parameters:
    ///    - time: Time into the file at which to start playing back
    ///    - endTime: Time into the file at which to playing back will stop / Loop
    ///    - scheduledTime: Time in the future to start playback. This is useful for scheduling a group of sounds to
    ///         start concurrently, or to simply schedule the start time.
    ///
    open func play(from time: Double, to endTime: Double = 0, when scheduledTime: Double = 0) {
        
        if endTime > 0 {
            self.endTime = endTime
        }
        
        self.startTime = time
        
        if endingFrame > startingFrame {
            stop()
            self.scheduledTime = scheduledTime
            start()
        } else {
            print("ERROR AKaudioPlayer:  cannot play, \(internalAudioFile.fileNamePlusExtension) is empty or segment is too short!")
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func initialize() {
        
        audioFileBuffer = nil
        totalFrameCount = UInt32(internalAudioFile.length)
        startingFrame = 0
        endingFrame = totalFrameCount
        
        // RF: Actually, this is incorrect. The audio will be played correctly now.
        // Warning if file's samplerate don't match with AKSettings.samplesRate
        //        if internalAudioFile.sampleRate != AKSettings.sampleRate {
        //            print("AKAudioPlayer Warning:  \"\(internalAudioFile.fileNamePlusExtension)\" has a different sample rate from AudioKit's Settings !")
        //            print("Audio will be played at a bad pitch/speed, in / out time will not be set properly !")
        //        }
        
        if internalAudioFile.length > 0 {
            updatePCMBuffer()
            
            // Setting this here doesn't make sense to me, if you pre-schedule the
            // buffer it's not possible to schedule it in the future
            //scheduleBuffer()
            
        } else {
            print("AKAudioPlayer Warning:  \"\(internalAudioFile.fileNamePlusExtension)\" is an empty file")
        }
    }
    
    fileprivate func secondsToAVAudioTime(_ time: Double) -> AVAudioTime {
        let sampleTime = AVAudioFramePosition(time * internalAudioFile.sampleRate)
        return AVAudioTime(hostTime: mach_absolute_time(), sampleTime: sampleTime, atRate: internalAudioFile.sampleRate)
    }
    
    fileprivate func scheduleBuffer(_ atTime: AVAudioTime? = nil) {
        if audioFileBuffer != nil {
            //internalPlayer.scheduleBuffer(audioFileBuffer!, completionHandler: internalCompletionHandler)
            internalPlayer.scheduleBuffer(audioFileBuffer!, at: atTime, options: .interrupts, completionHandler: internalCompletionHandler)
            
            if atTime != nil {
                internalPlayer.prepare(withFrameCount: framesToPlayCount)
            }
        }
    }
    
    fileprivate func updatePCMBuffer() {
        if internalAudioFile.samplesCount > 0 {
            internalAudioFile.framePosition = Int64(startingFrame)
            framesToPlayCount = endingFrame - startingFrame
            audioFileBuffer = AVAudioPCMBuffer(
                pcmFormat: internalAudioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(totalFrameCount) )
            do {
                try internalAudioFile.read(into: audioFileBuffer!, frameCount: framesToPlayCount)
                
                print("AKAudioPlayer.updatePCMBuffer() \(audioFileBuffer!.frameLength)")
            } catch {
                print("ERROR AKaudioPlayer: Could not read data into buffer.")
                return
            }
        } else {
            print("ERROR updatePCMBuffer: Could not set PCM buffer -> \(internalAudioFile.fileNamePlusExtension) samplesCount = 0.")
        }
    }
    
    /// Triggered when the player reaches the end of its playing range
    fileprivate func internalCompletionHandler() {
        if playing {
            if looping {
                scheduleBuffer()
            } else {
                stop()
                self.completionHandler?()
            }
        }
    }
    
    
}
