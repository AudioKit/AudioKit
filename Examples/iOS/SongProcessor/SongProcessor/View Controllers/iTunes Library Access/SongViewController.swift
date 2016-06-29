//
//  SongViewController.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/22/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AudioKit

class SongViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var albumImageView: UIImageView!
    
    var exportPath: String = ""
    var startTime: Float = 0.00
    let songProcessor = SongProcessor.sharedInstance
    var exporter: SongExporter?
    
    var song: MPMediaItem? {
        didSet {
            
            if song!.valueForProperty(MPMediaItemPropertyArtistPersistentID)!.integerValue !=
                songProcessor.currentSong?.valueForProperty(MPMediaItemPropertyArtistPersistentID)!.integerValue {
                
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
        
        if let artwork = songProcessor.currentSong!.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            albumImageView.image = artwork.imageWithSize(self.view.bounds.size)
        }
        
        if songProcessor.isPlaying!  {
            playButton.setTitle("Pause", forState: .Normal)
        } else {
            playButton.setTitle("Play", forState: .Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let docDirs: [NSString] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = docDirs[0]
        let tmp = docDir.stringByAppendingPathComponent("exported") as NSString
        exportPath = tmp.stringByAppendingPathExtension("wav")!
        
        exporter = SongExporter(exportPath: exportPath)
        print("Exporting song")
        exporter?.exportSong(song!)
    }
    
    @IBAction func play(sender: UIButton) {
        
        if exporter?.isReadyToPlay == false {
            print("Not Ready")
            return
        }
        
        if sender.titleLabel!.text == "Play" {
            loadSong()
            playButton.setTitle("Stop", forState: .Normal)
            songProcessor.audioFilePlayer!.play()
            songProcessor.isPlaying = true
            
        } else {
            playButton.setTitle("Play", forState: .Normal)
            songProcessor.audioFilePlayer!.stop()
            songProcessor.isPlaying = false
        }
    }
    
    func loadSong() {
        
        if NSFileManager.defaultManager().fileExistsAtPath(exportPath) == false {
            print("exportPath: \(exportPath)")
            print("File does not exist.")
            return
        }
        
        playButton.hidden = false
        
        songProcessor.audioFile = try? AKAudioFile(readFileName: "exported.wav", baseDir: .Documents)
        
        let _ = try? songProcessor.audioFilePlayer?.replaceFile(songProcessor.audioFile!)
        
    }
    

    
}

