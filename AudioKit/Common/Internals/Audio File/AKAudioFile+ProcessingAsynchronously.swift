//
//  AKAudioFile+ProcessingAsynchronously.swift
//  AudioKit
//
//  Created by Laurent Veliscek and Brandon Barber on 12/07/2016.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

///  Major Revision: Async process objects are now handled by AKAudioFile ProcessFactory singleton.
///  So there's no more need to handle asyncProcess objects.
///  You can process a file asynchronously using:
///
///      file.normalizeAsynchronously(completionHandler: callBack)
///
///  where completionHandler as an AKAudioFile.AsyncProcessCallback signature :
///
///      asyncProcessCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
///
///  When process has been completed, completionHandler is triggered
///  Then, processedFile is nil if an error occured (error is the process thrown error)
///  Or processedFile is the resulting processed AKAudioFile (and error is nil)
///
///  IMPORTANT: Any AKAudioFile process will output a .caf AKAudioFile
///  set with a PCM Linear Encoding (no compression)
///  But it can be applied to any readable file (.wav, .m4a, .mp3...)
///  So it can be used to convert any readable file (compressed or not) into a PCM Linear Encoded AKAudioFile
///  (That is not possible using AKAudioFile export method, that relies on AVAsset Export methods)
///
extension AKAudioFile {

    /// typealias for AKAudioFile Async Process Completion Handler
    ///
    /// If processedFile != nil, process succeeded (then error is nil)
    /// If processedFile == nil, process failed, error is the process thrown error
    public typealias AsyncProcessCallback = (processedFile: AKAudioFile?, error: NSError?) -> Void


    /// ExportFormat enum to set target format when exporting AKAudiofiles
    ///
    /// - wav: Waveform Audio File Format (WAVE, or more commonly known as WAV due to its filename extension)
    /// - aif: Audio Interchange File Format
    /// - mp4: MPEG-4 Part 14 Compression
    /// - m4a: MPEG 4 Audio
    /// - caf: Core Audio Format
    ///
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

    // MARK: - AKAudioFile public interface with private AKAudioFile ProcessFactory singleton

    /// Returns the remaining not completed queued Async processes (Int)
    static public var queuedAsyncProcessCount: Int {
        return ProcessFactory.sharedInstance.queuedProcessCount
    }

    /// Returns the total scheduled Async processes count (Int)
    static public var scheduledAsyncProcessesCount: Int {
        return ProcessFactory.sharedInstance.scheduledProcessesCount
    }

    /// Returns the completed Async processes count (Int)
    static public var completedAsyncProcessesCount: Int {
        return scheduledAsyncProcessesCount - queuedAsyncProcessCount
    }


    /// Process the current AKAudioFile in background to return an
    /// AKAudioFile normalized with a peak of newMaxLevel dB if succeeded
    ///
    /// Completion Handler is function with an AKAudioFile.AsyncProcessCallback signature:
    /// ```
    /// func myCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
    /// ```
    ///
    /// in this callBack, you can check that process succeeded by testing processedFile value :
    /// . if processedFile != nil, process succeded (and error is nil)
    /// . if processedFile == nil, process failed, error is the process thrown error
    ///
    /// Notice that completionCallBack will be triggered from a
    /// background thread. Any UI update should be made using:
    ///
    /// ```
    /// dispatch_async(dispatch_get_main_queue()) {
    ///   // UI updates...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - completionHandler: the callBack that will be triggered when process has been completed
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - newMaxLevel: max level targeted as a Float value (default if 0 dB)
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func normalizeAsynchronously(
        baseDir: BaseDirectory = .Temp,
        name: String = "",
        newMaxLevel: Float = 0.0,
        completionHandler: AsyncProcessCallback) {

        ProcessFactory.sharedInstance.queueNormalizeAsyncProcess(sourceFile: self,
                                                                 baseDir: baseDir,
                                                                 name: name,
                                                                 newMaxLevel: newMaxLevel,
                                                                 completionHandler: completionHandler)
    }


