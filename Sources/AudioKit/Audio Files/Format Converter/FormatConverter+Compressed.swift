// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

// MARK: - internal helper functions

extension FormatConverter {
    /// Example of the most simplistic AVFoundation conversion.
    /// With this approach you can't really specify any settings other than the limited presets.
    /// No sample rate conversion in this. This isn't used in the public methods but is here
    /// for example.
    ///
    /// see `AVAssetExportSession`:
    /// *Prior to initializing an instance of AVAssetExportSession, you can invoke
    /// +allExportPresets to obtain the complete list of presets available. Use
    /// +exportPresetsCompatibleWithAsset: to obtain a list of presets that are compatible
    /// with a specific AVAsset.*
    ///
    /// This is no longer used in this class as it's not possible to convert sample rate or other
    /// required options. It will use the next function instead
    func convertCompressed(presetName: String, completionHandler: FormatConverterCallback? = nil) {
        Log("Not Implemented.")
    }

    /// Convert to compressed first creating a tmp file to PCM to allow more flexible conversion
    /// options to work.
    func convertCompressed(completionHandler: FormatConverterCallback? = nil) {
        Log("Not Implemented.")
    }
    
    /// The AVFoundation way. *This doesn't currently handle compressed input - only compressed output.*
    func convertPCMToCompressed(completionHandler: FormatConverterCallback? = nil) {
        Log("Not Implemented.")
    }
}
