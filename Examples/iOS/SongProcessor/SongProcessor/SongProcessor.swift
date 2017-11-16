//
//  SongProcessor.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer

class SongProcessor: NSObject, UIDocumentInteractionControllerDelegate {

    static let sharedInstance = SongProcessor()

    var iTunesFilePlayer: AKAudioPlayer?
    var variableDelay = AKDelay()  //Was AKVariableDelay, but it wasn't offline render friendly!
    var delayMixer = AKDryWetMixer()
    var moogLadder = AKMoogLadder()
    var filterMixer = AKDryWetMixer()
    var reverb = AKCostelloReverb()
    var reverbMixer = AKDryWetMixer()
    var pitchShifter = AKPitchShifter()
    var pitchMixer = AKDryWetMixer()
    var bitCrusher = AKBitCrusher()
    var bitCrushMixer = AKDryWetMixer()
    var playerBooster = AKBooster()
    var offlineRender = AKOfflineRenderNode()
    var players = [String: AKAudioPlayer]()
    var playerMixer = AKMixer()

    fileprivate var docController: UIDocumentInteractionController?

    var iTunesPlaying: Bool {
        set {
            if newValue {
                guard let iTunesFilePlayer = iTunesFilePlayer else { return }
                if !iTunesFilePlayer.isPlaying { iTunesFilePlayer.play() }
            } else {
                iTunesFilePlayer?.stop()
            }
        }
        get {
            return iTunesFilePlayer?.isPlaying ?? false
        }
    }
    var loopsPlaying: Bool {
        set {
            if newValue {
                guard let firtPlayer = players.values.first else { return }
                if !firtPlayer.isPlaying { playLoops() }
            } else {
                stopLoops()
            }
        }
        get {
            return players.values.first?.isPlaying ?? false
        }
    }

    override init() {
        super.init()
        for name in ["bass", "drum", "guitar", "lead"] {
            do {
                let audioFile = try AKAudioFile(readFileName: name+"loop.wav", baseDir: .resources)
                players[name] = try AKAudioPlayer(file: audioFile, looping: true)
                players[name]?.connect(to: playerMixer)
            } catch {
                fatalError(String(describing: error))
            }
        }

        playerMixer >>>
            delayMixer >>>
            filterMixer >>>
            reverbMixer >>>
            pitchMixer >>>
            bitCrushMixer >>>
            playerBooster >>>
        offlineRender

        AudioKit.output = offlineRender

        playerMixer >>> variableDelay >>> delayMixer.wetInput
        delayMixer >>> moogLadder >>> filterMixer.wetInput
        filterMixer >>> reverb >>> reverbMixer.wetInput
        reverbMixer >>> pitchShifter >>> pitchMixer.wetInput
        pitchMixer >>> bitCrusher >>> bitCrushMixer.wetInput

        // Allow the app to play in the background
        do {
            try AKSettings.setSession(category: .playback, with: .mixWithOthers)
        } catch {
            print("error")
        }
        AKSettings.playbackWhileMuted = true

        AudioKit.output = offlineRender
        initParameters()
        AudioKit.start()

    }
    func initParameters() {

        delayMixer.balance = 0
        filterMixer.balance = 0
        reverbMixer.balance = 0
        pitchMixer.balance = 0

        bitCrushMixer.balance = 0
        bitCrusher.bitDepth = 16
        bitCrusher.sampleRate = 3_333

        //Booster for Volume
        playerBooster.gain = 0.5
    }

    func rewindLoops() {
        playersDo { $0.schedule(from: 0, to: $0.duration, avTime: nil)}
    }
    func playLoops(at when: AVAudioTime? = nil) {
        let startTime = when ?? SongProcessor.twoRendersFromNow()
        playersDo { $0.play(at: startTime) }
    }
    func stopLoops() {
        playersDo { $0.stop() }
    }
    func playersDo(_ action: @escaping (AKAudioPlayer) -> Void) {
        for player in players.values { action(player) }
    }
    private class func twoRendersFromNow() -> AVAudioTime {
        let twoRenders = AVAudioTime.hostTime(forSeconds: AKSettings.bufferLength.duration * 2)
        return AVAudioTime(hostTime: mach_absolute_time() + twoRenders)
    }

