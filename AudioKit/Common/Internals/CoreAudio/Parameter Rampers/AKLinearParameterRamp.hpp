//
//  AKLinearParameterRamp.hpp
//  AudioKit
//
//  Created by Andrew Voelkel on 9/18/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKParameterRampBase.hpp"

struct AKLinearParameterRamp : AKParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        float fract = (float)(atSample - _startSample) / _duration;
        return _value = (_target - _startSample) * fract;
    }

};

