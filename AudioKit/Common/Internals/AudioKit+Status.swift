//
//  AudioKit+Status.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/19/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
import AudioToolbox

extension AudioKit {

    // MARK: Global audio format (44.1K, Stereo)

    /// Format of AudioKit Nodes
    @available(*, deprecated, renamed: "AKSettings.audioFormat")
    @objc public static var format: AVAudioFormat {
        return AKSettings.audioFormat
    }

    @objc static var shouldBeRunning = false

    #if os(iOS)
    var isIAAConnected: Bool {
        #if !targetEnvironment(macCatalyst)
        do {
            let result: UInt32? = try AudioKit.engine.outputNode.audioUnit?.getValue(forProperty: kAudioUnitProperty_IsInterAppConnected)
            return result == 1
        } catch {
            AKLog("could not get IAA status: \(error)")
        }
        #endif
        return false
    }
    #endif
}
