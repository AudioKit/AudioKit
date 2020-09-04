// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// Utility class to manage DSP parameters which can change value smoothly (be ramped) while rendering, without introducing clicks or other distortion into the signal.
//
// Originally based on Apple sample code, but significantly altered by Aurelius Prochazka


#import <cstdint>

#include "ParameterRamper.hpp"

#import <AudioToolbox/AUAudioUnit.h>
#include <atomic>
#include <math.h>

struct ParameterRamper::InternalData {
    float uiValue;
    float sampleRate;
    float defaultRampDuration = 0.02;
    uint32_t offset = 0;
    float startingPoint;
    float goal;
    uint32_t duration;
    uint32_t samplesRemaining;
    std::atomic_int changeCounter{0};
    int32_t updateCounter = 0;
};

ParameterRamper::ParameterRamper(float value) : data(new InternalData)
{
    setImmediate(value);
}

ParameterRamper::~ParameterRamper() = default;

void ParameterRamper::setImmediate(float value)
{
    // only to be called from the render thread or when resources are not allocated.
    data->goal = data->uiValue = data->startingPoint = value;
    data->samplesRemaining = 0;
}

/// Call this from AUAudioUnit's allocateRenderResources
void ParameterRamper::init(float sampleRate)
{
    data->sampleRate = sampleRate;
    data->duration = data->defaultRampDuration * sampleRate;
    setImmediate(data->uiValue);
}

void ParameterRamper::reset()
{
    data->changeCounter = data->updateCounter = 0;
}

void ParameterRamper::setDefaultRampDuration(float duration)
{
    data->defaultRampDuration = duration;
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

void ParameterRamper::dezipperCheck()
{
    dezipperCheck(data->defaultRampDuration * data->sampleRate);
}

void ParameterRamper::dezipperCheck(uint32_t rampDuration)
{
    // check to see if the UI has changed and if so, start a ramp to dezipper it.
    int32_t changeCounterSnapshot = data->changeCounter;
    if (data->updateCounter != changeCounterSnapshot) {
        data->updateCounter = changeCounterSnapshot;
        data->offset = 0; // only use offset for automation
        startRamp(data->uiValue, rampDuration);
    }
}

void ParameterRamper::startRamp(float newGoal, uint32_t duration)
{
    if (duration == 0) {
        setImmediate(newGoal);
    } else {
        data->startingPoint = get();
        data->duration = duration;
        data->samplesRemaining = duration - data->offset;
        data->goal = data->uiValue = newGoal;
    }
}

float ParameterRamper::get() const
{
    return float(data->duration - data->samplesRemaining) / float(data->duration);
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
