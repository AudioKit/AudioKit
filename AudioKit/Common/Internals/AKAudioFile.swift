//
//  AKAudioFile.swift
//  AudioKit For iOS
//
//  Created by Laurent Veliscek on 08/06/2016.
//  Credits to Gene de Lisa (http://www.rockhoppertech.com/blog/)
//  who helped me a lot providing his tutos...
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Audio file, inherits from AVAudioFile and adds functionality
public class AKAudioFile: AVAudioFile {
    
    // MARK: - embedded enums
    
    /**
     BaseDirectory enum

     - Temp: Temp Directory.
     - Documents: Documents Directory
     - Resources: Resources Directory (Shouldn't be used for writing / recording files).
     
     Ex: let directory = AKAudioFile.BaseDirectory.Temp

     */
    public enum BaseDirectory {
        case Temp
        case Documents
        case Resources
    }
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
        case wav
        case aif
        case mp4
        case m4a
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
    
    // MARK: - private vars

    // Used for exporting, can be accessed with public .avAsset property
    private lazy var internalAVAsset: AVURLAsset = {
        let avAssetUrl = NSURL(fileURLWithPath:self.url.absoluteString)
        return  AVURLAsset(URL: avAssetUrl)
    }()
    
    
    // MARK: - super.inits !

    /**
     Super.init inherited from AVAudioFile superclass

     - Parameter fileURL: NSURL of the file.

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile object for reading, or nil if init failed.

     */
    public override init(forReading fileURL: NSURL) throws {
        try super.init(forReading: fileURL)
    }

    /**
     Super.init inherited from AVAudioFile superclass

     - Parameters: 
        - fileURL: NSURL of the file.
        - format: The processing commonFormat to use when reading from the file.
        - interleaved: Bool (Whether to use an interleaved processing format.)

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile object for reading, or nil if init failed.

     */
    public override init(forReading fileURL: NSURL,
                          commonFormat format: AVAudioCommonFormat,
                          interleaved: Bool) throws {
        
        try super.init(forReading: fileURL, commonFormat: format, interleaved: interleaved)
    }

    /**
     Super.init inherited from AVAudioFile superclass

     - Parameters:
        - fileURL: NSURL of the file.
        - settings: The format of the file to create.
        - format: The processing commonFormat to use when writing.
        - interleaved: Bool (Whether to use an interleaved processing format.)

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile for writing, or nil if init failed.

     From Apple doc: The file type to create is inferred from the file extension of fileURL.
     This method will overwrite a file at the specified URL if a file already exists.

     The file is opened for writing using the standard format, AVAudioPCMFormatFloat32.

     Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
     with a floating Point encoding. As a consequence, such files will fail to record properly.
     So it's better to use .caf (or .aif) files for recording purpose.
     
     */

    public override init(forWriting fileURL: NSURL,
                          settings: [String : AnyObject],
                          commonFormat format: AVAudioCommonFormat,
                          interleaved: Bool) throws {
        try super.init(forWriting: fileURL,
                       settings: settings,
                       commonFormat: format,
                       interleaved: interleaved)
    }


    /**
     Super.init inherited from AVAudioFile superclass

     - Parameters:
        - fileURL: NSURL of the file.
        - settings: The settings of the file to create.

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile for writing, or nil if init failed.
     
     From Apple doc: The file type to create is inferred from the file extension of fileURL.
     This method will overwrite a file at the specified URL if a file already exists.

     The file is opened for writing using the standard format, AVAudioPCMFormatFloat32.
     
     Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
     with a floating Point encoding. As a consequence, such files will fail to record properly.
     So it's better to use .caf (or .aif) files for recording purpose.

     */
    public override init(forWriting fileURL: NSURL, settings: [String:AnyObject]) throws {
        try super.init(forWriting: fileURL, settings: settings)
    }


    // MARK: - convenience inits


