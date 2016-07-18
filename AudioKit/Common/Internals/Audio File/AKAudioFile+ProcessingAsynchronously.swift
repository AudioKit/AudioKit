//
//  AKAudioFile+ProcessingAsynchronously.swift
//  AudioKit For iOS
//
//  Created by Laurent Veliscek and Brandon Barber on 12/07/2016.
//  Copyright © 2016 AudioKit. All rights reserved.
//
//
//  IMPORTANT: Any AKAudioFile process will output a .caf AKAudioFile
//  set with a PCM Linear Encoding (no compression)
//  But it can be applied to any readable file (.wav, .m4a, .mp3...)
//


import Foundation
import AVFoundation

extension AKAudioFile {


    // MARK: - embedded enum

    /// Enum of Status returned from the status property
    /// of any AKAudioFile Async AKAudioFile process.
    public enum ProcessStatus {
        case Failed
        case Processing
        case Succeeded
    }
    /// Enum of Process Types stored as a property
    /// in any AKAudioFile Async AKAudioFile process.
    public enum ProcessType {
        case Normalize
        case Reverse
        case Append
    }

    // MARK: - Async Process Objects

    /*
    Returned from normalize_Async()
    
    As soon as completionHandler has been triggered,
    you can check status (.Failed or .Succeeded)
     
    If .Succeeded, the resulting AKAudioFile is the
    process.processedFile property.

    If .Failed, you mau check the error thrown using
    process.error property.
     
    If needed, you can get the source AKAudioFile using
    process.sourceFile property and get the process type
    using process.processType

    */
    public class NormalizeProcess {

        public var status: ProcessStatus = .Processing
        public var processedFile: AKAudioFile?
        public var error: NSError?
        public let sourceFile: AKAudioFile
        public let processType: ProcessType = .Normalize

        init (  sourceFile: AKAudioFile, baseDir: BaseDirectory,
                name: String,
                newMaxLevel: Float,
                completionCallBack: AKCallback) {
            self.sourceFile = sourceFile
            dispatch_async(AudioKit.AKAudioFileProcessQueue) {
                do {
                    self.processedFile = try sourceFile.normalize(baseDir, name: name, newMaxLevel: newMaxLevel)
                } catch let error as NSError {
                    self.status = .Failed
                    print( "ERROR AKAudioFile: Normalize: \(error)")
                    self.error = error
                }
                print( "AKAudioFile: Normalizing \"\(self.sourceFile.fileNamePlusExtension)\" -> \"\(self.processedFile!.fileNamePlusExtension)\" completed!")
                self.status = .Succeeded
                completionCallBack()
            }
        }
    }

    /*
     Returned from reverse_Async()

     As soon as completionHandler has been triggered,
     you can check status (.Failed or .Succeeded)

     If .Succeeded, the resulting AKAudioFile is the
     process.processedFile property.

     If .Failed, you mau check the error thrown using
     process.error property.

     If needed, you can get the source AKAudioFile using
     process.sourceFile property.
     
     */
    public class ReverseProcess {

        public var status: ProcessStatus = .Processing
        public var processedFile: AKAudioFile?
        public var error: NSError?
        public let sourceFile: AKAudioFile
        public let processType: ProcessType = .Reverse

        init (  sourceFile: AKAudioFile, baseDir: BaseDirectory,
                name: String,
                completionCallBack: AKCallback) {
            self.sourceFile = sourceFile
            dispatch_async(AudioKit.AKAudioFileProcessQueue) {
                do {
                    self.processedFile = try sourceFile.reverse(baseDir, name: name)
                } catch let error as NSError {
                    self.status = .Failed
                    print( "ERROR AKAudioFile: Reverse: \(error)")
                    self.error = error
                }
                print( "AKAudioFile: Reversing \"\(self.sourceFile.fileNamePlusExtension)\" -> \"\(self.processedFile!.fileNamePlusExtension)\" completed!")
                self.status = .Succeeded
                completionCallBack()
            }
        }
    }


    /*
     Returned from append_Async()

     As soon as completionHandler has been triggered,
     you can check status (.Failed or .Succeeded)

     If .Succeeded, the resulting AKAudioFile is the
     process.processedFile property.

     If .Failed, you mau check the error thrown using
     process.error property.

     If needed, you can get the source AKAudioFile using
     process.sourceFile property.

     */
    public class AppendProcess {

        public var status: ProcessStatus = .Processing
        public var processedFile: AKAudioFile?
        public var error: NSError?
        public let sourceFile: AKAudioFile
        public let processType: ProcessType = .Append

        init (  sourceFile: AKAudioFile,
                file: AKAudioFile,
                baseDir: BaseDirectory,
                name: String  = "",
                completionCallBack: AKCallback) {
            self.sourceFile = sourceFile
            dispatch_async(AudioKit.AKAudioFileProcessQueue) {
            do {
                self.processedFile = try sourceFile.append(file, baseDir: baseDir, name: name)
            } catch let error as NSError {
                self.status = .Failed
                print( "ERROR AKAudioFile: Append: \(error)")
                self.error = error
                }
                print( "AKAudioFile: Appending to \"\(self.sourceFile.fileNamePlusExtension)\" -> \"\(self.processedFile!.fileNamePlusExtension)\" completed!")
                self.status = .Succeeded
                completionCallBack()
            }
        }
    }
    


