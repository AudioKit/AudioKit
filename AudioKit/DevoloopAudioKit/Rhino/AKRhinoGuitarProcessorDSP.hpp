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

#endif

