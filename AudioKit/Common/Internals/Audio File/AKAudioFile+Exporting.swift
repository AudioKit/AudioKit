//
//  AKAudioFile+Exporting.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka and Laurent Veliscek on 7/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

extension AKAudioFile {
    
    /**
     ExportFormat enum to set target format when exporting AKAudiofiles
     
     - wav
     - aif
     - mp4
     - m4a
     - caf
     
     Ex: let outputFormat = AKAudioFile.ExportFormats.aif
     
     */
    public enum ExportFormat {
        /// Waveform Audio File Format (WAVE, or more commonly known as WAV due to its filename extension)
        case wav
        
        /// Audio Interchange File Format
        case aif
        
        /// MPEG-4 Part 14 Compression
        case mp4
        
        /// MPEG 4 Audio
        case m4a
        
        /// Core Audio Format
        case caf
        
        // Returns a Uniform Type identifier for each audio file format
        private var UTI: CFString {
            switch self {
            case wav: return AVFileTypeWAVE
            case aif: return AVFileTypeAIFF
            case mp4: return AVFileTypeAppleM4A
            case m4a: return AVFileTypeAppleM4A
            case caf: return AVFileTypeCoreAudioFormat
            }
        }
        
        // Returns available Export Formats as an Array of Strings
        static var arrayOfStrings: [String] {
            return ["wav", "aif", "mp4", "m4a", "caf"]
        }
    }

