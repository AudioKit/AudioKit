//
//  AKAutoPannerDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAutoPannerParameter) {
    AKAutoPannerParameterFrequency,
    AKAutoPannerParameterDepth,
};

#ifndef __cplusplus

AKDSPRef createAutoPannerDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKAutoPannerDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
   
public:
    AKAutoPannerDSP();

    void setWavetable(const float* table, size_t length, int index) override;

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(uint32_t frameCount, uint32_t bufferOffset) override;
};

#endif
