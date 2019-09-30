//
//  AKLinearParameterRamp.hpp
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKParameterRampBase.hpp" // have to put this here to get it included in umbrella header

#ifdef __cplusplus

// Currently Unused

struct AKLinearParameterRamp : AKParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        float fract = (float)(atSample - _startSample) / _duration;
        return _value = _startValue + (_target - _startValue) * fract;
    }

};

#endif

