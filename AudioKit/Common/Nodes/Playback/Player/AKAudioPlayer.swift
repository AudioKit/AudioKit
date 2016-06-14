//
//  AKAudioPlayer.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Tweaked by Laurent Veliscek on 10/06/2016.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

@objc public protocol AKAudioPlayerDelegate: class {
    @objc optional func playerStoppedOrFinished()
    @objc optional func playHeadSnapshot(_ playHead: Double)
}

/// Not so simple audio playback class
public class AKAudioPlayer : AKNode, AKToggleable{


    // MARK: - private vars

    private var audioFile:AKAudioFile
    private var internalPlayer = AVAudioPlayerNode()
    private var audioFileBuffer: AVAudioPCMBuffer?
    private var totalFrameCount: UInt32 = 0
    private var startingFrame: UInt32 = 0
    private var endingFrame: UInt32 = 0
    private var framesToPlayCount: UInt32 = 0
    private var lastCurrentTime:Double = 0
    private var paused = false
    private var playing = false
    private var currentTimeTimer: Timer?
    

    // MARK: - public vars

    /// AKAudioPLayer delegate
    public weak var delegate:AKAudioPlayerDelegate?
    
    /// Will be triggered when AKAudioPlayer has finished to play.
    /// (will not as long as loop is on)
    public var completionHandler: AKCallback?

    // Boolean indicating whether or not to loop the playback
    public var looping:Bool = false

    // return the current AKAudioFile
    public var akAudioFile:AKAudioFile {
        return audioFile
    }

    /// Total duration of one loop through of the file
    public var duration: Double {
        return Double(totalFrameCount) / Double(audioFile.sampleRate)
    }

