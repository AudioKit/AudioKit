// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKRhinoGuitarProcessorParameter) {
    AKRhinoGuitarProcessorParameterPreGain,
    AKRhinoGuitarProcessorParameterPostGain,
    AKRhinoGuitarProcessorParameterLowGain,
    AKRhinoGuitarProcessorParameterMidGain,
    AKRhinoGuitarProcessorParameterHighGain,
    AKRhinoGuitarProcessorParameterDistortion
};

AK_API AKDSPRef akRhinoGuitarProcessorCreateDSP(void);