    /**
     Exports to a new AKAudiofile with trimming options:
     Can export from wav/aif to wav/aif/m4a/mp4
     Can export from m4a/mp4 to m4a/mp4
     Exporting from mp4/m4a to wav/aif is not supported.
     
     inTime and outTime can be set to extract only a portion of the current AKAudioFile.
     If outTime is zero, it will be set to the file's duration (no end trimming)
     
     
     - Parameters:
       - name: the name of the file without its extension (String).
       - ext: the output file formal as an ExportFormat enum value (.aif, .wav, .m4a, .mp4, .caf)
       - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
       - callBack: AKCallback function that will be triggered when export completed.
       - inTime: start range time value in seconds
       - outTime: end range time value in seconds.
     
     - Throws: NSError if init failed .
     
     - Returns: An AKAudioFile ExportSession object, or nil if init failed.
     
     As soon as callback has been triggered, you can use ExportSession.status to check if export succeeded or not. If export succeeded, you can get the exported AKAudioFile using ExportSession.exportedAudioFile. ExportSession.progress lets you monitor export progress.
     
     See playground for an example of use.
     
     */
    public func export(
        name: String,
        ext: ExportFormat,
        baseDir: BaseDirectory,
        callBack: (AKCallback),
        inTime: Double = 0,
        outTime: Double  = 0 ) throws -> ExportSession {
        
        let fromFileExt = fileExt.lowercaseString
        
        // Only mp4, m4a, .wav, .aif can be exported...
        guard   ExportFormat.arrayOfStrings.contains(fromFileExt) else {
            print( "ERROR: AKAudioFile  \".\(fromFileExt)\" is not supported for export!...")
            throw NSError(domain: NSURLErrorDomain, code: NSFileWriteUnsupportedSchemeError, userInfo: nil)
        }
        
        
        // Compressed formats cannot be exported to PCM
        let fromFileFormatIsCompressed: Bool  = (fromFileExt == "m4a" || fromFileExt == "mp4")
        let outFileFormatIsCompressed: Bool  = (ext == .mp4 || ext == .m4a )
        
        // set avExportPreset
        var avExportPreset: String
        
        if fromFileFormatIsCompressed {
            if !outFileFormatIsCompressed {
                print( "ERROR AKAudioFile: cannot convert from .\(fileExt) to .\(String(ext))!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            } else {
                avExportPreset = AVAssetExportPresetPassthrough
            }
        } else {
            if outFileFormatIsCompressed {
                avExportPreset = AVAssetExportPresetAppleM4A
            } else {
                avExportPreset = AVAssetExportPresetPassthrough
            }
        }
        
        
        return try ExportSession(fileName: name,
                                 baseDir: baseDir,
                                 callBack: callBack,
                                 presetName: avExportPreset,
                                 file: self,
                                 outputFileExtension:ext,
                                 from: inTime,
                                 to: outTime)
    }
    
    /**
     
     ExportSession wraps an AVAssetExportSession. It is returned by AKAudioFile.export().
     The benefit of this object is that you directly gets the resulting AKAudioFile
     if export succeeded. Most AVAssetExportSession properties/methods have been
     re-implemented as public.
     
     See playground for an example of use.
     
     */
    public class ExportSession {
        
        private var outputAudioFile: AKAudioFile?
        private var exporter: AVAssetExportSession
        private var callBack: AKCallback
        
        /// Initalization
        ///
        /// - Parameters:
        ///   - fileName:            Name of the file
        ///   - baseDir:             Base directory
        ///   - callBack:            Callback function
        ///   - presetName:          Name of the preset
        ///   - file:                AKAudioFile
        ///   - outputFileExtension: Extension to use for output
        ///   - inTime:              Starting time
        ///   - outTime:             Ending time
        ///
        /// - throws: NSError if failed
        ///
        public init(fileName: String, baseDir: BaseDirectory,
                    callBack: AKCallback,
                    presetName: String,
                    file: AKAudioFile,
                    outputFileExtension: ExportFormat,
                    from inTime: Double,
                         to outTime: Double) throws {
            
            self.callBack = callBack
            
            let assetUrl = file.url
            let asset  = AVURLAsset(URL: assetUrl)
            
            // let asset = file.avAsset
            
            let process = AVAssetExportSession(asset: asset, presetName:presetName)
            
            guard process != nil else {
                print( "ERROR AKAudioFile export: cannot create an AVAssetExportSession!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
            }
            exporter = process!
            
            guard file.samplesCount > 0 else {
                print( "ERROR AKAudioFile export: cannot export an empty file !...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
            }
            
            
            
            var filePath: String
            switch baseDir {
            case .Temp:
                filePath =  (NSTemporaryDirectory() as String) + fileName + "." + String(outputFileExtension)
            case .Documents:
                filePath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) +  "/" + fileName + "." + String(outputFileExtension)
            case .Resources:
                print( "ERROR AKAudioFile export: cannot create a file in applications resources!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
            
            let nsurl = NSURL(string: filePath)
            guard nsurl != nil else {
                print( "ERROR AKAudioFile export: directory \"\(filePath)\" isn't valid!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
            let directoryPath = nsurl!.URLByDeletingLastPathComponent
            // Check if directory exists
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath((directoryPath?.absoluteString)!) == false {
                print( "ERROR AKAudioFile export: directory \"\(directoryPath)\" doesn't exists!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
            
            // Check if out file exists
            if fileManager.fileExistsAtPath((nsurl?.absoluteString)!) {
                // Then delete file
                print ("AKAudioFile export: Output file already exists, trying to delete...")
                do {
                    try fileManager.removeItemAtPath((nsurl?.absoluteString)!)
                } catch let error as NSError {
                    print ("Error !!! AKAudioFile: couldn't delete file \"\(nsurl!)\" !...")
                    print(error.localizedDescription)
                    throw error
                }
                print ("AKAudioFile export: Output file has been deleted !")
            }
            
            exporter.outputURL = NSURL.fileURLWithPath(filePath)
            // Sets the output file encoding (avoid .wav encoded as m4a...)
            exporter.outputFileType = outputFileExtension.UTI as String
            
            // In and OUT times triming settings
            let inFrame: Int64
            let outFrame: Int64
            
            if outTime == 0 {
                outFrame = file.samplesCount
            } else {
                outFrame = min(file.samplesCount, Int64(outTime * file.sampleRate))
            }
            
            inFrame = abs(min(file.samplesCount, Int64(inTime * file.sampleRate)))
            
            if (outFrame <= inFrame) {
                print( "ERROR AKAudioFile export: In time must be less than Out time!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
            }
            let startTime = CMTimeMake(inFrame, Int32(file.sampleRate))
            let stopTime = CMTimeMake(outFrame, Int32(file.sampleRate))
            let timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            exporter.timeRange = timeRange
            
            // Everything is fine, we can export...
            exporter.exportAsynchronouslyWithCompletionHandler(internalCompletionHandler)
        }
        
        private func internalCompletionHandler () {
            switch exporter.status {
            case  AVAssetExportSessionStatus.Failed:
                print("ERROR AKAudioFile: Export Failed!...")
                print("Error: \(exporter.error)")
            case AVAssetExportSessionStatus.Cancelled:
                print("ERROR AKAudioFile: Export Cancelled!...")
                print("Error: \(exporter.error)")
            default:
                // Export succeeded !
                // We create an AKAudioFile from the exported audioFile
                let url = NSURL(string: exporter.outputURL!.path!)
                do {
                    outputAudioFile = try AKAudioFile(forReading: url!)
                } catch let error as NSError {
                    print("ERROR AKAudioFile export: Couldn't create AKAudioFile with url: \"\(url)\" !...")
                    print(error.localizedDescription)
                }
                
                callBack()
            }
        }
        
        /// True if export succeeded...
        public var succeeded: Bool {
            return exporter.status == .Completed
        }
        
        /// True if export failed...
        public var failed: Bool {
            return exporter.status == .Failed
        }
        
        /** status returns current exporter status:
         enum AVAssetExportSessionStatus : Int {
         case Unknown
         case Waiting
         case Exporting
         case Completed
         case Failed
         case Cancelled
         }
         */
        public var status: AVAssetExportSessionStatus {
            return exporter.status
        }
        
        /// Progress of export process as a Float from 0 to 1,
        /// a value of 1 means 100% completed.
        public var progress: Float {
            return exporter.progress
        }
        
        /// Returns the exported file as an AKAudioFile if export suceeded.
        public var exportedAudioFile: AKAudioFile? {
            return outputAudioFile
        }
        
        /// Return the error as a NSError if an error occured...
        public var error: NSError? {
            return exporter.error
        }
        
        /// To cancel export
        public func cancelExport() {
            exporter.cancelExport()
        }
    }
}