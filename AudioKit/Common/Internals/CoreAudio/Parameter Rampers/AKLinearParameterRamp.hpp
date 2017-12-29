//
//  AKLinearParameterRamp.hpp
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKParameterRampBase.hpp"

struct AKLinearParameterRamp : AKParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        float fract = (float)(atSample - _startSample) / _duration;
        return _value = _startValue + (_target - _startValue) * fract;
    }

};

