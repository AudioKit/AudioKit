//
//  RecordViewController.swift
//  Recorder
//
//  Created by Kanstantsin Linou on 6/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation

class RecordViewController: UIViewController {
    @IBOutlet var recordingButton: UIButton!
    @IBOutlet var stopRecordingButton: UIButton!
    var recorder: AKNodeRecorder!
    var mic: AKMicrophone!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(for: PlayerState.Stopped)
    }
    @IBAction func record(sender: UIButton) {
        recordingButton.setTitle("Recording in process", forState: .Normal)
        updateUI(for: PlayerState.Playing)
        mic = AKMicrophone()
        AudioKit.output = mic
        AudioKit.start()
        do {
            try recorder = AKNodeRecorder()
            try recorder.record()
        } catch {
            print("Recording failed")
        }
        
    }
    @IBAction func stop(sender: UIButton) {
        recordingButton.setTitle("Record", forState: .Normal)
        updateUI(for: PlayerState.Stopped)
        recorder.stop()
        AudioKit.stop()
        self.performSegueWithIdentifier("stop", sender: recorder.audioFile!.url)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stop") {
            let playVC = segue.destinationViewController as! PlayViewController
            let recordedURL = sender as! NSURL
            playVC.recordedURL = recordedURL
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

