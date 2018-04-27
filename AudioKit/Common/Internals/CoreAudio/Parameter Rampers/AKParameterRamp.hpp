//
//  AKParameterRamper.hpp
//  AudioKit
//
//  Created by Ryan Francesconi on 4/27/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKParameterRampBase.hpp" // have to put this here to get it included in umbrella header

#ifdef __cplusplus

// Variable Ramp Type Ramper
struct AKParameterRamp : AKParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        switch (getRampType()) {
            case 1:
                return computeExponential(atSample);
                break;
//            case 2:
//                return computeLogarithmic(atSample);
//                break;
            default:
                return computeLinear(atSample);
                break;
        }
    }

    float computeLinear(int64_t atSample) {
        float fract = (float)(atSample - _startSample) / _duration;
        return _value = _startValue + (_target - _startValue) * fract;
    }

    float computeExponential(int64_t atSample) {
        // position
        float minp = _startSample;
        float maxp = _startSample + _duration;

        // values
        float minv = log(_startValue);
        float maxv = log(_target);

        // calculate adjustment factor
        float scale = (maxv-minv) / (maxp-minp);

        _value = exp(minv + scale * (atSample-minp));

        //        printf( "%6.4lf %6.4lf \n", _startValue, _target);
        //        printf( "%lld %6.4lld %lld %6.4lf %6.4lf \n", _startSample, _duration, atSample, currSample, _value );
        return _value;
    }

// TODO
//    float computeLogarithmic(int64_t atSample) {
//
//    }

};

#endif


