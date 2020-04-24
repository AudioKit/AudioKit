//
//  AKConvolutionDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

#ifndef __cplusplus

AKDSPRef createConvolutionDSP(void);

void setPartitionLengthConvolutionDSP(AKDSPRef dsp, int length);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKConvolutionDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKConvolutionDSP();

    void setPartitionLength(int partLength);

    void setWavetable(const float* table, size_t length, int index) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void reset() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
