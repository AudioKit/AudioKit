// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension FormatConverter {
    class func createError(message: String, code: Int = 1) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "com.audiodesigndesk.FormatConverter.error",
                       code: code,
                       userInfo: userInfo)
    }
}

public extension FormatConverter {
    /// Is this file a PCM file?
    /// - Parameters:
    ///   - url: The URL to parse
    ///   - ignorePathExtension: Do a deep parse rather than rely on the path extension
    /// - Returns: Bool or nil if it couldn't be determined
    class func isPCM(url: URL, ignorePathExtension _: Bool = false) -> Bool? {
        guard let value = isCompressed(url: url) else { return nil }
        return !value
    }

    /// Compressed format or not
    class func isCompressed(url: URL, ignorePathExtension: Bool = false) -> Bool? {
        guard !ignorePathExtension else {
            return isCompressedExt(url: url)
        }
        let ext = url.pathExtension.lowercased()

        switch ext {
        case "wav", "bwf", "aif", "aiff", "caf":
            return false

        case "m4a", "mp3", "mp4", "m4v", "mpg", "flac", "ogg":
            return true

        default:
            // if the file extension is missing or unknown, open the file and check it
            return isCompressedExt(url: url) ?? false
        }
    }

    private class func isCompressedExt(url: URL) -> Bool? {
        var inputFile: ExtAudioFileRef?

        func closeFiles() {
            if let strongFile = inputFile {
                // Log("🗑 Disposing input", inputURL.path)
                if noErr != ExtAudioFileDispose(strongFile) {
                    Log("Error disposing input file, could have a memory leak")
                }
            }
            inputFile = nil
        }

        // make sure these are closed on any exit
        defer {
            closeFiles()
        }

        if noErr != ExtAudioFileOpenURL(url as CFURL,
                                        &inputFile)
        {
            Log("Unable to open", url.lastPathComponent)
            return nil
        }

        guard let strongInputFile = inputFile else {
            return nil
        }

        var inputDescription = AudioStreamBasicDescription()
        var inputDescriptionSize = UInt32(MemoryLayout.stride(ofValue: inputDescription))

        if noErr != ExtAudioFileGetProperty(strongInputFile,
                                            kExtAudioFileProperty_FileDataFormat,
                                            &inputDescriptionSize,
                                            &inputDescription) {}

        let mFormatID = inputDescription.mFormatID

        switch mFormatID {
        case kAudioFormatLinearPCM,
             kAudioFormatAppleLossless: return false
        default:
            // basically all other format IDs are compressed
            return true
        }
    }
}

extension Comparable {
    // ie: 5.clamped(to: 7...10)
    // ie: 5.0.clamped(to: 7.0...10.0)
    // ie: "a".clamped(to: "b"..."h")
    /// **OTCore:**
    /// Returns the value clamped to the passed range.
    @inlinable func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