    /**
     Opens a file for reading.

     - Parameters:
     - name: the name of the file without its extension (String).
     - baseDir: where the file is located, can be set to .Resources,  .Documents or .Temp

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile for reading, or nil if init failed.

    */
    public convenience init(readFileName name: String,
                            baseDir: BaseDirectory = .Resources) throws {
        
        let filePath: String
        let fileNameWithExtension = name
        
        switch baseDir {
        case .Temp:
            filePath =  (NSTemporaryDirectory() as String) + "/" + name
        case .Documents:
            filePath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) + "/" + name
        case .Resources:
            func resourcePath(name: String?) -> String? {
                return NSBundle.mainBundle().pathForResource(name, ofType: "")
            }
            let path =  resourcePath(name)
            if path == nil {
                print( "ERROR: AKAudioFile cannot find \"\(name)\" in resources!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil)
            }
            filePath = path!
            
        }
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            let fileUrl = NSURL(string: filePath)
            
            do {
                try self.init(forReading: fileUrl!)
            } catch let error as NSError {
                print ("Error !!! AKAudioFile: \"\(name)\" doesn't seem to be a valid AudioFile !...")
                print(error.localizedDescription)
                throw error
            }
            
        } else {
            print( "ERROR: AKAudioFile cannot find \"\(name)\"!... aka \(name)")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
        }
    }


    /**
     Converts an AVAudioFile to an AKAudioFile for reading.

     - Parameters:
     - avAudioFile: an AVAudioFile.

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile for reading, or nil if init failed.
     
     */
    public convenience init(readAVAudioFile avAudioFile: AVAudioFile) throws {
        try self.init(forReading: avAudioFile.url)
    }

    /**
     Converts an AVAudioFile to an AKAudioFile for writing.

     - Parameters:
     - avAudioFile: an AVAudioFile.

     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile for writing, or nil if init failed.
     
     */
    public convenience init(writeAVAudioFile avAudioFile: AVAudioFile) throws {
        var avSettings = avAudioFile.processingFormat.settings
        // Avoid a warning complaining about interleavead setting value
        avSettings["AVLinearPCMIsNonInterleaved"] = NSNumber(bool: false)
        try self.init(forWriting: avAudioFile.url, settings: avSettings)
    }
    
    
    /**
     Creates file for recording / writing purpose
     Default is a .caf AKAudioFile with AudioKit settings
     If file name is an empty String, a unique Name will be set
     If no baseDir is set, baseDir will be the Temp Directory


     - Parameters:
        - name: the name of the file without its extension (String).
        - ext: the extension of the file without "." (String).
        - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
        - settings: The settings of the file to create.
        - format: The processing commonFormat to use when writing.
        - interleaved: Bool (Whether to use an interleaved processing format.)


     - Throws: NSError if init failed .

     - Returns: An initialized AKAudioFile for writing, or nil if init failed.

     From Apple doc: The file type to create is inferred from the file extension of fileURL.
     This method will overwrite a file at the specified URL if a file already exists.

     Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
     with a floating Point encoding. As a consequence, such files will fail to record properly.
     So it's better to use .caf (or .aif) files for recording purpose.
     
     Example of use: to create a temp .caf file with a unique name for recording:
     let recordFile = AKAudioFile()
     
     */
    public convenience init(writeIn baseDir: BaseDirectory = .Temp,
        name: String = "",
        ext: String = "caf",
        settings: [String : AnyObject] = AKSettings.audioFormat.settings,
        commonFormat format: AVAudioCommonFormat = AKSettings.audioFormat.commonFormat,
        interleaved: Bool = AKSettings.audioFormat.interleaved) throws {
        
        let fileNameWithExtension: String
        // Create a unique file name if fileName == ""
        if name == "" {
            fileNameWithExtension =  NSUUID().UUIDString + "." + ext
        } else {
            fileNameWithExtension = name + "." + ext
        }
        
        var filePath: String
        switch baseDir {
        case .Temp:
            filePath =  (NSTemporaryDirectory() as String) + "/" + fileNameWithExtension
        case .Documents:
            filePath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) + "/" + fileNameWithExtension
        case .Resources:
            print( "ERROR AKAudioFile: cannot create a file in applications resources!...")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
        
        let nsurl = NSURL(string: filePath)
        guard nsurl != nil else {
            print( "ERROR AKAudioFile: directory \"\(filePath)\" isn't valid!...")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
        let directoryPath = nsurl!.URLByDeletingLastPathComponent
        // Check if directory exists
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath((directoryPath?.absoluteString)!) == false {
            print( "ERROR AKAudioFile: directory \"\(directoryPath)\" doesn't exists!...")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
        
        // AVLinearPCMIsNonInterleaved cannot be set to false (ignored but throw a warning)
        var  fixedSettings =  settings
        fixedSettings[ AVLinearPCMIsNonInterleaved] =  NSNumber(bool: false)
        
        
        try self.init(forWriting: nsurl!, settings: fixedSettings, commonFormat: format, interleaved: interleaved)
    }

    
    // MARK: - Public AKAudioFileFormat Properties
    
    /// The number of samples can be accessed by .length property,
    /// but samplesCount has a less ambiguous meaning
    public var samplesCount: Int64 {
        get {
            return self.length
        }
    }
    
    /// strange that sampleRate is a Double and not an Integer !...
    public var sampleRate: Double {
        get {
            return self.fileFormat.sampleRate
        }
    }
    /// Number of channels, 1 for mono, 2 for stereo...
    public var channelCount: UInt32 {
        get {
            return self.fileFormat.channelCount
        }
    }
    
    /// Duration in seconds
    public var duration: Double {
        get {
            return Double(samplesCount) / (sampleRate)
        }
    }
    
    /// true if Audio Samples are interleaved
    public var interleaved: Bool {
        get {
            return self.fileFormat.interleaved
        }
    }
    
    /// true if file format is "deinterleaved native-endian float (AVAudioPCMFormatFloat32)", otherwise false
    public var standard: Bool {
        get {
            return self.fileFormat.standard
        }
    }
    
    /**  commonFormatString translates commonFormat in an human readable string.
     enum AVAudioCommonFormat : UInt {
     case OtherFormat
     case PCMFormatFloat32
     case PCMFormatFloat64
     case PCMFormatInt16
     case PCMFormatInt32
     }  */
    
    public var commonFormatString: String {
        get {
            
            switch self.fileFormat.commonFormat.rawValue {
            case 1 :
                return "PCMFormatFloat32"
            case 2:
                return "PCMFormatFloat64"
            case 3 :
                return "PCMFormatInt16"
            case 4:
                return "PCMFormatInt32"
            default :
                return "OtherFormat"
            }
        }
    }
    
    /// the directory path as a NSURL object
    public var directoryPath: NSURL {
        get {
            return self.url.URLByDeletingLastPathComponent!
        }
    }
    
    /// the file name with extension as a String
    public var fileNamePlusExtension: String {
        get {
            return self.url.lastPathComponent!
        }
    }
    
    /// the file name without extension as a String
    public var fileName: String {
        get {
            return (self.url.URLByDeletingPathExtension?.lastPathComponent!)!
        }
    }
    
    /// the file extension as a String (without ".")
    public var fileExt: String {
        get {
            return (self.url.pathExtension!)
        }
    }
    
    /// Returns an AVAsset from the AKAudioFile
    public var avAsset: AVURLAsset {
        return internalAVAsset
    }
    
    /// As The description doesn't provide so much informations, I appended the
    /// fileFormat String. (But may be it is a bad practice... let me know :-)
    override public var description: String {
        get {
            return super.description + "\n" + String(self.fileFormat)
        }
    }
    
    
    // MARK: - Exporting utility method


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
        
        public init(fileName: String, baseDir: BaseDirectory,
                    callBack: AKCallback,
                    presetName: String,
                    file: AKAudioFile,
                    outputFileExtension: ExportFormat,
                    from inTime: Double,
                    to outTime: Double) throws {
            
            self.callBack = callBack
            let asset = file.avAsset
            
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
            
            // must translate url as a fileUrl
            exporter.outputURL = NSURL(fileURLWithPath: filePath)
            
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