    enum ShareTarget {
        case iTunes
        case loops
    }

    fileprivate func mixDownItunes(url: URL) throws {

        offlineRender.internalRenderEnabled = false

        guard let player = iTunesFilePlayer else {
            offlineRender.internalRenderEnabled = true
            throw NSError(domain: "SongProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Target itunes but no player exists"])
        }
        let duration = player.duration
        player.schedule(from: 0, to: duration, avTime: nil)
        let timeZero = AVAudioTime(sampleTime: 0, atRate: offlineRender.avAudioNode.inputFormat(forBus: 0).sampleRate)

        player.play(at:timeZero)
        try offlineRender.renderToURL(url, seconds: duration)
        player.stop()
        offlineRender.internalRenderEnabled = true

    }
    fileprivate func mixDownLoops(url: URL, loops: Int) throws {

        offlineRender.internalRenderEnabled = false

        guard let player = players.values.first else {
            offlineRender.internalRenderEnabled = true
            throw NSError(domain: "SongProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "No loop players!"])
        }
        let duration = player.duration * Double(loops)
        let timeZero = AVAudioTime(sampleTime: 0, atRate: offlineRender.avAudioNode.inputFormat(forBus: 0).sampleRate)
        rewindLoops()
        playLoops(at: timeZero)
        try offlineRender.renderToURL(url, seconds: duration)
        rewindLoops()
        stopLoops()
        offlineRender.internalRenderEnabled = true

    }
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        docController = nil
        guard let url = controller.url else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            do { try FileManager.default.removeItem(at: url) } catch {
                print(error)
            }
        }
    }
    var mixDownURL: URL = {
        let tempDir = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDir.appendingPathComponent("mixDown.m4a")
    }()
}

extension UIViewController {
    func renderAndShare(completion: @escaping (UIDocumentInteractionController?) -> Void) {
        let songProcessor = SongProcessor.sharedInstance
        let url = songProcessor.mixDownURL

        let cleanup: (Error) -> Void = { error in
            if FileManager.default.fileExists(atPath: url.path) {
                do { try FileManager.default.removeItem(at: url) } catch {
                    print(error)
                }
            }
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            self.present(alert, animated: true, completion: {completion(nil)})
        }

        let success = {
            let docController = UIDocumentInteractionController(url: url)
            docController.delegate = songProcessor
            songProcessor.docController = docController
            completion(docController)
        }

        let shareLoops = {
            let alert = UIAlertController(title: "How many loops?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.keyboardType = .decimalPad
                textField.text = String(1)
            }
            alert.addAction(.init(title: "OK", style: .default, handler: { (_) in
                let text = alert.textFields?.first?.text
                guard let countText = text,
                    let count = Int(countText),
                    count > 0 else {

                        let message = text == nil ? "Need a count" : text! + " isn't a vaild loop count!"
                        cleanup(NSError(domain: "SongProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: message]))
                        return
                }
                do {
                    try songProcessor.mixDownLoops(url: url, loops: count)
                    success()

                } catch {
                    cleanup(error)
                }

            }))
            alert.addAction(.init(title: "Cancel", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }

        if songProcessor.iTunesFilePlayer != nil {
            let alert = UIAlertController(title: "Export Song or Loops?", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Song", style: .default, handler: { (_) in
                do {
                    try songProcessor.mixDownItunes(url: url)
                    success()
                } catch {
                    cleanup(error)
                }
            }))
            alert.addAction(.init(title: "Loops", style: .default, handler: { (_) in
                shareLoops()
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel, handler:nil))
            present(alert, animated: true, completion: nil)
        } else {
            shareLoops()
        }

    }

    func alertForShareFail() -> UIAlertController {
        let message = TARGET_OS_SIMULATOR == 0 ? nil : "Try using a device instead of the simulator :)"
        let alert = UIAlertController(title: "No Applications to share with", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        return alert
    }

}
