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
    var isReadyToPlay: Bool = true
    var startTime: Float = 0.00
    let songProcessor = SongProcessor.sharedInstance
    
    var song: MPMediaItem? {
        didSet {
            
            if song!.valueForProperty(MPMediaItemPropertyArtistPersistentID)!.integerValue !=
                songProcessor.currentSong?.valueForProperty(MPMediaItemPropertyArtistPersistentID)!.integerValue {
                
                songProcessor.audioFilePlayer?.stop()
                songProcessor.isPlaying = false
                songProcessor.currentSong = song!
                startTime = 0
                exportSong(song!)
                
            } else { // the same song again.
                isReadyToPlay = true
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
    
    @IBAction func play(sender: UIButton) {
        
        if isReadyToPlay == false {
            print("Not Ready", terminator: "")
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
            print("exportPath: \(exportPath)", terminator: "")
            print("File does not exist.", terminator: "")
            return
        }
        
        playButton.hidden = false
        
        songProcessor.audioFile = try? AKAudioFile(readFileName: "exported.wav", baseDir: .Documents)
        
        let _ = try? songProcessor.audioFilePlayer?.replaceFile(songProcessor.audioFile!)
        
    }
    
    func exportSong(song: MPMediaItem) {
        
        isReadyToPlay = false
        
        let docDirs: [NSString] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = docDirs[0]
        let tmp = docDir.stringByAppendingPathComponent("exported") as NSString
        exportPath = tmp.stringByAppendingPathExtension("wav")!
        
        let url = song.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        let songAsset = AVURLAsset(URL: url, options: nil)
        
        var assetError: NSError?
        
        do {
            let assetReader = try AVAssetReader(asset: songAsset)
            
            // Create an asset reader ouput and add it to the reader.
            let assetReaderOutput = AVAssetReaderAudioMixOutput(audioTracks: songAsset.tracks,
                                                                audioSettings: nil)
            
            if !assetReader.canAddOutput(assetReaderOutput) {
                print("Can't add reader output...die!", terminator: "")
            } else {
                assetReader.addOutput(assetReaderOutput)
            }
            
            // If a file already exists at the export path, remove it.
            if NSFileManager.defaultManager().fileExistsAtPath(exportPath) {
                print("Deleting said file.", terminator: "")
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(exportPath)
                } catch _ {
                }
            }
            
            // Create an asset writer with the export path.
            let exportURL = NSURL.fileURLWithPath(exportPath)
            let assetWriter: AVAssetWriter!
            do {
                assetWriter = try AVAssetWriter(URL: exportURL, fileType: AVFileTypeCoreAudioFormat)
            } catch let error as NSError {
                assetError = error
                assetWriter = nil
            }
            
            if assetError != nil {
                print("Error \(assetError)", terminator: "")
                return
            }
            
            // Define the format settings for the asset writer.  Defined in AVAudioSettings.h
            
            // memset(&channelLayout, 0, sizeof(AudioChannelLayout))
            let outputSettings = [ AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
                                   AVSampleRateKey: NSNumber(float: 44100.0),
                                   AVNumberOfChannelsKey: NSNumber(unsignedInt: 2),
                AVLinearPCMBitDepthKey: NSNumber(int: 16),
                AVLinearPCMIsNonInterleaved: NSNumber(bool: false),
                AVLinearPCMIsFloatKey: NSNumber(bool: false),
                AVLinearPCMIsBigEndianKey: NSNumber(bool: false)
            ]
            
            // Create a writer input to encode and write samples in this format.
            let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio,
                                                      outputSettings: outputSettings)
            
            // Add the input to the writer.
            if assetWriter.canAddInput(assetWriterInput) {
                assetWriter.addInput(assetWriterInput)
            } else {
                print("cant add asset writer input...die!", terminator: "")
                return
            }
            
            // Change this property to YES if you want to start using the data immediately.
            assetWriterInput.expectsMediaDataInRealTime = false
            
            // Start reading from the reader and writing to the writer.
            assetWriter.startWriting()
            assetReader.startReading()
            
            // Set the session start time.
            let soundTrack = songAsset.tracks[0]
            let cmtStartTime: CMTime = CMTimeMake(0, soundTrack.naturalTimeScale)
            assetWriter.startSessionAtSourceTime(cmtStartTime)
            
            // Variable to store the converted bytes.
            var convertedByteCount: Int = 0
            var buffers: Float = 0
            
            // Create a queue to which the writing block with be submitted.
            let mediaInputQueue: dispatch_queue_t = dispatch_queue_create("mediaInputQueue", nil)
            
            // Instruct the writer input to invoke a block repeatedly, at its convenience, in
            // order to gather media data for writing to the output.
            assetWriterInput.requestMediaDataWhenReadyOnQueue(mediaInputQueue, usingBlock: {
                
                // While the writer input can accept more samples, keep appending its buffers
                // with buffers read from the reader output.
                while (assetWriterInput.readyForMoreMediaData) {
                    
                    if let nextBuffer = assetReaderOutput.copyNextSampleBuffer() {
                        assetWriterInput.appendSampleBuffer(nextBuffer)
                        // Increment byte count.
                        convertedByteCount += CMSampleBufferGetTotalSampleSize(nextBuffer)
                        buffers += 0.0002
                        
                    } else {
                        // All done
                        assetWriterInput.markAsFinished()
                        assetWriter.finishWritingWithCompletionHandler(){
                            self.isReadyToPlay = true
                            self.playButton.hidden = false
                        }
                        assetReader.cancelReading()
                        break
                    }
                    // Core Foundation objects automatically memory managed in Swift
                    // CFRelease(nextBuffer)
                }
            })
            
        } catch let error as NSError {
            assetError = error
            print("Initializing assetReader Failed", terminator: "")
        }
        
    }
    
}

