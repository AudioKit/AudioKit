//
//  SongExporter.swift
//  SongProcessor
//
//  Created by Aurelius Prochazka on 6/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AudioKit

class SongExporter {
    
    var exportPath: String = ""
    var isReadyToPlay: Bool = true
    
    init(exportPath: String) {
        self.exportPath = exportPath
    }
    
    func exportSong(song: MPMediaItem) {
        
        isReadyToPlay = false
        
        let url = song.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
        let songAsset = AVURLAsset(URL: url, options: nil)
        
        var assetError: NSError?
        
        do {
            let assetReader = try AVAssetReader(asset: songAsset)
            
            // Create an asset reader ouput and add it to the reader.
            let assetReaderOutput = AVAssetReaderAudioMixOutput(audioTracks: songAsset.tracks,
                                                                audioSettings: nil)
            
            if !assetReader.canAddOutput(assetReaderOutput) {
                print("Can't add reader output...die!")
            } else {
                assetReader.addOutput(assetReaderOutput)
            }
            
            // If a file already exists at the export path, remove it.
            if NSFileManager.defaultManager().fileExistsAtPath(exportPath) {
                print("Deleting said file.")
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
                print("Error \(assetError)")
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
                print("cant add asset writer input...die!")
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
                            //                            self.playButton.hidden = false
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
            print("Initializing assetReader Failed")
        }
        
    }
}