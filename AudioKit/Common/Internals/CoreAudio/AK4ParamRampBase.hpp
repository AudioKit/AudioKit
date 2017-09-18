//
//  AK4ParamRampBase.h
//  AudioKit
//
//  Created by Andrew Voelkel on 9/18/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import <AudioToolbox/AudioToolbox.h>
#import "AK4DspBase.hpp"

struct AK4ParamRampBase {
    
    float target = 0;
    float value = 0;
    float duration = 0;  // in samples
    int64_t startSample = 0;
    
    virtual float computeValueAt(int64_t atSample) = 0;
    
    void setTarget(float value, int64_t atSample) {
        target = value;
        startSample = atSample;
    }
    
    float advanceTo(int64_t atSample) {
        if (value == target) return value;
        if ((atSample - startSample) >= duration) {
            value = target;
        } else {
        value = computeValueAt(atSample);
        }
        return value;
    }
    
};

