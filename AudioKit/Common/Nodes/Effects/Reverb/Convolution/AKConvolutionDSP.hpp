//
//  AKConvolutionDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKConvolutionParameter) {
    AKConvolutionParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createConvolutionDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKConvolutionDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> data;
 
public:
    AKConvolutionDSP();

    int defaultRampDurationSamples = 10000;
    
    void init(int _channels, double _sampleRate) override;

    void setUpTable(float *table, UInt32 size) override;
    void setPartitionLength(int partLength) override;
    void initConvolutionEngine() override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