    /// Process the current AKAudioFile in background to return the current AKAudioFile reversed (will play backward)
    ///
    /// Completion Handler is function with an AKAudioFile.AsyncProcessCallback signature:
    /// ```
    /// func myCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
    /// ```
    ///
    /// in this callBack, you can check that process succeeded by testing processedFile value :
    /// . if processedFile != nil, process succeded (and error is nil)
    /// . if processedFile == nil, process failed, error is the process thrown error
    ///
    /// Notice that completionCallBack will be triggered from a
    /// background thread. Any UI update should be made using:
    ///
    /// ```
    /// dispatch_async(dispatch_get_main_queue()) {
    ///   // UI updates...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - completionHandler: the callBack that will be triggered when process has been completed
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func reverseAsynchronously(baseDir baseDir: BaseDirectory = .Temp,
                                              name: String = "",
                                              completionHandler: AsyncProcessCallback) {

        ProcessFactory.sharedInstance.queueReverseAsyncProcess(
            sourceFile: self,
            baseDir: baseDir,
            name: name,
            completionHandler: completionHandler
        )
    }


    /// Process the current AKAudioFile in background to return an AKAudioFile with appended audio data from another AKAudioFile.
    ///
    /// Completion Handler is function with an AKAudioFile.AsyncProcessCallback signature:
    /// ```
    /// func myCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
    /// ```
    ///
    /// in this callBack, you can check that process succeeded by testing processedFile value :
    /// . if processedFile != nil, process succeded (and error is nil)
    /// . if processedFile == nil, process failed, error is the process thrown error
    ///
    /// Notice that completionCallBack will be triggered from a
    /// background thread. Any UI update should be made using:
    ///
    /// ```
    /// dispatch_async(dispatch_get_main_queue()) {
    ///   // UI updates...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - completionHandler: the callBack that will be triggered when process has been completed
    ///   - file: an AKAudioFile that will be used to append audio from.
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func appendAsynchronously(file file: AKAudioFile,
                                          baseDir: BaseDirectory = .Temp,
                                          name: String = "",
                                          completionHandler: AsyncProcessCallback) {

        ProcessFactory.sharedInstance.queueAppendAsyncProcess(
            sourceFile: self,
            appendedFile:file,
            baseDir: baseDir,
            name: name,
            completionHandler: completionHandler
        )
    }

    /// Process the current AKAudioFile in background to return an AKAudioFile with an extracted range of audio data.
    ///
    /// if "toSample" parameter is set to zero, it will be set to be the number of samples of the file, so extraction will go from fromSample value to the end of file.
    ///
    /// Completion Handler is function with an AKAudioFile.AsyncProcessCallback signature:
    /// ```
    /// func myCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
    /// ```
    ///
    /// in this callBack, you can check that process succeeded by testing processedFile value :
    /// . if processedFile != nil, process succeded (and error is nil)
    /// . if processedFile == nil, process failed, error is the process thrown error
    ///
    /// Notice that completionCallBack will be triggered from a
    /// background thread. Any UI update should be made using:
    ///
    /// ```
    /// dispatch_async(dispatch_get_main_queue()) {
    ///   // UI updates...
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - completionHandler: the callBack that will be triggered when process has been completed
    ///   - fromSample: the starting sampleFrame for extraction. (default is zero)
    ///   - toSample: the ending sampleFrame for extraction (default is zero)
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func extractAsynchronously(fromSample fromSample: Int64 = 0,
                                                 toSample: Int64 = 0,
                                                 baseDir: BaseDirectory = .Temp,
                                                 name: String = "",
                                                 completionHandler: AsyncProcessCallback) {

        ProcessFactory.sharedInstance.queueExtractAsyncProcess(
            sourceFile: self,
            fromSample: fromSample,
            toSample: toSample,
            baseDir: baseDir,
            name: name,
            completionHandler: completionHandler
        )
    }


