//
//  SDModulatedDelayDSPKernel.hpp
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

#import "SDModulatedDelayStuff.hpp"

#define FLANGER_MIN_DELAY_MS 0.01f
#define FLANGER_MAX_DELAY_MS 10.0f
#define FLANGER_MIN_FEEDBACK -0.95f
#define FLANGER_MAX_FEEDBACK 0.95f
#define FLANGER_DEFAULT_DRYWETMIX 0.0f

#define CHORUS_MIN_DELAY_MS 4.0f
#define CHORUS_MAX_DELAY_MS 24.0f
#define CHORUS_MIN_FEEDBACK 0.0f
#define CHORUS_MAX_FEEDBACK 0.25f
#define CHORUS_DEFAULT_DRYWETMIX 0.0f

#define MIN_FREQUENCY_HZ 0.1f
#define DEFAULT_FREQUENCY_HZ 1.0f
#define MAX_FREQUENCY_HZ 10.0f
#define MIN_FRACTION 0.0f
#define MAX_FRACTION 1.0f

typedef enum {
    kChorus,
    kFlanger
} SDMDEffectType;

enum {
    frequencyAddress = 0,
    depthAddress = 1,
    dryWetMixAddress = 2,
    feedbackAddress = 3
};

class SDModulatedDelayDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    SDModulatedDelayDSPKernel(SDMDEffectType type)
        : effectType(type)
        , frequency(DEFAULT_FREQUENCY_HZ)
        , depth(MIN_FRACTION)
        , feedback(MIN_FRACTION)
        , dryWetMix(CHORUS_DEFAULT_DRYWETMIX)
        , frequencyRamper(DEFAULT_FREQUENCY_HZ)
        , depthRamper(MIN_FRACTION)
        , feedbackRamper(MIN_FRACTION)
        , dryWetMixRamper(CHORUS_DEFAULT_DRYWETMIX)
    {
        switch (type) {
            case kFlanger:
                frequency = DEFAULT_FREQUENCY_HZ;
                depth = MIN_FRACTION;
                feedback = MIN_FRACTION;
                dryWetMix = FLANGER_DEFAULT_DRYWETMIX;
                break;
                
            case kChorus:
            default:
                break;
        }
        frequencyRamper.setImmediate(frequency);
        depthRamper.setImmediate(depth);
        dryWetMixRamper.setImmediate(dryWetMix);
        feedbackRamper.setImmediate(feedback);
    }

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        frequencyRamper.init();
        depthRamper.init();
        dryWetMixRamper.init();
        feedbackRamper.init();
        
        minDelayMs = CHORUS_MIN_DELAY_MS;
        maxDelayMs = CHORUS_MAX_DELAY_MS;
        switch (effectType) {
            case kFlanger:
                minDelayMs = FLANGER_MIN_DELAY_MS;
                maxDelayMs = FLANGER_MAX_DELAY_MS;
                modOscillator.initTriangle(_sampleRate, DEFAULT_FREQUENCY_HZ);
                break;
            case kChorus:
            default:
                modOscillator.initSinusoid(_sampleRate, DEFAULT_FREQUENCY_HZ);
                break;
        }
        delayRangeMs = 0.5f * (maxDelayMs - minDelayMs);
        midDelayMs = 0.5f * (minDelayMs + maxDelayMs);
        leftDelayLine.init(_sampleRate, maxDelayMs);
        rightDelayLine.init(_sampleRate, maxDelayMs);
        leftDelayLine.setDelayMs(midDelayMs);
        rightDelayLine.setDelayMs(midDelayMs);
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
    }

    void reset() {
        resetted = true;
        frequencyRamper.reset();
        depthRamper.reset();
        dryWetMixRamper.reset();
        feedbackRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, MIN_FREQUENCY_HZ, MAX_FREQUENCY_HZ);
        frequencyRamper.setImmediate(frequency);
        modOscillator.setFrequency(frequency);
    }
    
    void setDepth(float value) {
        depth = clamp(value, MIN_FRACTION, MAX_FRACTION);
        depthRamper.setImmediate(depth);
    }
    
    void setDryWetMix(float value) {
        dryWetMix = clamp(value, MIN_FRACTION, MAX_FRACTION);
        dryWetMixRamper.setImmediate(dryWetMix);
    }
    
    void setFeedback(float value) {
        float minFeedback = CHORUS_MIN_FEEDBACK;
        float maxFeedback = CHORUS_MAX_FEEDBACK;
        switch (effectType) {
            case kFlanger:
                minFeedback = FLANGER_MIN_FEEDBACK;
                maxFeedback = FLANGER_MAX_FEEDBACK;
                break;
                
            case kChorus:
            default:
                break;
        }
        feedback = clamp(value, minFeedback, maxFeedback);
        feedbackRamper.setImmediate(feedback);
        leftDelayLine.setFeedback(feedback);
        rightDelayLine.setFeedback(feedback);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        float minFeedback = CHORUS_MIN_FEEDBACK;
        float maxFeedback = CHORUS_MAX_FEEDBACK;
        switch (effectType) {
            case kFlanger:
                minFeedback = FLANGER_MIN_FEEDBACK;
                maxFeedback = FLANGER_MAX_FEEDBACK;
                break;
                
            case kChorus:
            default:
                break;
        }
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, MIN_FREQUENCY_HZ, MAX_FREQUENCY_HZ));
                break;
            case depthAddress:
                depthRamper.setUIValue(clamp(value, MIN_FRACTION, MAX_FRACTION));
                break;
            case dryWetMixAddress:
                dryWetMixRamper.setUIValue(clamp(value, MIN_FRACTION, MAX_FRACTION));
                break;
            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, minFeedback, maxFeedback));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();
            case depthAddress:
                return depthRamper.getUIValue();
            case dryWetMixAddress:
                return dryWetMixRamper.getUIValue();
            case feedbackAddress:
                return feedbackRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        float minFeedback = CHORUS_MIN_FEEDBACK;
        float maxFeedback = CHORUS_MAX_FEEDBACK;
        switch (effectType) {
            case kFlanger:
                minFeedback = FLANGER_MIN_FEEDBACK;
                maxFeedback = FLANGER_MAX_FEEDBACK;
                break;
                
            case kChorus:
            default:
                break;
        }
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, MIN_FREQUENCY_HZ, MAX_FREQUENCY_HZ), duration);
                break;
            case depthAddress:
                depthRamper.startRamp(clamp(value, MIN_FRACTION, MAX_FRACTION), duration);
                break;
            case dryWetMixAddress:
                dryWetMixRamper.startRamp(clamp(value, MIN_FRACTION, MAX_FRACTION), duration);
                break;
            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, minFeedback, maxFeedback), duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = frequencyRamper.getAndStep();
            modOscillator.setFrequency(frequency);
            depth = depthRamper.getAndStep();
            dryWetMix = dryWetMixRamper.getAndStep();
            feedback = feedbackRamper.getAndStep();
            leftDelayLine.setFeedback(feedback);
            rightDelayLine.setFeedback(feedback);

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            
            float *inLeft  = (float *)inBufferListPtr->mBuffers[0].mData  + frameOffset;
            float *outLeft = (float *)outBufferListPtr->mBuffers[0].mData + frameOffset;
            float *inRight  = (float *)inBufferListPtr->mBuffers[1].mData  + frameOffset;
            float *outRight = (float *)outBufferListPtr->mBuffers[1].mData + frameOffset;

            float modLeft, modRight;
            modOscillator.getSamples(&modLeft, &modRight);

            float leftDelayMs = midDelayMs + delayRangeMs * depth * modLeft;
            float rightDelayMs = midDelayMs + delayRangeMs * depth * modRight;
            switch (effectType) {
                case kFlanger:
                    leftDelayMs = minDelayMs + delayRangeMs * depth * (1.0f + modLeft);
                    rightDelayMs = minDelayMs + delayRangeMs * depth * (1.0f + modRight);
                    break;
                    
                case kChorus:
                default:
                    break;
            }
            leftDelayLine.setDelayMs(leftDelayMs);
            rightDelayLine.setDelayMs(rightDelayMs);

            float dryFraction = 1.0f - dryWetMix;
            *outLeft = dryFraction * (*inLeft) + dryWetMix * leftDelayLine.push(*inLeft);
            *outRight = dryFraction * (*inRight) + dryWetMix * rightDelayLine.push(*inRight);
        }
    }

    // MARK: Member Variables

private:
    SDMDEffectType effectType;
    float minDelayMs, maxDelayMs, midDelayMs, delayRangeMs;
    SDDelayLine leftDelayLine;
    SDDelayLine rightDelayLine;
    SDTwoPhaseOscillator modOscillator;
    float frequency;
    float depth;
    float feedback;
    float dryWetMix;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper;
    ParameterRamper depthRamper;
    ParameterRamper feedbackRamper;
    ParameterRamper dryWetMixRamper;
};

class AKChorusDSPKernel : public SDModulatedDelayDSPKernel {
public:
    AKChorusDSPKernel() : SDModulatedDelayDSPKernel(kChorus) {}
};

class AKFlangerDSPKernel : public SDModulatedDelayDSPKernel {
public:
    AKFlangerDSPKernel() : SDModulatedDelayDSPKernel(kFlanger) {}
};

