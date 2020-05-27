// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Preset for the AKFMOscillator
public extension AKFMOscillator {

    /// Stun Ray Preset
    func presetStunRay() {
        baseFrequency.value = 200
        carrierMultiplier.value = 90
        modulatingMultiplier.value = 10
        modulationIndex.value = 25
    }

    /// Fog Horn Preset
    func presetFogHorn() {
        baseFrequency.value = 25
        carrierMultiplier.value = 10
        modulatingMultiplier.value = 5
        modulationIndex.value = 10
    }

    /// Buzzer Preset
    func presetBuzzer() {
        baseFrequency.value = 400
        carrierMultiplier.value = 28
        modulatingMultiplier.value = 0.5
        modulationIndex.value = 100
    }

    /// Spiral Preset
    func presetSpiral() {
        baseFrequency.value = 5
        carrierMultiplier.value = 280
        modulatingMultiplier.value = 0.2
        modulationIndex.value = 100
    }

    /// Wobble Preset
    func presetWobble() {
        baseFrequency.value = 20
        carrierMultiplier.value = 10
        modulatingMultiplier.value = 0.9
        modulationIndex.value = 20
    }
}
