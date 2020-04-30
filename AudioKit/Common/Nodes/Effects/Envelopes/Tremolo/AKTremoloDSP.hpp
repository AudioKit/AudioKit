// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTremoloParameter) {
    AKTremoloParameterFrequency,
    AKTremoloParameterDepth,
};

#ifndef __cplusplus

AKDSPRef createTremoloDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKTremoloDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKTremoloDSP();

    void setWavetable(const float* table, size_t length, int index) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
