// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

/// Effects Chain management
extension AKAudioUnitManager {
    /// Create the Audio Unit at the specified index of the chain
    public func insertAudioUnit(name: String, at index: Int) {
        guard _effectsChain.indices.contains(index) else {
            AKLog("\(index) index is invalid.", type: .error)
            return
        }
        guard availableEffects.isNotEmpty else {
            AKLog("You must call requestEffects before using this function. availableEffects is empty", type: .error)
            return
        }

        if let component = (availableEffects.first { $0.name == name }) {
            let acd = component.audioComponentDescription

            AKAudioUnitManager.createEffectAudioUnit(acd) { audioUnit in
                guard let audioUnit = audioUnit else {
                    AKLog("Unable to create audioUnit", type: .error)
                    return
                }

                if audioUnit.inputFormat(forBus: 0).channelCount == 1 {
                    AKLog("\(audioUnit.name) is a Mono effect. Please select a stereo version of it.", type: .error)
                }

                // AKLog("* \(audioUnit.name) : Audio Unit created at index \(index), version: \(audioUnit)")

                self._effectsChain[index] = audioUnit
                self.connectEffects()
                DispatchQueue.main.async {
                    self.delegate?.audioUnitManager(self, didAddEffectAtIndex: index)
                }
            }

        } else if let avUnit = AKAudioUnitManager.createInternalEffect(name: name) {
            _effectsChain[index] = avUnit
            connectEffects()
            DispatchQueue.main.async {
                self.delegate?.audioUnitManager(self, didAddEffectAtIndex: index)
            }
        } else {
            AKLog("Error: Unable to find \(name) in availableEffects.", type: .error)
        }
    }

    public func removeEffect(at index: Int, reconnectChain: Bool = true) {
        if let au = _effectsChain[index] {
            // AKLog("removeEffect: \(au.auAudioUnit.audioUnitName ?? "")")

            if au.engine != nil {
//                engine.disconnectNodeInput(au)
//                engine.detach(au)
            }
        }
        _effectsChain[index] = nil

        if reconnectChain {
            connectEffects()
        }
        delegate?.audioUnitManager(self, didRemoveEffectAtIndex: index)
    }

    /// Removes all effects from the effectsChain and detach Audio Units from the engine
    public func removeEffects() {
        for i in 0 ..< _effectsChain.count {
            if let au = _effectsChain[i] {
                if au.engine != nil {
//                    engine.disconnectNodeInput(au)
//                    engine.detach(au)
                }
                _effectsChain[i] = nil
            }
        }
    }

    /// called from client to hook the chain together
    /// firstNode would be something like a player, and last something like a mixer that's headed
    /// to the output.
    public func connectEffects(firstNode: AKNode? = nil, lastNode: AKNode? = nil) {
        if firstNode != nil {
            input = firstNode
        }

        if lastNode != nil {
            output = lastNode
        }

        guard let input = input else {
            AKLog("input is nil", type: .error)
            return
        }
        guard let output = output else {
            AKLog("output is nil", type: .error)
            return
        }

        // it's an effects sandwich
        let inputAV = input.avAudioUnitOrNode
        let effects = linkedEffects
        let outputAV = output.avAudioUnitOrNode

        // where to take the processing format from. Can take from the output of the chain's nodes or from the input
        let processingFormat = useSystemAVFormat ? AKSettings.audioFormat : inputAV.outputFormat(forBus: 0)
        // AKLog("\(effects.count) to connect... chain source format: \(processingFormat), pulled from \(input)")

        if effects.isEmpty {
//            engine.connect(inputAV, to: outputAV, format: processingFormat)
            return
        }
        var au = effects[0]

//        engine.connect(inputAV, to: au, format: processingFormat)

        if effects.count > 1 {
            for i in 1 ..< effects.count {
                au = effects[i]
                let prevAU = effects[i - 1]

//                engine.connect(prevAU, to: au, format: processingFormat)
            }
        }

//        engine.connect(au, to: outputAV, format: processingFormat)
    }
}
