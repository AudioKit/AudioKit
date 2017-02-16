//
//  AKAudioFile+ProcessingAsynchronously.swift
//  AudioKit
//
//  Created by Laurent Veliscek and Brandon Barber on 12/07/2016.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

///  Major Revision: Async process objects are now handled by AKAudioFile ProcessFactory singleton.
///  So there's no more need to handle asyncProcess objects.
///  You can process a file asynchronously using:
///
///      file.normalizeAsynchronously(completionHandler: callback)
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
    public typealias AsyncProcessCallback = (_ processedFile: AKAudioFile?, _ error: NSError?) -> Void

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
        fileprivate var UTI: CFString {
            switch self {
            case .wav:
                return AVFileTypeWAVE as CFString
            case .aif:
                return AVFileTypeAIFF as CFString
            case .mp4:
                return AVFileTypeAppleM4A as CFString
            case .m4a:
                return AVFileTypeAppleM4A as CFString
            case .caf:
                return AVFileTypeCoreAudioFormat as CFString
            }
        }

        // Available Export Formats
        static var supportedFileExtensions: [String] {
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
    /// in this callback, you can check that process succeeded by testing processedFile value :
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
    ///   - completionHandler: the callback that will be triggered when process has been completed
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - newMaxLevel: max level targeted as a Float value (default if 0 dB)
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func normalizeAsynchronously(baseDir: BaseDirectory = .temp,
                                        name: String = "",
                                        newMaxLevel: Float = 0.0,
                                        completionHandler: @escaping AsyncProcessCallback) {

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
    /// in this callback, you can check that process succeeded by testing processedFile value :
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
    ///   - completionHandler: the callback that will be triggered when process has been completed
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func reverseAsynchronously(baseDir: BaseDirectory = .temp,
                                      name: String = "",
                                      completionHandler: @escaping AsyncProcessCallback) {

        ProcessFactory.sharedInstance.queueReverseAsyncProcess(
            sourceFile: self,
            baseDir: baseDir,
            name: name,
            completionHandler: completionHandler
        )
    }

    /// Process an AKAudioFile in background to return an AKAudioFile with appended audio data from another AKAudioFile.
    ///
    /// Completion Handler is function with an AKAudioFile.AsyncProcessCallback signature:
    /// ```
    /// func myCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
    /// ```
    ///
    /// in this callback, you can check that process succeeded by testing processedFile value :
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
    ///   - completionHandler: the callback that will be triggered when process has been completed
    ///   - file: an AKAudioFile that will be used to append audio from.
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp (Default is .Temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func appendAsynchronously(file: AKAudioFile,
                                     baseDir: BaseDirectory = .temp,
                                     name: String = "",
                                     completionHandler: @escaping AsyncProcessCallback) {

        ProcessFactory.sharedInstance.queueAppendAsyncProcess(
            sourceFile: self,
            appendedFile: file,
            baseDir: baseDir,
            name: name,
            completionHandler: completionHandler
        )
    }

    /// Process the current AKAudioFile in background to return an AKAudioFile with an extracted range of audio data.
    ///
    /// if "toSample" parameter is set to zero, it will be set to be the number of samples of the file, 
    /// so extraction will go from fromSample value to the end of file.
    ///
    /// Completion Handler is function with an AKAudioFile.AsyncProcessCallback signature:
    /// ```
    /// func myCallback(processedFile:AKAudioFile?, error:NSError?) -> Void
    /// ```
    ///
    /// in this callback, you can check that process succeeded by testing processedFile value :
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
    ///   - completionHandler: the callback that will be triggered when process has been completed
    ///   - fromSample: the starting sampleFrame for extraction. (default is zero)
    ///   - toSample: the ending sampleFrame for extraction (default is zero)
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp (Default is .temp)
    ///   - name: the name of the resulting file without its extension (String).
    ///   - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.
    ///
    public func extractAsynchronously(fromSample: Int64 = 0,
                                      toSample: Int64 = 0,
                                      baseDir: BaseDirectory = .temp,
                                      name: String = "",
                                      completionHandler: @escaping AsyncProcessCallback) {

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
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp
    ///   - ExportFormat: the output file format as an ExportFormat enum value (.aif, .wav, .m4a, .mp4, .caf)
    ///   - fromSample: start range in samples
    ///   - toSample: end range time in samples
    ///   - callback: AsyncProcessCallback function that will be triggered when export completed.
    ///
    public func exportAsynchronously(name: String,
                                     baseDir: BaseDirectory,
                                     exportFormat: ExportFormat,
                                     fromSample: Int64 = 0,
                                     toSample: Int64 = 0,
                                     callback: @escaping AsyncProcessCallback) {
        let fromFileExt = fileExt.lowercased()

        // Only mp4, m4a, .wav, .aif can be exported...
        guard ExportFormat.supportedFileExtensions.contains(fromFileExt) else {
            AKLog("ERROR: AKAudioFile \".\(fromFileExt)\" is not supported for export!...")
            callback(nil,
                     NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            return
        }

        // Compressed formats cannot be exported to PCM
        let fromFileFormatIsCompressed = (fromFileExt == "m4a" || fromFileExt == "mp4")
        let outFileFormatIsCompressed = (exportFormat == .m4a || exportFormat == .mp4 )

        // set avExportPreset
        var avExportPreset: String = ""

        if fromFileFormatIsCompressed {
            if !outFileFormatIsCompressed {
                AKLog("ERROR AKAudioFile: cannot export from .\(fileExt) to .\(String(describing: exportFormat))!...")
                callback(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
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

        let asset = AVURLAsset(url: url)
        if let internalExportSession = AVAssetExportSession(asset: asset, presetName: avExportPreset) {
            AKLog("internalExportSession session created")

            var filePath: String = ""
            var fileName = name

            let fileExt = String(describing: exportFormat)

            // only add the file extension if it isn't already there
            if !fileName.hasSuffix(fileExt) {
                fileName += "." + fileExt
            }

            switch baseDir {
            case .temp:
                filePath = (NSTemporaryDirectory() as String) + fileName
            case .documents:
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                filePath = documentsPath + "/" + fileName
            case .resources:
                AKLog("ERROR AKAudioFile export: cannot create a file in applications resources!...")
                callback(nil,
                         NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            // Save in same directory as original file
            case .custom:
                let defaultBase: URL = url.deletingLastPathComponent()
                filePath = defaultBase.path +  "/" + fileName
            }

            guard let nsurl = URL(string: filePath) else {
                AKLog("ERROR AKAudioFile export: directory \"\(filePath)\" isn't valid!...")
                callback(nil,
                         NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
                return
            }
            let directoryPath = nsurl.deletingLastPathComponent()
            // Check if directory exists
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: (directoryPath.absoluteString)) == false {
                AKLog("ERROR AKAudioFile export: directory \"\(directoryPath)\" doesn't exists!...")
                callback(nil,
                         NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            }

            // Check if out file exists
            if fileManager.fileExists(atPath: nsurl.absoluteString) {
                // Then delete file
                AKLog("AKAudioFile export: Output file already exists, trying to delete...")
                do {
                    try fileManager.removeItem(atPath: nsurl.absoluteString)
                } catch let error as NSError {
                    AKLog("Error !!! AKAudioFile: couldn't delete file \"\(nsurl)\" !...")
                    AKLog(error.localizedDescription)
                    callback(nil, error)
                }
                AKLog("AKAudioFile export: Output file has been deleted !")
            }

            internalExportSession.outputURL = URL(fileURLWithPath: filePath)
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

            if outFrame <= inFrame {
                AKLog("ERROR AKAudioFile export: In time must be less than Out time!...")
                callback(nil,
                         NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            }
            let startTime = CMTimeMake(inFrame, Int32(sampleRate))
            let stopTime = CMTimeMake(outFrame, Int32(sampleRate))
            let timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            internalExportSession.timeRange = timeRange

            let session = ExportSession(AVAssetExportSession: internalExportSession, callback: callback)

            ExportFactory.queueExportSession(session: session)

        } else {
            AKLog("ERROR AKAudioFile export: cannot create AVAssetExportSession!...")
            callback(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil))
            return
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////

    // MARK: - ProcessFactory Private class

    // private process factory
    fileprivate class ProcessFactory {
        fileprivate var processIDs = [Int]()
        fileprivate var lastProcessID: Int = 0

        // Singleton
        static let sharedInstance = ProcessFactory()

        // The queue that will be used for background AKAudioFile Async Processing
        fileprivate let processQueue = DispatchQueue(label: "AKAudioFileProcessQueue", attributes: [])

        // Append Normalize Process
        fileprivate func queueNormalizeAsyncProcess(sourceFile: AKAudioFile,
                                                    baseDir: BaseDirectory,
                                                    name: String,
                                                    newMaxLevel: Float,
                                                    completionHandler: @escaping AsyncProcessCallback ) {

            let processID = ProcessFactory.sharedInstance.lastProcessID
            ProcessFactory.sharedInstance.lastProcessID += 1
            ProcessFactory.sharedInstance.processIDs.append(processID)

            ProcessFactory.sharedInstance.processQueue.async {
                AKLog("Beginning Normalizing file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processID))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.normalized(baseDir: baseDir,
                                                              name: name,
                                                              newMaxLevel: newMaxLevel)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processIDs.removeLast()
                if processedFile != nil {
                    AKLog("Completed Normalizing file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "\"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    AKLog("Failed Normalizing file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    AKLog("Failed Normalizing file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [AnyHashable: Any] = [
                        NSLocalizedDescriptionKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "An Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "An Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0,
                                           userInfo: userInfo)

                }
                completionHandler(processedFile, processError)
            }
        }

        // Append Reverse Process
        fileprivate func queueReverseAsyncProcess(sourceFile: AKAudioFile,
                                                  baseDir: BaseDirectory,
                                                  name: String,
                                                  completionHandler: @escaping AsyncProcessCallback) {

            let processID = ProcessFactory.sharedInstance.lastProcessID
            ProcessFactory.sharedInstance.lastProcessID += 1
            ProcessFactory.sharedInstance.processIDs.append(processID)

            ProcessFactory.sharedInstance.processQueue.async {
                AKLog("Beginning Reversing file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processID))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.reversed(baseDir: baseDir, name: name)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processIDs.removeLast()
                if processedFile != nil {
                    AKLog("Completed Reversing file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "\"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    AKLog("Failed Reversing file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    AKLog("Failed Reversing file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [AnyHashable: Any] = [
                        NSLocalizedDescriptionKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",

                            comment: ""),
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile, processError)
            }
        }

        // Append Append Process
        fileprivate func queueAppendAsyncProcess(sourceFile: AKAudioFile,
                                                 appendedFile: AKAudioFile,
                                                 baseDir: BaseDirectory,
                                                 name: String,
                                                 completionHandler: @escaping AsyncProcessCallback) {

            let processID = ProcessFactory.sharedInstance.lastProcessID
            ProcessFactory.sharedInstance.lastProcessID += 1
            ProcessFactory.sharedInstance.processIDs.append(processID)

            ProcessFactory.sharedInstance.processQueue.async {
                AKLog("Beginning Appending file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processID))")
                var processedFile: AKAudioFile?
                var processError: NSError?
                do {
                    processedFile = try sourceFile.appendedBy(file: appendedFile,
                                                              baseDir: baseDir,
                                                              name: name)
                } catch let error as NSError {
                    processError = error
                }
                let lastCompletedProcess = ProcessFactory.sharedInstance.processIDs.removeLast()
                if processedFile != nil {
                    AKLog("Completed Appending file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "\"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    AKLog("Failed Appending file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    AKLog("Failed Appending file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [AnyHashable: Any] = [
                        NSLocalizedDescriptionKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile, processError)
            }
        }

        // Queue extract Process
        fileprivate func queueExtractAsyncProcess(sourceFile: AKAudioFile,
                                                  fromSample: Int64 = 0,
                                                  toSample: Int64 = 0,
                                                  baseDir: BaseDirectory,
                                                  name: String,
                                                  completionHandler: @escaping AsyncProcessCallback) {

            let processID = ProcessFactory.sharedInstance.lastProcessID
            ProcessFactory.sharedInstance.lastProcessID += 1
            ProcessFactory.sharedInstance.processIDs.append(processID)

            ProcessFactory.sharedInstance.processQueue.async {
                AKLog("Beginning Extracting from file \"\(sourceFile.fileNamePlusExtension)\" (process #\(processID))")
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
                let lastCompletedProcess = ProcessFactory.sharedInstance.processIDs.removeLast()
                if processedFile != nil {
                    AKLog("Completed Extracting from file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "\"\(processedFile!.fileNamePlusExtension)\" (process #\(lastCompletedProcess))")
                } else if processError != nil {
                    AKLog("Failed Extracting from file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Error: \"\(processError!)\" (process #\(lastCompletedProcess))")
                } else {
                    AKLog("Failed Extracting from file \"\(sourceFile.fileNamePlusExtension)\" -> " +
                        "Unknown Error (process #\(lastCompletedProcess))")
                    let userInfo: [AnyHashable: Any] = [
                        NSLocalizedDescriptionKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey: NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: "")
                    ]
                    processError = NSError(domain: "AKAudioFile ASync Process Unknown Error",
                                           code: 0, userInfo: userInfo)

                }
                completionHandler(processedFile, processError)
            }
        }

        fileprivate var queuedProcessCount: Int {
            return processIDs.count
        }

        fileprivate var scheduledProcessesCount: Int {
            return lastProcessID
        }
    }

    // MARK: - ExportFactory Private classes

    // private ExportSession wraps an AVAssetExportSession with an id and the completion callback
    fileprivate class ExportSession {
        fileprivate var avAssetExportSession: AVAssetExportSession
        fileprivate var id: Int
        fileprivate var callback: AsyncProcessCallback

        fileprivate init(AVAssetExportSession avAssetExportSession: AVAssetExportSession,
                         callback: @escaping AsyncProcessCallback) {
            self.avAssetExportSession = avAssetExportSession
            self.callback = callback
            self.id = ExportFactory.lastExportSessionID
            ExportFactory.lastExportSessionID += 1
        }
    }

    // Export Factory is a singleton that handles Export Sessions serially
    fileprivate class ExportFactory {

        fileprivate static var exportSessions = [Int: ExportSession]()
        fileprivate static var lastExportSessionID: Int = 0
        fileprivate static var isExporting = false
        fileprivate static var currentExportProcessID: Int = 0

        // Singleton
        static let sharedInstance = ExportFactory()

        fileprivate static func completionHandler() {

            if let session = exportSessions[currentExportProcessID] {
                switch session.avAssetExportSession.status {
                case  AVAssetExportSessionStatus.failed:
                    session.callback(nil, session.avAssetExportSession.error as NSError?)
                case AVAssetExportSessionStatus.cancelled:
                    session.callback(nil, session.avAssetExportSession.error as NSError?)
                default :
                    if  let outputURL = session.avAssetExportSession.outputURL {
                        do {
                            let audiofile = try AKAudioFile(forReading: outputURL)
                            session.callback(audiofile, nil)
                        } catch let error as NSError {
                            session.callback(nil, error)
                        }
                    } else {
                        AKLog("ERROR AKAudioFile export: outputURL is nil!...")
                        session.callback(nil,
                                         NSError(
                                            domain: NSURLErrorDomain,
                                            code: NSURLErrorCannotCreateFile,
                                            userInfo: nil))
                    }
                }
                AKLog("ExportFactory: session #\(session.id) Completed")
                exportSessions.removeValue(forKey: currentExportProcessID)
                if exportSessions.isEmpty == false {
                    //currentExportProcessID = exportSessions.first!.0
                    currentExportProcessID += 1
                    AKLog("ExportFactory: exporting session #\(currentExportProcessID)")
                    exportSessions[currentExportProcessID]!.avAssetExportSession.exportAsynchronously(
                        completionHandler: completionHandler
                    )

                } else {
                    isExporting = false
                    AKLog("ExportFactory: All exports have been completed")
                }
            } else {
                AKLog("ExportFactory: Error : sessionId:\(currentExportProcessID) doesn't exist!")
            }
        }

        // Append the exportSession to the ExportFactory Export Queue
        fileprivate static func queueExportSession(session: ExportSession) {
            exportSessions[session.id] = session

            if !isExporting {
                isExporting = true
                currentExportProcessID = session.id
                AKLog("ExportFactory: exporting session #\(session.id)")
                exportSessions[currentExportProcessID]!.avAssetExportSession.exportAsynchronously(
                    completionHandler: completionHandler
                )
            } else {
                AKLog("ExportFactory: is busy!")
                AKLog("ExportFactory: Queuing session #\(session.id)")
            }
        }
    }
}
