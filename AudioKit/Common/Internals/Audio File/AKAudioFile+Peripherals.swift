// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKAudioFile {
    /// Create an AKAppleSampler loaded with the current AKAudioFile
    public var sampler: AKAppleSampler? {
        let fileSampler = AKAppleSampler()
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
            AKLog("Cannot create sampler: " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }
        return fileSampler
    }

    /// Create an AKMIDISampler loaded with the current AKAudioFile
    public var midiSampler: AKMIDISampler? {
        let fileSampler = AKMIDISampler(name: "File Sampler")
        do {
            try fileSampler.loadAudioFile(self)
        } catch let error as NSError {
            AKLog("Cannot create sampler: " + error.localizedDescription, log: OSLog.fileHandling, type: .error)
        }
        return fileSampler
    }

    /// Create an AKAudioPlayer to play the current AKAudioFile
    public var player: AKPlayer {
        return AKPlayer(audioFile: self)
    }
}
