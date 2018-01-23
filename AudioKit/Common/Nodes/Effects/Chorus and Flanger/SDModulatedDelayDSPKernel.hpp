//
//  SDModulatedDelayDSPKernel.hpp
//  AudioKit
//
//  Created by Shane Dunne
//  Copyright © 2018 Shane Dunne. All rights reserved.
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
#define FLANGER_DEFAULT_WETFRACTION 0.0f

#define CHORUS_MIN_DELAY_MS 4.0f
#define CHORUS_MAX_DELAY_MS 24.0f
#define CHORUS_MIN_FEEDBACK 0.0f
#define CHORUS_MAX_FEEDBACK 0.25f
#define CHORUS_DEFAULT_WETFRACTION 0.0f

#define MIN_MODFREQ_HZ 0.1f
#define DEFAULT_MODFREQ_HZ 1.0f
#define MAX_MODFREQ_HZ 10.0f
#define MIN_FRACTION 0.0f
#define MAX_FRACTION 1.0f

typedef enum {
    kChorus,
    kFlanger
} SDMDEffectType;

enum {
    modFreqAddress = 0,
    modDepthAddress = 1,
    wetFractionAddress = 2,
    feedbackAddress = 3
};

class SDModulatedDelayDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    SDModulatedDelayDSPKernel(SDMDEffectType type)
        : effectType(type)
        , modFreq(DEFAULT_MODFREQ_HZ)
        , modDepth(MIN_FRACTION)
        , feedback(MIN_FRACTION)
        , wetFraction(CHORUS_DEFAULT_WETFRACTION)
        , modFreqRamper(DEFAULT_MODFREQ_HZ)
        , modDepthRamper(MIN_FRACTION)
        , feedbackRamper(MIN_FRACTION)
        , wetFractionRamper(CHORUS_DEFAULT_WETFRACTION)
    {
        switch (type) {
            case kFlanger:
                modFreq = DEFAULT_MODFREQ_HZ;
                modDepth = MIN_FRACTION;
                feedback = MIN_FRACTION;
                wetFraction = FLANGER_DEFAULT_WETFRACTION;
                break;
                
            case kChorus:
            default:
                break;
        }
        modFreqRamper.setImmediate(modFreq);
        modDepthRamper.setImmediate(modDepth);
        wetFractionRamper.setImmediate(wetFraction);
        feedbackRamper.setImmediate(feedback);
    }

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        modFreqRamper.init();
        modDepthRamper.init();
        wetFractionRamper.init();
        feedbackRamper.init();
        
        minDelayMs = CHORUS_MIN_DELAY_MS;
        maxDelayMs = CHORUS_MAX_DELAY_MS;
        switch (effectType) {
            case kFlanger:
                minDelayMs = FLANGER_MIN_DELAY_MS;
                maxDelayMs = FLANGER_MAX_DELAY_MS;
                modOscillator.initTriangle(_sampleRate, DEFAULT_MODFREQ_HZ);
                break;
            case kChorus:
            default:
                modOscillator.initSinusoid(_sampleRate, DEFAULT_MODFREQ_HZ);
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
        modFreqRamper.reset();
        modDepthRamper.reset();
        wetFractionRamper.reset();
        feedbackRamper.reset();
    }

    void setModFreq(float value) {
        modFreq = clamp(value, MIN_MODFREQ_HZ, MAX_MODFREQ_HZ);
        modFreqRamper.setImmediate(modFreq);
        modOscillator.setFrequency(modFreq);
    }
    
    void setModDepth(float value) {
        modDepth = clamp(value, MIN_FRACTION, MAX_FRACTION);
        modDepthRamper.setImmediate(modDepth);
    }
    
    void setWetFraction(float value) {
        wetFraction = clamp(value, MIN_FRACTION, MAX_FRACTION);
        wetFractionRamper.setImmediate(wetFraction);
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
            case modFreqAddress:
                modFreqRamper.setUIValue(clamp(value, MIN_MODFREQ_HZ, MAX_MODFREQ_HZ));
                break;
            case modDepthAddress:
                modDepthRamper.setUIValue(clamp(value, MIN_FRACTION, MAX_FRACTION));
                break;
            case wetFractionAddress:
                wetFractionRamper.setUIValue(clamp(value, MIN_FRACTION, MAX_FRACTION));
                break;
            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, minFeedback, maxFeedback));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case modFreqAddress:
                return modFreqRamper.getUIValue();
            case modDepthAddress:
                return modDepthRamper.getUIValue();
            case wetFractionAddress:
                return wetFractionRamper.getUIValue();
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
            case modFreqAddress:
                modFreqRamper.startRamp(clamp(value, MIN_MODFREQ_HZ, MAX_MODFREQ_HZ), duration);
                break;
            case modDepthAddress:
                modDepthRamper.startRamp(clamp(value, MIN_FRACTION, MAX_FRACTION), duration);
                break;
            case wetFractionAddress:
                wetFractionRamper.startRamp(clamp(value, MIN_FRACTION, MAX_FRACTION), duration);
                break;
            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, minFeedback, maxFeedback), duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            modFreq = modFreqRamper.getAndStep();
            modOscillator.setFrequency(modFreq);
            modDepth = modDepthRamper.getAndStep();
            wetFraction = wetFractionRamper.getAndStep();
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

            float leftDelayMs = midDelayMs + delayRangeMs * modDepth * modLeft;
            float rightDelayMs = midDelayMs + delayRangeMs * modDepth * modRight;
            switch (effectType) {
                case kFlanger:
                    leftDelayMs = minDelayMs + delayRangeMs * modDepth * (1.0f + modLeft);
                    rightDelayMs = minDelayMs + delayRangeMs * modDepth * (1.0f + modRight);
                    break;
                    
                case kChorus:
                default:
                    break;
            }
            leftDelayLine.setDelayMs(leftDelayMs);
            rightDelayLine.setDelayMs(rightDelayMs);

            float dryFraction = 1.0f - wetFraction;
            *outLeft = dryFraction * (*inLeft) + wetFraction * leftDelayLine.push(*inLeft);
            *outRight = dryFraction * (*inRight) + wetFraction * rightDelayLine.push(*inRight);
        }
    }

    // MARK: Member Variables

private:
    SDMDEffectType effectType;
    float minDelayMs, maxDelayMs, midDelayMs, delayRangeMs;
    SDDelayLine leftDelayLine;
    SDDelayLine rightDelayLine;
    SDTwoPhaseOscillator modOscillator;
    float modFreq;
    float modDepth;
    float feedback;
    float wetFraction;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper modFreqRamper;
    ParameterRamper modDepthRamper;
    ParameterRamper feedbackRamper;
    ParameterRamper wetFractionRamper;
};

class AKChorusDSPKernel : public SDModulatedDelayDSPKernel {
public:
    AKChorusDSPKernel() : SDModulatedDelayDSPKernel(kChorus) {}
};

class AKFlangerDSPKernel : public SDModulatedDelayDSPKernel {
public:
    AKFlangerDSPKernel() : SDModulatedDelayDSPKernel(kFlanger) {}
};

