// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "ParameterRampBase.h" // have to put this here to get it included in umbrella header

#ifdef __cplusplus

// Currently Unused

struct LinearParameterRamp : ParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        float fract = (float)(atSample - _startSample) / _duration;
        return _value = _startValue + (_target - _startValue) * fract;
    }

};

#endif

