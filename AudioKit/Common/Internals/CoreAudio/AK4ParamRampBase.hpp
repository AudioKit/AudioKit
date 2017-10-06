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
    
protected:
    float _target = 0;
    float _value = 0;
    int64_t _duration = 0;  // in samples
    int64_t _startSample = 0;
    
public:
    
    virtual float computeValueAt(int64_t atSample) = 0;
    
    void setTarget(float value, int64_t atSample) {
        _target = value;
        _startSample = atSample;
    }
    
    void setDurationInSamples(int64_t duration) {
        if (duration >= 0) _duration = duration;
    }
    
    float getDurationInSamples() { return _duration; }
    
    void setRampTime(float mSec, int64_t sampleRate) {
        _duration = mSec * sampleRate / 1000.0;
    }
    
    float getRampTime(int64_t sampleRate) {
        return (sampleRate == 0) ? 0 : _duration * 1000.0 / sampleRate;
    }

    float getValue() { return _value; }
    float getTarget() { return _target; }
    
    float advanceTo(int64_t atSample) {
        if (_value == _target) return _value;
        int64_t deltaSamples = atSample - _startSample;
        if (deltaSamples >= _duration || deltaSamples < 0) {
            _value = _target;
            _startSample = 0;  // for good measure
        } else {
            computeValueAt(atSample);
        }
        return _value;
    }
    
};

