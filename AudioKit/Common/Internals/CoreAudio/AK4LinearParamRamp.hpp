//
//  LinearParamRamp.hpp
//  AudioKit
//
//  Created by Andrew Voelkel on 9/18/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AK4ParamRampBase.hpp"

struct AK4LinearParamRamp : AK4ParamRampBase {
    
    float computeValueAt(int64_t atSample) override {
        float fract = (atSample - startSample) / duration;
        return (target - value) * fract;
    }
    
};

