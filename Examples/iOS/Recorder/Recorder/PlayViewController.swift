//
//  PlayViewController.swift
//  Recorder
//
//  Created by Kanstantsin Linou on 6/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class PlayViewController: UIViewController {
    
    @IBOutlet var playingButton: UIButton!
    @IBOutlet var stopPlayingButton: UIButton!
    @IBOutlet var cutoffFrequencyLabel: UILabel!
    @IBOutlet var resonanceLabel: UILabel!
    var recordedURL: NSURL!
    var player: AKAudioPlayer!
    var audioFile: AKAudioFile!
    var moogLadder: AKMoogLadder!
    
    
    
    @IBAction func stop(sender: AnyObject) {
        player?.stop()
        updateUI(for: PlayerState.Stopped)
    }
    
    @IBAction func play(sender: AnyObject) {
        player?.play()
        updateUI(for: PlayerState.Playing)
    }
    
    @IBAction func setCutoffFrequency(sender: UISlider) {
        moogLadder.cutoffFrequency = Double(sender.value)
        cutoffFrequencyLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", moogLadder.cutoffFrequency))"
    }
    
    @IBAction func setResonance(sender: UISlider) {
        moogLadder.resonance = Double(sender.value)
        resonanceLabel!.text = "Resonance: \(String(format: "%0.3f", moogLadder.resonance))"
    }
    func playerStoppedOrFinished() {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateUI(for: PlayerState.Stopped)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI(for: PlayerState.Stopped)
        setupFile()
        setupEffects()
    }
    
    func setupFile() {
        do {
            let fileName = (recordedURL.URLByDeletingPathExtension?.lastPathComponent)!
            let fileExtension = (recordedURL.pathExtension)!
            audioFile = try AKAudioFile(forReadingWithFileName: fileName, andExtension: fileExtension, fromBaseDirectory: .Temp)
            player = try? AKAudioPlayer(file: audioFile, completionHandler:  playerStoppedOrFinished)
        } catch {
            print("\((recordedURL.lastPathComponent)!) wasn't found.")
        }
    }
    
    func setupEffects() {
        moogLadder = AKMoogLadder(player)
        AudioKit.output = moogLadder
        AudioKit.start()
    }
    
    func updateUI(for state: PlayerState) {
        switch state {
        case .Playing:
            playingButton.enabled = false
            stopPlayingButton.enabled = true
        case .Stopped:
            playingButton.enabled = true
            stopPlayingButton.enabled = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        AudioKit.stop()
    }
}
