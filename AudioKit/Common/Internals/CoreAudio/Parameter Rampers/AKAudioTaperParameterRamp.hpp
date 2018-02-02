//
//  AKAudioTaperParameterRamp
//  AudioKit
//
//  Created by Ryan Francesconi on 1/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKParameterRampBase.hpp" // have to put this here to get it included in umbrella header

#ifdef __cplusplus

struct AKAudioTaperParameterRamp : AKParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        float fract = (float)(atSample - _startSample) / _duration;
        float linValue = _startValue + (_target - _startValue) * fract;
        _value = taper(linValue);
        //printf( "%6.4lf %6.4lf \n", linValue, _value );
        // if (_value > 2) { _value = 2; }
        return _value;
    }

    // This doesn't work correctly
    float taper(float input) {
        float startRange = 20.0 * log10(_startValue);
        float endRange = 20.0 * log10(_target);

        float dBrange = abs(endRange - startRange);
        float zeroShape = pow(10, -dBrange / 20);
        float unityFix = 1.0f / (1 + zeroShape);
        float gain = pow(10, ((dBrange * input - dBrange)/20) - zeroShape) / unityFix;
        return gain;
    }

};

#endif



