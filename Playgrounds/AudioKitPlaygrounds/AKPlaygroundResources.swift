//
//  AKPlaygroundResources.swift
//  AudioKit Playgrounds
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

public var playgroundAudioFiles: [String] {
    let mp3URLs = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "", localization: "")
    let wavURLs = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: "", localization: "")
    let aifURLs = Bundle.main.urls(forResourcesWithExtension: "aif", subdirectory: "", localization: "")
    let m4aURLs = Bundle.main.urls(forResourcesWithExtension: "m4a", subdirectory: "", localization: "")
    let fileURLs: [URL] = mp3URLs! + wavURLs! + aifURLs! + m4aURLs!
    return fileURLs.flatMap{ $0.lastPathComponent }.sorted()
}
