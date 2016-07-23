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
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
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
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
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
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
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
                        NSLocalizedDescriptionKey :  NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "An Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey :NSLocalizedString(
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
                        NSLocalizedDescriptionKey :  NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey :NSLocalizedString(
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
                        NSLocalizedDescriptionKey:  NSLocalizedString(
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
                        NSLocalizedDescriptionKey :  NSLocalizedString(
                            "AKAudioFile ASync Process Unknown Error",
                            value: "Ans Async Process unknown error occured",
                            comment: ""),
                        NSLocalizedFailureReasonErrorKey :NSLocalizedString(
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
    
    
    
}
