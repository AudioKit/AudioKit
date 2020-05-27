// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKVocalTractParameter) {
    AKVocalTractParameterFrequency,
    AKVocalTractParameterTonguePosition,
    AKVocalTractParameterTongueDiameter,
    AKVocalTractParameterTenseness,
    AKVocalTractParameterNasality,
};

#ifndef __cplusplus

AKDSPRef createVocalTractDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"
#import "ParameterRamper.hpp"

class AKVocalTractDSP : public AKSoundpipeDSPBase {
public:
    AKVocalTractDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
    
private:
    
    sp_vocwrapper *vocwrapper;
    
    ParameterRamper frequencyRamp;
    ParameterRamper tonguePositionRamp;
    ParameterRamper tongueDiameterRamp;
    ParameterRamper tensenessRamp;
    ParameterRamper nasalityRamp;
};

#endif
