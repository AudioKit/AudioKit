// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKRhinoGuitarProcessorParameter) {
    AKRhinoGuitarProcessorParameterPreGain,
    AKRhinoGuitarProcessorParameterPostGain,
    AKRhinoGuitarProcessorParameterLowGain,
    AKRhinoGuitarProcessorParameterMidGain,
    AKRhinoGuitarProcessorParameterHighGain,
    AKRhinoGuitarProcessorParameterDistortion
};

#ifndef __cplusplus

AKDSPRef createRhinoGuitarProcessorDSP(void);

#else

#import "AKDSPBase.hpp"

class AKRhinoGuitarProcessorDSP : public AKDSPBase {
public:
    
    AKRhinoGuitarProcessorDSP();

    void init(int channelCount, double sampleRate) override;

    void deinit() override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
};

#endif