    /*
     Returned from extract_Async()

     As soon as completionHandler has been triggered,
     you can check status (.Failed or .Succeeded)

     If .Succeeded, the resulting AKAudioFile is the
     process.processedFile property.

     If .Failed, you mau check the error thrown using
     process.error property.

     If needed, you can get the source AKAudioFile using
     process.sourceFile property.

     */
    public class ExtractProcess {

        public var status: ProcessStatus = .Processing
        public var processedFile: AKAudioFile?
        public var error: NSError?
        public let sourceFile: AKAudioFile
        public let processType: ProcessType = .Append

        init(sourceFile: AKAudioFile,
             fromSample: Int64,
             toSample: Int64,
             baseDir: BaseDirectory,
             name: String  = "",
             completionCallBack: AKCallback) {
            self.sourceFile = sourceFile
            dispatch_async(AudioKit.AKAudioFileProcessQueue) {
                do {
                    self.processedFile = try sourceFile.extract(fromSample: fromSample,
                                                                toSample: toSample,
                                                                baseDir: baseDir,
                                                                name: name)
                } catch let error as NSError {
                    self.status = .Failed
                    print( "ERROR AKAudioFile: Extract: \(error)")
                    self.error = error
                }
                print( "AKAudioFile: Extracting from \"\(self.sourceFile.fileNamePlusExtension)\" -> \"\(self.processedFile!.fileNamePlusExtension)\" completed!")
                self.status = .Succeeded
                completionCallBack()
            }
        }
    }
    
    



    // MARK: - Async Process functions

    /**
     Process the current AKAudioFile in background to return an
     AKAudioFile reversed (will play backward)

     - Parameters:
       - name: the name of resulting the file without its extension (String).
       - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
       - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.

     - Returns: A ReverseProcess Object.

     Notice that completionCallBack will be triggered from a
     background thread. Any UI update should be made using:

     dispatch_async(dispatch_get_main_queue()) {
     // UI updates...
     }
     */

    public func reverseAsynchronously( baseDir: BaseDirectory = .Temp,
                               name: String = "",
                               completionCallBack: AKCallback) -> ReverseProcess {

        let process = ReverseProcess(sourceFile: self, baseDir: baseDir, name: name, completionCallBack: completionCallBack)
        return process
    }

    /**
     Process the current AKAudioFile in background to return an
     AKAudioFile normalized with a peak of newMaxLevel dB if succeeded

     - Parameters:
       - name: the name of the resulting file without its extension (String).
       - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
       - newMaxLevel: max level targeted as a Float value (default if 0 dB)
       - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.

     - Returns: A NormalizeProcess Object.

     Notice that completionCallBack will be triggered from a
     background thread. Any UI update should be made using:

     dispatch_async(dispatch_get_main_queue()) {
     // UI updates...
     }
     */
    public func normalizeAsynchronously(baseDir: BaseDirectory = .Temp,
                                        name: String = "",
                                        newMaxLevel: Float = 0.0,
                                        completionCallBack: AKCallback) -> NormalizeProcess {

        let process = NormalizeProcess(sourceFile: self, baseDir: baseDir, name: name, newMaxLevel: newMaxLevel, completionCallBack: completionCallBack)
        return process
    }
    
    /**
     Process the current AKAudioFile in background to return an
     AKAudioFile with another file audio appended, if succeeded

     - Parameters:
       - file: AKAudioFile to be appended to the current file.
       - name: the name of the resulting file without its extension (String).
       - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
       - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.

     - Returns: an AppendProcess Object.

     Notice that completionCallBack will be triggered from a
     background thread. Any UI update should be made using:

     dispatch_async(dispatch_get_main_queue()) {
     // UI updates...
     }
     */
    public func appendAsynchronously(file: AKAudioFile,
                                     baseDir: BaseDirectory = .Temp,
                                     name: String = "",
                                     newMaxLevel: Float = 0.0,
                                     completionCallBack: AKCallback) -> AppendProcess {

        let process = AppendProcess(sourceFile: self,
                                    file: file,
                                    baseDir: baseDir,
                                    name: name,
                                    completionCallBack: completionCallBack)
        return process
    }
    
    
    /**
     Process the current AKAudioFile in background to return an
     AKAudioFile extracted from the current AKAudioFile, if succeeded

     - Parameters:
       - fromSample: the starting sampleFrame for extraction.
       - toSample: the ending sampleFrame for extraction
       - name: the name of the resulting file without its extension (String).
       - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp (Default is .Temp)
       - completionCallBack : AKCallback that will be triggered as soon as process has been completed or failed.

     - Returns: an ExtractProcess Object.

     Notice that completionCallBack will be triggered from a
     background thread. Any UI update should be made using:

     dispatch_async(dispatch_get_main_queue()) {
     // UI updates...
     }
     */
    public func extractAsynchronously(fromSample: Int64 = 0,
                                      toSample: Int64 = 0,
                                      baseDir: BaseDirectory = .Temp,
                                      name: String = "",
                                      completionCallBack: AKCallback) -> ExtractProcess {


        let fixedFrom = abs(fromSample)
        let fixedTo: Int64 = toSample == 0 ? Int64(self.samplesCount) : min(toSample, Int64(self.samplesCount))

        let process = ExtractProcess(sourceFile: self,
                                     fromSample: fixedFrom,
                                     toSample: fixedTo,
                                     baseDir: baseDir,
                                     name: name,
                                     completionCallBack: completionCallBack)
        return process
    }
    
    

}
