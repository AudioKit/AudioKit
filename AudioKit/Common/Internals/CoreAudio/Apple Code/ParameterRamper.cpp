//
//  ParameterRamper.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <cstdint>

#include "ParameterRamper.hpp"

#import <libkern/OSAtomic.h>
#import <stdatomic.h>

struct ParameterRamper::_Internal
{
    float clampLow, clampHigh;
    float _uiValue;
    float _goal;
    float inverseSlope;
    uint32_t samplesRemaining;
    volatile atomic_int changeCounter = 0;
    int32_t updateCounter = 0;
};

ParameterRamper::ParameterRamper(float value) : _private(new _Internal) {
    setImmediate(value);
}

ParameterRamper::~ParameterRamper() {
    delete _private;
}

void ParameterRamper::setImmediate(float value) {
    // only to be called from the render thread or when resources are not allocated.
    _private->_goal = _private->_uiValue = value;
    _private->inverseSlope = 0.0;
    _private->samplesRemaining = 0;
}

void ParameterRamper::init() {
    /*
     Call this from the kernel init.
     Updates the internal value from the UI value.
     */
    setImmediate(_private->_uiValue);
}

void ParameterRamper::reset() {
    _private->changeCounter = _private->updateCounter = 0;
}

void ParameterRamper::setUIValue(float value) {
    _private->_uiValue = value;
    atomic_fetch_add(&_private->changeCounter, 1);
}

float ParameterRamper::getUIValue() const {
    return _private->_uiValue;
}

void ParameterRamper::dezipperCheck(uint32_t rampDuration)
{
    // check to see if the UI has changed and if so, start a ramp to dezipper it.
    int32_t changeCounterSnapshot = _private->changeCounter;
    if (_private->updateCounter != changeCounterSnapshot) {
        _private->updateCounter = changeCounterSnapshot;
        startRamp(_private->_uiValue, rampDuration);
    }
}

void ParameterRamper::startRamp(float newGoal, uint32_t duration) {
    if (duration == 0) {
        setImmediate(newGoal);
    }
    else {
        /*
         Set a new ramp.
         Assigning to inverseSlope must come before assigning to goal.
         */
        _private->inverseSlope = (get() - newGoal) / float(duration);
        _private->samplesRemaining = duration;
        _private->_goal = _private->_uiValue = newGoal;
    }
}

float ParameterRamper::get() const {
    /*
     For long ramps, integrating a sum loses precision and does not reach
     the goal at the right time. So instead, a line equation is used. y = m * x + b.
     */
    return _private->inverseSlope * float(_private->samplesRemaining) + _private->_goal;
}

void ParameterRamper::step() {
    // Do this in each inner loop iteration after getting the value.
    if (_private->samplesRemaining != 0) {
        --_private->samplesRemaining;
    }
}

float ParameterRamper::getAndStep() {
    // Combines get and step. Saves a multiply-add when not ramping.
    if (_private->samplesRemaining != 0) {
        float value = get();
        --_private->samplesRemaining;
        return value;
    }
    else {
        return _private->_goal;
    }
}

void ParameterRamper::stepBy(uint32_t n) {
    /*
     When a parameter does not participate in the current inner loop, you
     will want to advance it after the end of the loop.
     */
    if (n >= _private->samplesRemaining) {
        _private->samplesRemaining = 0;
    }
    else {
        _private->samplesRemaining -= n;
    }
}
