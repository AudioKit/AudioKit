// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDynaRageCompressorParameter) {
    AKDynaRageCompressorParameterRatio,
    AKDynaRageCompressorParameterThreshold,
    AKDynaRageCompressorParameterAttack,
    AKDynaRageCompressorParameterRelease,
    AKDynaRageCompressorParameterRageAmount,
    AKDynaRageCompressorParameterRageEnabled
};

#ifndef __cplusplus
#import <AudioKit/AKInterop.hpp>

AKDSPRef createDynaRageCompressorDSP(void);

#else

#import <AudioKit/AKDSPBase.hpp>

class AKDynaRageCompressorDSP : public AKDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
    
public:

    AKDynaRageCompressorDSP();
    
    void init(int channelCount, double sampleRate) override;
    
    void deinit() override;

    void reset() override;
    
    virtual void setParameter(AUParameterAddress address, float value, bool immediate) override;

    virtual float getParameter(AUParameterAddress address) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
