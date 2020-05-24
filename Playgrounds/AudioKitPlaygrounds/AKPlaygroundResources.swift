// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

public var playgroundAudioFiles: [String] {
    let mp3URLs = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "", localization: "")
    let wavURLs = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: "", localization: "")
    let aifURLs = Bundle.main.urls(forResourcesWithExtension: "aif", subdirectory: "", localization: "")
    let m4aURLs = Bundle.main.urls(forResourcesWithExtension: "m4a", subdirectory: "", localization: "")
    let fileURLs: [URL] = mp3URLs! + wavURLs! + aifURLs! + m4aURLs!
    return fileURLs.compactMap { $0.lastPathComponent }.sorted()
}
