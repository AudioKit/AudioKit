//
//  ViewController.swift
//  LoopbackRecording
//
//  Created by David O'Neill on 5/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

/**

 ------      README      ------


 To use, press the button and listen.
 The metronome will begin to play.
 The recorder will tap the mic and record the loopback audio for two loops.
 After the two loops are complete, the clip player's position will be set to four loops, and the loopback will be scheduled to start at excatly 4 loops from original start time.  The less you can hear it the better!
 Wait for the fourth loop to start and observe the loopback recording being played at the same time.
 There will also be a reference recording for comparison, where the metronome is recorded directly, rather than through device io loopback.
 Both files are saved in documents directory, so you can access through iTunes file sharing.
 If using headphones, hold them to the mic for the first two loops, then hold them to your ear for the rest.

 */

class ViewController: UIViewController {

    var metronome = AKSamplerMetronome()
    var mixer = AKMixer()
    var loopBackRecorder: AKClipRecorder?
    var directRecorder: AKClipRecorder?
    var player = AKClipPlayer()
    let comparisonViewController: CompareViewController = {
        let vc = CompareViewController()
        vc.slider.addTarget(self, action: #selector(sliderAction(slider:)), for: .valueChanged)
        return vc
    }()

    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonAction(button:event:)), for: .touchDown)
        button.setTitle("Button", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.backgroundColor = UIColor.yellow
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        FileManager.emtpyDocumentsDirectory()

        AVAudioSession.sharedInstance().requestRecordPermission { canRecord in
            if canRecord {
                self.setUpAudio()
            } else {
                fatalError("Recorder needs to record")
            }
        }

        view.addSubview(button)
        self.addChild(comparisonViewController)
        comparisonViewController.view.isHidden = true
        view.addSubview(comparisonViewController.view)
        comparisonViewController.didMove(toParent: self)

    }

    func setUpAudio() {

        do {
            AKSettings.audioInputEnabled = true
            AKSettings.defaultToSpeaker = true
            AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
            try AKSettings.setSession(category: .playAndRecord)


            // Measurement mode can have an effect on latency.  But you end up having to boost everything.
            // It's a must if you want accurate recordings.  It turns of the os input processing.
            // Uncomment / Experiment

            // try AKSettings.session.setMode(AVAudioSession.Mode.measurement)


        } catch {
            fatalError(error.localizedDescription)
        }

        // Make connections
        metronome.connect(to: mixer.inputNode)
        player.connect(to: mixer.inputNode)
        AudioKit.output = mixer

        // Set up recorders
        loopBackRecorder = AKClipRecorder(node: AudioKit.engine.inputNode)
        directRecorder = AKClipRecorder(node: metronome)

        do { try AudioKit.start() } catch {
            fatalError(error.localizedDescription)
        }

        // Hello beep
        metronome.startNote(0, withVelocity: 60, onChannel: 0)
        metronome.startNote(1, withVelocity: 60, onChannel: 0)
    }

    @objc func buttonAction(button: UIButton, event: UIEvent) {

        // Not needed for this demo, just demonstrating how to get a touch event time
        // into a valid AVAudioTime - Just in case it helps ;)
        _ = AVAudioTime(hostTime: UInt64(event.timestamp * secondsToTicks))

        // This gives us a reference time in the very near past to work with, and it gets right in to
        // what complicates ios audio io. The sampleTime of the input render timestamp (mic), and the sampleTime
        // of the rest of the nodes' timestamps don't share the same base; they might be off by millions of
        // samples.  However, the hostTime of all of the timestamps share the same base, so we'll use it.
        guard let lastRenderHostTime = mixer.avAudioNode.lastRenderTime?.hostTime else { fatalError("Engine not running!") }

        let audioSession = AKSettings.session
        let bufferDurationTicks = UInt64(audioSession.ioBufferDuration * secondsToTicks)
        let outputLatencyTicks = UInt64(audioSession.outputLatency * secondsToTicks)
        let inputLatencyTicks = UInt64(audioSession.inputLatency * secondsToTicks)

        // We have to schedule the audio to play on the next render, since we missed the last one.
        let nextRenderHostTime = lastRenderHostTime + bufferDurationTicks

        // Since we're dealing with another thread, the next render cycle
        // may have already started, we'll be safer aiming for the one after that.
        let renderAfterNextHostTime = nextRenderHostTime + bufferDurationTicks

        // This is the target time that we will be scheduling around, It should be the hostTime when the
        // first sample "leaves the speaker". Latency is only added here because we will be subtracting
        // it from the playback start time, and we don't want to start any earlier than two buffers
        // in the furture.
        let startTimeHost = renderAfterNextHostTime + outputLatencyTicks

        // In order to have audio leave the speaker at start time, we adjust the metronome start
        // back in time to compensate for hardware output latency.
        let playbackStartTime = AVAudioTime(hostTime: startTimeHost - outputLatencyTicks)

        // In order to record audio entering the microphone at startTime, we need to adjust the
        // recorder start forward in time to compensate for hardware input latency.
        let recordingStartTime = AVAudioTime(hostTime: startTimeHost + inputLatencyTicks)

        metronome.beatTime = 0
        loopBackRecorder?.currentTime = 0
        directRecorder?.currentTime = 0

        // MeasurementMode is really quiet.  AKClipRecorder.recordClip takes an optional tap where you can
        // read and write to the data before it's written to file.  We'll use that to boost if in MeasurementMode.
        let tap = convertFromAVAudioSessionMode(audioSession.mode) != convertFromAVAudioSessionMode(AVAudioSession.Mode.measurement) ? nil : { (buffer: AVAudioPCMBuffer, time: AVAudioTime) in
            guard let channels = buffer.floatChannelData else { return }
            for c in 0..<Int(buffer.format.channelCount) {
                for i in 0..<Int(buffer.frameLength) {
                    channels[c][i] *= 4 // Credit TAAE - Use X 4 when in Measurement Mode
                }
            }
        }

        var referenceURL: URL?

        // Schedule a clip to record
        let targetDuration = (metronome.tempo / 60)
        try? loopBackRecorder?.recordClip(time: 0, duration: targetDuration, tap: tap) { result in

            switch result {
            case .error(let error):
                AKLog(error)
                return
            case .clip(let clip):
                AKLog("loopback.duration \(clip.duration)")
                AKLog("loopback.StartTime \(clip.startTime)")
                do {
                    let urlInDocs = FileManager.docs.appendingPathComponent("loopback").appendingPathExtension(clip.url.pathExtension)
                    try FileManager.default.moveItem(at: clip.url, to: urlInDocs)
                    AKLog("loopback saved at " + urlInDocs.path)

                    // Schedule 30 loops of the recorderd audio to play
                    let audioFile = try AKAudioFile(forReading: urlInDocs)
                    self.player.clips = (2..<32).map({ i in AKFileClip(audioFile: audioFile,
                                                                       time: Double(i) * targetDuration,
                                                                       offset: 0,
                                                                       duration: targetDuration) })

                    // let another targetDuration go by, then start player in sync.
                    let twoDurationsIn = targetDuration * 2
                    self.player.currentTime = twoDurationsIn
                    // player is playing yet, but it's now ready to start in the future.
                    self.player.start(at: playbackStartTime + twoDurationsIn)

                    // Balance between the metronome, and the loop back recording of the metronome.
                    self.balance = 0.5

                    DispatchQueue.main.asyncAfter(deadline: .now() + targetDuration, execute: {
                        guard let rURL = referenceURL else { return }
                        self.comparisonViewController.slider.value = self.balance
                        self.comparisonViewController.setFiles(file1: try! AKAudioFile(forReading: rURL), file2: audioFile)
                        self.comparisonViewController.view.isHidden = false
                    })

                } catch {
                    AKLog(error)
                }
            }

        }

        // Save direct recording for comparison
        try? directRecorder?.recordClip(time: 0, duration: targetDuration, tap: nil) { result in
            switch result {
            case .error(let error):
                AKLog(error)
                return
            case .clip(let clip):
                AKLog("direct.duration \(clip.duration)")
                AKLog("direct.StartTime \(clip.startTime)")
                do {
                    let urlInDocs = FileManager.docs.appendingPathComponent("direct").appendingPathExtension(clip.url.pathExtension)
                    referenceURL = urlInDocs
                    try FileManager.default.moveItem(at: clip.url, to: urlInDocs)
                    AKLog("Direct saved at " + urlInDocs.path)
                } catch {
                    AKLog(error)
                }
            }
        }

        // Metronome is somehow getting ahead ~1ms, not sure why.  Delaying it is a hack
        // so that we can see the start of the direct waveform.
        let todoDelay = 0.001

        metronome.play(at: playbackStartTime + todoDelay) //
        directRecorder?.start(at: playbackStartTime)
        loopBackRecorder?.start(at: recordingStartTime)

        // It's a one-off!
        button.isHidden = true
    }

    @objc func sliderAction(slider: UISlider) {
        balance = slider.value
    }
    var balance: Float {
        get { return player.volume }
        set {
            player.volume = newValue
            metronome.volume = 1 - newValue
        }
    }
    override func viewDidLayoutSubviews() {
        let b = view.bounds
        button.frame = b.insetBy(dx: b.width / 4, dy: b.height / 4)
        comparisonViewController.slider.value = metronome.volume
        comparisonViewController.view.frame = b
    }

}

// Utility to convert between hostTime (ticks) and seconds.
private let secondsToTicks: Double = {
    var tinfo = mach_timebase_info()
    let err = mach_timebase_info(&tinfo)
    let timecon = Double(tinfo.denom) / Double(tinfo.numer)
    return timecon * 1_000_000_000
}()

extension FileManager {
    static var docs: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    static func emtpyDocumentsDirectory() {
        let fileManager = FileManager.default
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: docs.path)
            for fileName in fileNames {
                try fileManager.removeItem(at: docs.appendingPathComponent(fileName))
            }
        } catch {
            AKLog(error)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionMode(_ input: AVAudioSession.Mode) -> String {
	return input.rawValue
}
