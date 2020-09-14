// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// Utility class to manage DSP parameters which can change value smoothly (be ramped) while rendering, without introducing clicks or other distortion into the signal.
//
// Originally based on Apple sample code, but significantly altered by Aurelius Prochazka

#pragma once

#ifdef __cplusplus

// N.B. This is C++.

#import <AudioToolbox/AudioToolbox.h>
#import <libkern/OSAtomic.h>

#import <atomic>

class ParameterRamper {
    float clampLow, clampHigh;
    std::atomic<float> _uiValue{0};
    float _goal;
    float inverseSlope;
    AUAudioFrameCount samplesRemaining;
    std::atomic<int32_t> changeCounter;
    int32_t updateCounter = 0;

    void setImmediate(float value) {
        // only to be called from the render thread or when resources are not allocated.
        _goal = _uiValue = value;
        inverseSlope = 0.0;
        samplesRemaining = 0;
    }

public:
    ParameterRamper(float value = 0.0f) : changeCounter(0) {
        setImmediate(value);
    }

    void init() {
        /*
         Call this from the kernel init.
         Updates the internal value from the UI value.
         */
        setImmediate(_uiValue);
    }

    void reset() {
        changeCounter = updateCounter = 0;
    }

    void setUIValue(float value) {
        _uiValue = value;
        std::atomic_fetch_add(&changeCounter, 1);
    }

    float getUIValue() const { return _uiValue; }

    void dezipperCheck(AUAudioFrameCount rampDuration)
    {
        // check to see if the UI has changed and if so, start a ramp to dezipper it.
        int32_t changeCounterSnapshot = changeCounter;
        if (updateCounter != changeCounterSnapshot) {
            updateCounter = changeCounterSnapshot;
            startRamp(_uiValue, rampDuration);
        }
    }

    void startRamp(float newGoal, AUAudioFrameCount duration) {
        if (duration == 0) {
            setImmediate(newGoal);
        }
        else {
            /*
             Set a new ramp.
             Assigning to inverseSlope must come before assigning to goal.
             */
            inverseSlope = (get() - newGoal) / float(duration);
            samplesRemaining = duration;
            _goal = _uiValue = newGoal;
        }
    }

    float get() const {
        /*
         For long ramps, integrating a sum loses precision and does not reach
         the goal at the right time. So instead, a line equation is used. y = m * x + b.
         */
        return inverseSlope * float(samplesRemaining) + _goal;
    }

    void step() {
        // Do this in each inner loop iteration after getting the value.
        if (samplesRemaining != 0) {
            --samplesRemaining;
        }
    }

    float getAndStep() {
        // Combines get and step. Saves a multiply-add when not ramping.
        if (samplesRemaining != 0) {
            float value = get();
            --samplesRemaining;
            return value;
        }
        else {
            return _goal;
        }
    }

    void stepBy(AUAudioFrameCount n) {
        /*
         When a parameter does not participate in the current inner loop, you
         will want to advance it after the end of the loop.
         */
        if (n >= samplesRemaining) {
            samplesRemaining = 0;
        }
        else {
            samplesRemaining -= n;
        }
    }
};

#endif