    /// Output Volume (Default 1)
    public var volume: Double = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            internalPlayer.volume = Float(volume)
        }
    }

    /// Whether or not the audio player is currently started
    public var isStarted: Bool {
        return  internalPlayer.isPlaying
    }


    /// Current playback time (in seconds)
    public var currentTime: Double {
        if playing {
            if let nodeTime = internalPlayer.lastRenderTime,
                let playerTime = internalPlayer.playerTime(forNodeTime: nodeTime) {
                //return   Double(Double(startingFrame) / sampleRate)  +  Double( Double( playerTime.sampleTime ) / playerTime.sampleRate )
                return    Double( Double( playerTime.sampleTime ) / playerTime.sampleRate )
            }

        }
        return lastCurrentTime
    }

    ///Snapshot playhead
    public func timerPlayerHead() {
        self.delegate?.playHeadSnapshot?(self.playhead)
    }
    
    /// Time within the audio file at the current time
    public var playhead: Double {

        let endTime = Double(Double(endingFrame) / audioFile.sampleRate)
        let startTime = Double(Double(startingFrame) / audioFile.sampleRate)

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
    public var pan: Double = 0.0 {
        didSet {
            if pan < -1 {
                pan = -1
            }
            if pan > 1 {
                pan = 1
            }
            internalPlayer.pan = Float(pan)
        }
    }

    /// sets the start time, If it is playing, player will
    /// restart playing from the start time each time end time is set
    public var startTime :Double
        {
        get {
            return Double(startingFrame) / audioFile.sampleRate

        }
        set {
            let wasPlaying = playing
            if newValue > Double(endingFrame) / audioFile.sampleRate
            {
                print ("ERROR: AKAudioPlayer cannot set a startTime bigger that endTime: \(Double(endingFrame) / audioFile.sampleRate) seconds")
            } else {
                startingFrame = UInt32(newValue * audioFile.sampleRate
                )
                stop()
            }
            if wasPlaying
            {
                play()
            }
        }
    }

    /// sets the end time, If it is playing, player will
    /// restart playing from the start time each time end time is set
    public var endTime :Double
        {
        get {
            return Double(endingFrame) / audioFile.sampleRate

        }
        set {
            let wasPlaying = playing
            if newValue < Double(startingFrame) / audioFile.sampleRate
                || newValue > Double(Double(totalFrameCount) / audioFile.sampleRate)
            {
                print ("ERROR: AKAudioPlayer cannot set an endTime more than file's duration: \(duration) seconds or less than startTime: \(Double(startingFrame) / audioFile.sampleRate) seconds")
            } else {
                endingFrame = UInt32(newValue * audioFile.sampleRate)
                stop()
            }
            if wasPlaying
            {
                play()
            }
        }
    }



    // MARK: - public inits

    /// the safest way to proceed is to use an AKAudioFile
    public init (AKAudioFile file: AKAudioFile, completionHandler: AKCallback? = nil) throws {

        self.audioFile = file
        self.completionHandler = completionHandler

        // Conforms to protocoles...
        super.init()
        AudioKit.engine.attach(internalPlayer)
        let mixer = AVAudioMixerNode()
        AudioKit.engine.attach(mixer)
        AudioKit.engine.connect(internalPlayer, to: mixer, format: AudioKit.format)
        self.avAudioNode = mixer

        internalPlayer.volume = 1.0

        initialize()

    }


    /// To stay compatible with ealier version
    /// Should be deprecated because you cannot handle errors at run time...
    /// :-/
    public convenience init(_ file: String, completionHandler: AKCallback? = nil) {

        // build an empty AKAudioFile as a backup if we fail to create a valid one from "file"
        var akAudioFile = try? AKAudioFile()

        let nsurl = URL(string:file)
        if nsurl != nil {
            do {
                let avAudioFile = try AVAudioFile(forReading: nsurl!)
                do {
                    akAudioFile = try AKAudioFile(fromAVAudioFile: avAudioFile)
                } catch let error as NSError {
                    print ("Couldn't create an AKAudioFile with file: \(file) !...")
                    print("Error: \(error)")
                }

            } catch let error as NSError {
                print ("Couldn't create an AVAudioFile with file: \(file) !...")
                print("Error: \(error)")
            }
        } else {
            print("Cannot create a valid nsurl with file:\(file)")
        }
        //
        try! self.init (AKAudioFile: akAudioFile! , completionHandler: completionHandler)
    }


    // MARK: - public func

    public func start() {

        if (!playing)  {
            playing = true
            paused = false
            internalPlayer.play()
            self.currentTimeTimer?.invalidate()
            self.currentTimeTimer = nil
            self.currentTimeTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(AKAudioPlayer.timerPlayerHead), userInfo: nil, repeats: true)
            RunLoop.current().add(self.currentTimeTimer!, forMode: RunLoopMode.commonModes)
        }

    }

    /// Stop playback
    public func stop() {

        lastCurrentTime = Double(startTime / audioFile.sampleRate)
        playing = false
        paused = false
        internalPlayer.stop()
        setPCMBuffer()
        scheduleBuffer()

    }

    /// Pause playback
    public func pause() {
        lastCurrentTime = currentTime
        playing = false
        paused = true
        internalPlayer.pause()
        self.currentTimeTimer?.invalidate()
        self.currentTimeTimer = nil
    }


    /// resets in and out times for playing
    public func reloadFile()
    {
       var newAudioFile:AKAudioFile?

        do {
            newAudioFile = try AKAudioFile(fromAVAudioFile: audioFile as AVAudioFile)

        } catch let error as NSError {
            print ("Couldn't reLoadFile !...")
            print("Error: \(error)")

        }
        if newAudioFile != nil {
        audioFile = newAudioFile!
        initialize()
        }
        else{
              print ("Couldn't reLoadFile, newAudioFile is not valid !...")
        }
    }

    /// Replace the current audio file with a new AKAudioFile file
    public func replaceAKAudioFile(_ newAKAudioFile: AKAudioFile) {
        self.audioFile = newAKAudioFile
        let wasPlaying = playing
        playing = false
        internalPlayer.stop()
        internalPlayer.reset()
        initialize()
        if wasPlaying
        {
            play()
        }
    }

    /// To stay compatible with ealier version
    /// Should be deprecated...
    /// (very ugly !)
    /// File is replaced only if a valid AKAudioFile can be instanciated from the file (Path As String)
    public func replaceFile(_ newFile: String) {

        func warnFailed()
        {
            print("Cannot replace with file:\(newFile)")
        }

        let nsurl = URL(string:newFile)
        if nsurl != nil {
            let newAvAudioFile = try? AVAudioFile(forReading: nsurl!)
            if newAvAudioFile != nil
            {
                let  newAKAudioFile = try? AKAudioFile(fromAVAudioFile: newAvAudioFile!)
                if newAKAudioFile != nil
                {
                    replaceAKAudioFile(newAKAudioFile!)
                } else {
                    warnFailed()
                }
            } else {
                warnFailed()
            }
        } else {
            warnFailed()
        }
    }

    /*
     /// Play the file back from a certain time to an end time (if set)
     ///
     /// - parameter time: Time into the file at which to start playing back
     /// - parameter endTime: Time into the file at which to playing back will stop / Loop
     ///
     */
    public func playFrom(_ time: Double, to endTime:Double = 0) {

        if endTime > 0
        {
            self.endTime = endTime

        }

        self.startTime = time

        if (endingFrame > startingFrame ){
            stop()
            play()
            self.currentTimeTimer?.invalidate()
            self.currentTimeTimer = nil
            self.currentTimeTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(AKAudioPlayer.timerPlayerHead), userInfo: nil, repeats: true)
            RunLoop.current().add(self.currentTimeTimer!, forMode: RunLoopMode.commonModes)
        }
        else {
            print("ERROR AKaudioPlayer:  cannot play, \(audioFile.fileNameWithExtension) is empty or segment is too short!")
        }
    }


    // MARK: - private funcs

    private func initialize(){


        totalFrameCount = UInt32(audioFile.length)
        startingFrame = 0
        endingFrame = totalFrameCount

        // Warning if file's samplerate don't match with AKSettings.samplesRate
        if audioFile.sampleRate != AKSettings.sampleRate
        {
            print ("AKAudioPlayer Warning:  \"\(audioFile.fileNameWithExtension)\" has a different sample rate from AudioKit's Settings !")

            print ("Audio will be played at a bad pitch/speed, in / out time will not be set properly !")
        }

        // stop will reset PCMbuffer and scheduleBuffer
        if audioFile.length > 0
        {
            self.stop()

        } else {
            print ("AKAudioPlayer Warning:  \"\(audioFile.fileNameWithExtension)\" is an empty file")
        }
    }

    private func scheduleBuffer(){
        if audioFileBuffer != nil {
            internalPlayer.scheduleBuffer(audioFileBuffer!, completionHandler: internalCompletionHandler)
        }
    }

    private func setPCMBuffer()
    {
        if audioFile.length > 0 {
            audioFile.framePosition = Int64(startingFrame)
            framesToPlayCount = endingFrame - startingFrame
            audioFileBuffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(totalFrameCount) )
            do {
                try audioFile.read(into: audioFileBuffer!, frameCount: framesToPlayCount)
            } catch {
                print("ERROR AKaudioPlayer: Could not read data into buffer.")
                return
            }
        }
    }
    
    /// Triggered when the player stops playing
    private func internalCompletionHandler()
    {
        if playing{
            if looping {
                scheduleBuffer()
            } else {
                self.currentTimeTimer?.invalidate()
                self.currentTimeTimer = nil
                stop()
                completionHandler?()
                self.delegate?.playerStoppedOrFinished?()
            }
        }
    }
    
    
}
