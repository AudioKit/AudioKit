//
//  SongViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit
import AVFoundation
import MediaPlayer
import UIKit

class SongViewController: UIViewController {

    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var albumImageView: UIImageView!

    var exportPath: String = ""
    var startTime: Float = 0.00
    let songProcessor = SongProcessor.sharedInstance
    var exporter: SongExporter?

    var song: MPMediaItem? {
        didSet {
            if song?.persistentID != songProcessor.currentSong?.persistentID {

                songProcessor.audioFilePlayer?.stop()
                songProcessor.isPlaying = false
                songProcessor.currentSong = song!
                startTime = 0

            } else { // the same song again.
                exporter?.isReadyToPlay = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let art = songProcessor.currentSong!.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            albumImageView.image = art.image(at: self.view.bounds.size)
        }

        if songProcessor.isPlaying! {
            playButton.setTitle("Pause", for: UIControlState())
        } else {
            if exporter?.isReadyToPlay == false {
                playButton.setTitle("Loading", for: UIControlState())
            }
            playButton.setTitle("Play", for: UIControlState())

        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let docDirs: [NSString] = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                      .userDomainMask,
                                                                      true) as [NSString]
        let docDir = docDirs[0]
        let tmp = docDir.appendingPathComponent("exported") as NSString
        exportPath = tmp.appendingPathExtension("wav")!

        exporter = SongExporter(exportPath: exportPath)
        print("Exporting song")
        exporter?.exportSong(song!)
    }

    @IBAction func play(_ sender: UIButton) {
        /*
        if exporter?.isReadyToPlay == false {
            print("Not Ready")
            playButton.setTitle("Loading", for: UIControlState())
        } else {
            playButton.setTitle("Play", for: UIControlState())
        }
        */
        if sender.titleLabel!.text == "Play" {
            loadSong()
            playButton.setTitle("Stop", for: UIControlState())
            songProcessor.audioFilePlayer!.play()
            songProcessor.isPlaying = true

        } else {
            playButton.setTitle("Play", for: UIControlState())
            songProcessor.audioFilePlayer!.stop()
            songProcessor.isPlaying = false
        }
    }

    func loadSong() {

        if FileManager.default.fileExists(atPath: exportPath) == false {
            print("exportPath: \(exportPath)")
            print("File does not exist.")
            return
        }

        playButton.isHidden = false

        songProcessor.audioFile = try? AKAudioFile(readFileName: "exported.wav", baseDir: .documents)

        try? songProcessor.audioFilePlayer?.replace(file: songProcessor.audioFile!)

    }

}
