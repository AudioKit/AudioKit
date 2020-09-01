// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKDSPBase.hpp"

#ifdef __cplusplus

class AKSoundpipeDSPBase: public AKDSPBase {
protected:
    struct sp_data *sp = nullptr;
public:
    AKSoundpipeDSPBase(int inputBusCount=1) : AKDSPBase(inputBusCount) {
        bCanProcessInPlace = true;
    }

    virtual void init(int channelCount, double sampleRate) override;
    virtual void deinit() override;
    virtual void processSample(int channel, float *in, float *out);
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
