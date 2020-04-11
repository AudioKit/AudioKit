//
// ParameterRamper.cpp
// AudioKit
//
// Utility class to manage DSP parameters which can change value smoothly (be ramped) while rendering, without introducing clicks or other distortion into the signal.
//
// Originally based on Apple sample code, but significantly altered by Aurelius Prochazka
//
//  Copyright © 2020 AudioKit. All rights reserved.
//

#import <cstdint>

#include "ParameterRamper.hpp"

#import <AudioToolbox/AUAudioUnit.h>
#import <libkern/OSAtomic.h>
#import <stdatomic.h>
#include <math.h>

struct ParameterRamper::InternalData {
    float clampLow, clampHigh;
    float uiValue;
    float taper = 1;
    float skew = 0;
    uint32_t offset = 0;
    float startingPoint;
    float goal;
    uint32_t duration;
    uint32_t samplesRemaining;
    volatile atomic_int changeCounter = 0;
    int32_t updateCounter = 0;
};

ParameterRamper::ParameterRamper(float value) : data(new InternalData)
{
    setImmediate(value);
}

ParameterRamper::~ParameterRamper()
{
    delete data;
}

void ParameterRamper::setImmediate(float value)
{
    // only to be called from the render thread or when resources are not allocated.
    data->goal = data->uiValue = data->startingPoint = value;
    data->samplesRemaining = 0;
}

void ParameterRamper::init()
{
    /*
     Call this from the kernel init.
     Updates the internal value from the UI value.
     */
    setImmediate(data->uiValue);
}

void ParameterRamper::reset()
{
    data->changeCounter = data->updateCounter = 0;
}

void ParameterRamper::setTaper(float taper)
{
    data->taper = taper;
    atomic_fetch_add(&data->changeCounter, 1);
}

float ParameterRamper::getTaper() const
{
    return data->taper;
}

void ParameterRamper::setSkew(float skew)
{
    if (skew > 1) {
        skew = 1.0;
    }
    if (skew < 0) {
        skew = 0.0;
    }
    data->skew = skew;
    atomic_fetch_add(&data->changeCounter, 1);
}

float ParameterRamper::getSkew() const
{
    return data->skew;
}

void ParameterRamper::setOffset(uint32_t offset)
{
    if (offset < 0) {
        offset = 0;
    }
    data->offset = offset;
    atomic_fetch_add(&data->changeCounter, 1);
}

uint32_t ParameterRamper::getOffset() const
{
    return data->offset;
}

void ParameterRamper::setUIValue(float value)
{
    data->uiValue = value;
    atomic_fetch_add(&data->changeCounter, 1);
}

float ParameterRamper::getUIValue() const
{
    return data->uiValue;
}

void ParameterRamper::dezipperCheck(uint32_t rampDuration)
{
    // check to see if the UI has changed and if so, start a ramp to dezipper it.
    int32_t changeCounterSnapshot = data->changeCounter;
    if (data->updateCounter != changeCounterSnapshot) {
        data->updateCounter = changeCounterSnapshot;
        startRamp(data->uiValue, rampDuration);
    }
}

void ParameterRamper::startRamp(float newGoal, uint32_t duration)
{
    if (duration == 0) {
        setImmediate(newGoal);
    } else {
        data->startingPoint = data->uiValue;
        data->duration = duration;
        data->samplesRemaining = duration - data->offset;
        data->goal = data->uiValue = newGoal;
    }
}

float ParameterRamper::get() const
{
    float x = float(data->duration - data->samplesRemaining) / float(data->duration);
    float taper1 = data->startingPoint + (data->goal - data->startingPoint) * pow(x, abs(data->taper));

    float absxm1 = abs(float(data->duration - data->samplesRemaining) / float(data->duration) - 1.0);

    float taper2 = data->startingPoint + (data->goal - data->startingPoint) * (1.0 - pow(absxm1, 1.0 / abs(data->taper)));

    return taper1 * (1.0 - data->skew) + taper2 * data->skew;
}

void ParameterRamper::step()
{
    // Do this in each inner loop iteration after getting the value.
    if (data->samplesRemaining != 0) {
        --data->samplesRemaining;
    }
}

float ParameterRamper::getAndStep()
{
    // Combines get and step. Saves a multiply-add when not ramping.
    if (data->samplesRemaining != 0) {
        float value = get();
        --data->samplesRemaining;
        return value;
    } else {
        return data->goal;
    }
}

void ParameterRamper::stepBy(uint32_t n)
{
    /*
     When a parameter does not participate in the current inner loop, you
     will want to advance it after the end of the loop.
     */
    if (n >= data->samplesRemaining) {
        data->samplesRemaining = 0;
    } else {
        data->samplesRemaining -= n;
    }
}