    /// Exports Asynchronously to a new AKAudiofile with trimming options.
    ///
    /// Can export from wav/aif/caf to wav/aif/m4a/mp4/caf
    /// Can export from m4a/mp4 to m4a/mp4
    /// Exporting from a compressed format to a PCM format (mp4/m4a to wav/aif/caf) is not supported.
    ///
    /// fromSample and toSample can be set to extract only a portion of the current AKAudioFile.
    /// If toSample is zero, it will be set to the file's duration (no end trimming)
    ///
    /// As soon as callback has been triggered, you can use ExportSession.status to
    /// check if export succeeded or not. If export succeeded, you can get the exported
    /// AKAudioFile using ExportSession.exportedAudioFile. ExportSession.progress
    /// lets you monitor export progress.
    ///
    /// See playground for an example of use.
    ///
    /// - Parameters:
    ///   - name: the name of the exported file without its extension (String).
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
    ///   - ExportFormat: the output file format as an ExportFormat enum value (.aif, .wav, .m4a, .mp4, .caf)
    ///   - fromSample: start range in samples
    ///   - toSample: end range time in samples
    ///   - callBack: AsyncProcessCallback function that will be triggered when export completed.
    ///
    public func exportAsynchronously (name name: String,
                                           baseDir: BaseDirectory,
                                           exportFormat: ExportFormat,
                                           fromSample: Int64 = 0,
                                           toSample: Int64 = 0,
                                           callBack: AsyncProcessCallback) {
        let fromFileExt = fileExt.lowercaseString

        // Only mp4, m4a, .wav, .aif can be exported...
        guard ExportFormat.arrayOfStrings.contains(fromFileExt) else {
            print( "ERROR: AKAudioFile \".\(fromFileExt)\" is not supported for export!...")
            callBack(processedFile: nil,
                     error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            return
        }


        // Compressed formats cannot be exported to PCM
        let fromFileFormatIsCompressed = (fromFileExt == "m4a" || fromFileExt == "mp4")
        let outFileFormatIsCompressed  = (exportFormat == .mp4 || exportFormat == .m4a )

        // set avExportPreset
        var avExportPreset: String = ""

        if fromFileFormatIsCompressed {
            if !outFileFormatIsCompressed {
                print( "ERROR AKAudioFile: cannot export from .\(fileExt) to .\(String(exportFormat))!...")
                callBack(processedFile: nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
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



        let assetUrl = url
        let asset  = AVURLAsset(URL: assetUrl)

        if let internalExportSession = AVAssetExportSession(asset: asset, presetName: avExportPreset) {
            print ("internalExportSession session created")

            var filePath: String = ""
            switch baseDir {
            case .Temp:
                filePath = (NSTemporaryDirectory() as String) + name + "." + String(exportFormat)
            case .Documents:
                filePath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) + "/" + name + "." + String(exportFormat)
            case .Resources:
                print( "ERROR AKAudioFile export: cannot create a file in applications resources!...")
                callBack(processedFile: nil,
                         error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            }

            let nsurl = NSURL(string: filePath)
            guard nsurl != nil else {
                print( "ERROR AKAudioFile export: directory \"\(filePath)\" isn't valid!...")
                callBack(processedFile: nil,
                         error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
                return
            }
            let directoryPath = nsurl!.URLByDeletingLastPathComponent
            // Check if directory exists
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath((directoryPath?.absoluteString)!) == false {
                print( "ERROR AKAudioFile export: directory \"\(directoryPath)\" doesn't exists!...")
                callBack(processedFile: nil,
                         error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
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
                    callBack(processedFile: nil, error: error)
                }
                print ("AKAudioFile export: Output file has been deleted !")
            }

            internalExportSession.outputURL = NSURL.fileURLWithPath(filePath)
            // Sets the output file encoding (avoid .wav encoded as m4a...)
            internalExportSession.outputFileType = exportFormat.UTI as String

            // In and OUT times triming settings
            let inFrame: Int64
            let outFrame: Int64

            if toSample == 0 {
                outFrame = samplesCount
            } else {
                outFrame = min(samplesCount, toSample)
            }

            inFrame = abs(min(samplesCount, fromSample))

            if (outFrame <= inFrame) {
                print( "ERROR AKAudioFile export: In time must be less than Out time!...")
                callBack(processedFile: nil,
                         error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            }
            let startTime = CMTimeMake(inFrame, Int32(sampleRate))
            let stopTime = CMTimeMake(outFrame, Int32(sampleRate))
            let timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            internalExportSession.timeRange = timeRange

            let session = ExportSession(AVAssetExportSession: internalExportSession, callBack: callBack)

            ExportFactory.queueExportSession(session: session)

        } else {
            print( "ERROR AKAudioFile export: cannot create AVAssetExportSession!...")
            callBack(processedFile: nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            return
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////

    // MARK: - ProcessFactory Private class

    // private process factory
    private class ProcessFactory {
        private var processArray = [Int]()
        private var lastProcessIdStamp: Int = 0

        // Singleton
        static let sharedInstance = ProcessFactory()

        // The queue that will be used for background AKAudioFile Async Processing
        private let processQueue = dispatch_queue_create("AKAudioFileProcessQueue", DISPATCH_QUEUE_SERIAL)


        // Append Normalize Process
        private func queueNormalizeAsyncProcess(sourceFile sourceFile: AKAudioFile,
                                                           baseDir: BaseDirectory,
                                                           name: String,
                                                           newMaxLevel: Float,
                                                           completionHandler: AsyncProcessCallback ) {


            let processIdStamp = ProcessFactory.sharedInstance.lastProcessIdStamp
            ProcessFactory.sharedInstance.lastProcessIdStamp += 1
            ProcessFactory.sharedInstance.processArray.append(processIdStamp)


            dispatch_async(ProcessFactory.sharedInstance.processQueue) {
                print("AKAudioFile.ProcessFactory beginning Normalizing file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processIdStamp))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.normalized(baseDir: baseDir,
                                                              name: name,
                                                              newMaxLevel: newMaxLevel)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processArray.removeLast()
                if processedFile != nil {
                    print("AKAudioFile.ProcessFactory completed Normalizing file \"\(sourceFile.fileNamePlusExtension)\" -> \"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    print("AKAudioFile.ProcessFactory failed Normalizing file \"\(sourceFile.fileNamePlusExtension)\" -> Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    print("AKAudioFile.ProcessFactory failed Normalizing file \"\(sourceFile.fileNamePlusExtension)\" -> Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [NSObject : AnyObject] = [
                        NSLocalizedDescriptionKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "An Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "An Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile: processedFile, error: processError)
            }
        }



        // Append Reverse Process
        private func queueReverseAsyncProcess(sourceFile sourceFile: AKAudioFile,
                                                         baseDir: BaseDirectory,
                                                         name: String,
                                                         completionHandler: AsyncProcessCallback) {


            let processIdStamp = ProcessFactory.sharedInstance.lastProcessIdStamp
            ProcessFactory.sharedInstance.lastProcessIdStamp += 1
            ProcessFactory.sharedInstance.processArray.append(processIdStamp)


            dispatch_async(ProcessFactory.sharedInstance.processQueue) {
                print("AKAudioFile.ProcessFactory beginning Reversing file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processIdStamp))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.reversed(baseDir: baseDir, name: name)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processArray.removeLast()
                if processedFile != nil {
                    print("AKAudioFile.ProcessFactory completed Reversing file \"\(sourceFile.fileNamePlusExtension)\" -> \"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    print("AKAudioFile.ProcessFactory failed Reversing file \"\(sourceFile.fileNamePlusExtension)\" -> Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    print("AKAudioFile.ProcessFactory failed Reversing file \"\(sourceFile.fileNamePlusExtension)\" -> Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [NSObject : AnyObject] = [
                        NSLocalizedDescriptionKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",

                            comment: ""),
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile: processedFile, error: processError)
            }
        }



        // Append Append Process
        private func queueAppendAsyncProcess(sourceFile sourceFile: AKAudioFile,
                                                        appendedFile: AKAudioFile,
                                                        baseDir: BaseDirectory,
                                                        name: String,
                                                        completionHandler: AsyncProcessCallback) {


            let processIdStamp = ProcessFactory.sharedInstance.lastProcessIdStamp
            ProcessFactory.sharedInstance.lastProcessIdStamp += 1
            ProcessFactory.sharedInstance.processArray.append(processIdStamp)


            dispatch_async(ProcessFactory.sharedInstance.processQueue) {
                print("AKAudioFile.ProcessFactory beginning Appending file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processIdStamp))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.appendedBy(file: appendedFile,
                                                              baseDir: baseDir,
                                                              name: name)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processArray.removeLast()
                if processedFile != nil {
                    print("AKAudioFile.ProcessFactory completed Appending file \"\(sourceFile.fileNamePlusExtension)\" -> \"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    print("AKAudioFile.ProcessFactory failed Appending file \"\(sourceFile.fileNamePlusExtension)\" -> Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    print("AKAudioFile.ProcessFactory failed Appending file \"\(sourceFile.fileNamePlusExtension)\" -> Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [NSObject : AnyObject] = [
                        NSLocalizedDescriptionKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile: processedFile, error: processError)
            }
        }


        // Queue extract Process
        private func queueExtractAsyncProcess(sourceFile sourceFile: AKAudioFile,
                                                         fromSample: Int64 = 0,
                                                         toSample: Int64 = 0,
                                                         baseDir: BaseDirectory,
                                                         name: String,
                                                         completionHandler: AsyncProcessCallback) {


            let processIdStamp = ProcessFactory.sharedInstance.lastProcessIdStamp
            ProcessFactory.sharedInstance.lastProcessIdStamp += 1
            ProcessFactory.sharedInstance.processArray.append(processIdStamp)


            dispatch_async(ProcessFactory.sharedInstance.processQueue) {
                print("AKAudioFile.ProcessFactory beginning Extracting from file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processIdStamp))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.extracted(fromSample: fromSample,
                                                             toSample: toSample,
                                                             baseDir: baseDir,
                                                             name: name)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processArray.removeLast()
                if processedFile != nil {
                    print("AKAudioFile.ProcessFactory completed Extracting from file \"\(sourceFile.fileNamePlusExtension)\" -> \"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    print("AKAudioFile.ProcessFactory failed Extracting from file \"\(sourceFile.fileNamePlusExtension)\" -> Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    print("AKAudioFile.ProcessFactory failed Extracting from file \"\(sourceFile.fileNamePlusExtension)\" -> Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [NSObject : AnyObject] = [
                        NSLocalizedDescriptionKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey : NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile: processedFile, error: processError)
            }
        }




        private var queuedProcessCount: Int {
            return processArray.count
        }

        private var scheduledProcessesCount: Int {
            return lastProcessIdStamp
        }

    }

    // MARK: - ExportFactory Private classes

    // private ExportSession wraps an AVAssetExportSession with an id and the completion callback
    private class ExportSession {
        private var avAssetExportSession: AVAssetExportSession
        private var idStamp: Int
        private var callBack: AsyncProcessCallback


        private init (AVAssetExportSession avAssetExportSession: AVAssetExportSession,
                                           callBack: AsyncProcessCallback) {
            self.avAssetExportSession = avAssetExportSession
            self.callBack = callBack
            self.idStamp = ExportFactory.lastExportSessionIdStamp
            ExportFactory.lastExportSessionIdStamp += 1
        }
    }


    // Export Factory is a singleton that handles Export Sessions serially
    private class ExportFactory {

        private static var exportSessionsArray = [Int:ExportSession]()
        private static var lastExportSessionIdStamp: Int = 0
        private static var isExporting = false
        private static var currentExportProcessId: Int = 0


        // Singleton
        static let sharedInstance = ExportFactory()

        private static func completionHandler() {

            if let session = exportSessionsArray[currentExportProcessId] {
                switch session.avAssetExportSession.status {
                case  AVAssetExportSessionStatus.Failed:
                    session.callBack(processedFile: nil, error: session.avAssetExportSession.error)
                case AVAssetExportSessionStatus.Cancelled:
                    session.callBack(processedFile: nil, error: session.avAssetExportSession.error)
                default :
                    if  let outputUrl = session.avAssetExportSession.outputURL {
                        do {
                            let audiofile = try AKAudioFile(forReading: outputUrl)
                            session.callBack(processedFile: audiofile, error: nil)
                        } catch let error as NSError {
                            session.callBack(processedFile: nil, error: error)
                        }
                    } else {
                        print( "ERROR AKAudioFile export: outputUrl is nil!...")
                        session.callBack(processedFile: nil,
                                         error: NSError(
                                            domain: NSURLErrorDomain,
                                            code: NSURLErrorCannotCreateFile,
                                            userInfo: nil))
                    }
                }
                print("ExportFactory: session #\(session.idStamp) Completed")
                exportSessionsArray.removeValueForKey(currentExportProcessId)
                if exportSessionsArray.isEmpty == false {
                    //currentExportProcessId = exportSessionsArray.first!.0
                    currentExportProcessId += 1
                    print("ExportFactory: exporting session #\(currentExportProcessId)")
                    exportSessionsArray[currentExportProcessId]!.avAssetExportSession.exportAsynchronouslyWithCompletionHandler(completionHandler)

                } else {
                    isExporting = false
                    print ("ExportFactory: All exports have been completed")
                }
            } else {
                print("ExportFactory: Error : sessionId:\(currentExportProcessId) doesn't exist !!")
            }
        }

        // Append the exportSession to the ExportFactory Export Queue
        private static func queueExportSession(session session: ExportSession) {
            exportSessionsArray[session.idStamp] = session

            if isExporting == false {
                isExporting = true
                currentExportProcessId = session.idStamp
                print("ExportFactory: exporting session #\(session.idStamp)")
                exportSessionsArray[currentExportProcessId]!.avAssetExportSession.exportAsynchronouslyWithCompletionHandler(completionHandler)
            } else {
                print ("ExportFactory: is busy !")
                print("ExportFactory: Queuing session #\(session.idStamp)")
            }
        }
    }
}
