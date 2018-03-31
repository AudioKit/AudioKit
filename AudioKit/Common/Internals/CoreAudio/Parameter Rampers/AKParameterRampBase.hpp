//
//  AKParameterRampBase.h
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AudioToolbox/AudioToolbox.h>
#import "AKDSPBase.hpp"  // have to put this here to get it included in umbrella header

#ifdef __cplusplus

class AKParameterRampBase {

protected:
    float _paramValue = 0;  // set by UI thread
    float _target = 0;
    float _value = 0;
    float _startValue = 0;
    int64_t _duration = 0;  // in samples
    int64_t _startSample = 0;

    void updateTarget(int64_t atSample) {
        _target = _paramValue;
        _startSample = atSample;
        _startValue = _value;
    }

public:

    virtual float computeValueAt(int64_t atSample) = 0;



    void setTarget(float value, bool immediate = false) {
        if (immediate) { _startValue = _paramValue = _value = _target = value; }
        else { _paramValue = value; }
    }

    void setDurationInSamples(int64_t duration) {
        if (duration >= 0) _duration = duration;
    }

    float getDurationInSamples() { return _duration; }

    void setRampTime(float seconds, int64_t sampleRate) {
        _duration = seconds * sampleRate;
    }

    float getRampTime(int64_t sampleRate) {
        return (sampleRate == 0) ? 0 : _duration / sampleRate;
    }

    float getValue() { return _value; }
    float getTarget() { return _target; }

    float advanceTo(int64_t atSample) {
        if (_paramValue != _target) { updateTarget(atSample); }
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

#endif

