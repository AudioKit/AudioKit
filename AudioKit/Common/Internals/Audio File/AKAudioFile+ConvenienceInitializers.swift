//
//  AKAudioFile+ConvenienceInitializers.swift
//  AudioKit
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

extension NSError {
  static var fileCreateError: NSError {
    return NSError(domain: NSURLErrorDomain,
                   code: NSURLErrorCannotCreateFile,
                   userInfo: nil)
  }
}

func ??<T> (lhs: T?, rhs: NSError) throws -> T {
  guard let l = lhs else { throw rhs }
  return l
}

func || (lhs: Bool, rhs: NSError) throws -> Bool {
  guard lhs else { throw rhs }
  return lhs
}

extension AKAudioFile {

    /// Opens a file for reading.
    ///
    /// - parameter name:    Filename, including the extension
    /// - parameter baseDir: Location of file, can be set to .Resources, .Documents or .Temp
    ///
    /// - returns: An initialized AKAudioFile for reading, or nil if init failed
    ///
    public convenience init(readFileName name: String,
                            baseDir: BaseDirectory = .resources) throws {
        let path: String = try baseDir.create(file: name)
        try self.init(forReading: URL(fileURLWithPath: path))
    }

    /// Initialize file for recording / writing purpose
    ///
    /// Default is a .caf AKAudioFile with AudioKit settings
    /// If file name is an empty String, a unique Name will be set
    /// If no baseDir is set, baseDir will be the Temp Directory
    ///
    /// From Apple doc: The file type to create is inferred from the file extension of fileURL.
    /// This method will overwrite a file at the specified URL if a file already exists.
    ///
    /// Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
    /// with a floating Point encoding. As a consequence, such files will fail to record properly.
    /// So it's better to use .caf (or .aif) files for recording purpose.
    ///
    /// Example of use: to create a temp .caf file with a unique name for recording:
    /// let recordFile = AKAudioFile()
    ///
    /// - Parameters:
    ///   - name: the name of the file without its extension (String).
    ///   - ext: the extension of the file without "." (String).
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp
    ///   - settings: The settings of the file to create.
    ///   - format: The processing commonFormat to use when writing.
    ///   - interleaved: Bool (Whether to use an interleaved processing format.)
    ///
    public convenience init(writeIn baseDir: BaseDirectory = .temp,
                            name: String? = nil,
                            settings: [String : Any] = AKSettings.audioFormat.settings)
        throws {
            let extPath: String = "\(name ?? UUID().uuidString).caf"
            let filePath: String = try baseDir.create(file: extPath, write: true)
            let fileURL = URL(fileURLWithPath: filePath)

            // Directory exists ?
            let absDirPath = fileURL.deletingLastPathComponent().path

            _ = try FileManager.default.fileExists(atPath: absDirPath) || .fileCreateError

            // AVLinearPCMIsNonInterleaved cannot be set to false (ignored but throw a warning)
            var fixedSettings = settings

            fixedSettings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)

            do {
                try self.init(forWriting: fileURL, settings: fixedSettings)
            } catch let error as NSError {
                AKLog("ERROR AKAudioFile: Couldn't create an AKAudioFile...")
                AKLog("Error: \(error)")
                throw NSError.fileCreateError
            }
    }

    /// Instantiate a file from Floats Arrays.
    ///
    /// To create a stereo file, you pass [leftChannelFloats, rightChannelFloats]
    /// where leftChannelFloats and rightChannelFloats are 2 arrays of FLoat values.
    /// Arrays must both have the same number of Floats.
    ///
    /// - Parameters:
    ///   - floatsArrays: An array of Arrays of floats
    ///   - name: the name of the file without its extension (String).
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp
    ///
    /// - Returns: a .caf AKAudioFile set to AudioKit settings (32 bits float @ 44100 Hz)
    ///
    public convenience init(createFileFromFloats floatsArrays: [[Float]],
                            baseDir: BaseDirectory = .temp,
                            name: String = "") throws {

        let channels = floatsArrays.count
        var fixedSettings = AKSettings.audioFormat.settings

        fixedSettings[AVNumberOfChannelsKey] = channels

        try self.init(writeIn: baseDir, name: name, settings: fixedSettings)

        // create buffer for floats
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100,
                                   channels: AVAudioChannelCount(channels))

        let buffer = AVAudioPCMBuffer(pcmFormat: format,
                                      frameCapacity:  AVAudioFrameCount(floatsArrays[0].count))

        // Fill the buffers

        for channel in 0..<channels {
            let channelNData = buffer.floatChannelData?[channel]
            for f in 0..<Int(buffer.frameCapacity) {
                channelNData?[f] = floatsArrays[channel][f]
            }
        }

        // set the buffer frameLength
        buffer.frameLength = buffer.frameCapacity

        // Write the buffer in file
        do {
            try self.write(from: buffer)
        } catch let error as NSError {
            AKLog("ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }

    }

    /// Convenience init to instantiate a file from an AVAudioPCMBuffer.
    ///
    /// - Parameters:
    ///   - buffer: the AVAudioPCMBuffer that will be used to fill the AKAudioFile
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp
    ///   - name: the name of the file without its extension (String).
    ///
    /// - Returns: a .caf AKAudioFile set to AudioKit settings (32 bits float @ 44100 Hz)
    ///
    public convenience init(fromAVAudioPCMBuffer buffer: AVAudioPCMBuffer,
                            baseDir: BaseDirectory = .temp,
                            name: String = "") throws {

        try self.init(writeIn: baseDir,
                      name: name)

        // Write the buffer in file
        do {
            try self.write(from: buffer)
        } catch let error as NSError {
            AKLog("ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }

    }
}
