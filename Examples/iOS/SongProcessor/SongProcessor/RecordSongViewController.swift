//
//  ViewController.swift
//  SongProcessor
//
//  Created by Kanstantsin Linou on 6/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation

class RecordSongViewController: UIViewController {
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var stopRecordingButton: UIButton!
    var songRecorder: AKMagneto!
    var mic: AKMicrophone!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(for: PlayerState.Stopped)
    }
    @IBAction func recordSong(sender: UIButton) {
        recordingButton.setTitle("Recording in process", forState: .Normal)
        updateUI(for: PlayerState.Playing)
        mic = AKMicrophone()
        AudioKit.output = mic
        AudioKit.start()
        try! songRecorder = AKMagneto()
        songRecorder.record()
    }
    @IBAction func stopRecordSong(sender: UIButton) {
        recordingButton.setTitle("Tap to Record", forState: .Normal)
        updateUI(for: PlayerState.Stopped)
        songRecorder.stopRecord()
        AudioKit.stop()
        self.performSegueWithIdentifier("stop", sender: songRecorder.audioFile.url)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stop") {
            let playSongVC = segue.destinationViewController as! PlaySongViewController
            let recordedSongURL = sender as! NSURL
            playSongVC.recordedSongURL = recordedSongURL
        }
    }
    
    func updateUI(for state: PlayerState) {
        switch state {
        case .Playing:
            recordingButton.enabled = false
            stopRecordingButton.enabled = true
        case .Stopped:
            recordingButton.enabled = true
            stopRecordingButton.enabled = false
        }
    }
}

