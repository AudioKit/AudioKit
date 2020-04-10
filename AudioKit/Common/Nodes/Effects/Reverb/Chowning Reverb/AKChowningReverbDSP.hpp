// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKChowningReverbParameter) {
    AKChowningReverbParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createChowningReverbDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKChowningReverbDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKChowningReverbDSP();
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
