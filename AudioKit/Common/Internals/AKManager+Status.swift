// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import AudioToolbox

extension AKManager {

    @objc static var shouldBeRunning = false

    #if os(iOS)
    var isIAAConnected: Bool {
        #if !targetEnvironment(macCatalyst)
        do {
            let result: UInt32? = try AKManager.engine.outputNode.audioUnit?.getValue(
                forProperty: kAudioUnitProperty_IsInterAppConnected
            )
            return result == 1
        } catch {
            AKLog("could not get IAA status: \(error)")
        }
        #endif
        return false
    }
    #endif
}
