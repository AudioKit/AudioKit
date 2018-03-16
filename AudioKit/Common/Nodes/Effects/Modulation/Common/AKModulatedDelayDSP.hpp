//
//  AKModulatedDelayDSP.hpp
//  AudioKit For macOS
//
//  Created by Shane Dunne on 2018-02-11.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKModulatedDelayParameter) {
    AKModulatedDelayParameterFrequency,
    AKModulatedDelayParameterDepth,
    AKModulatedDelayParameterFeedback,
    AKModulatedDelayParameterDryWetMix,
    AKModulatedDelayParameterRampTime
};

#ifndef __cplusplus

void* createChorusDSP(int nChannels, double sampleRate);
void* createFlangerDSP(int nChannels, double sampleRate);

#else

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "AKLinearParameterRamp.hpp"

#define FLANGER_MIN_DELAY_MS 0.01f
#define FLANGER_MAX_DELAY_MS 10.0f
#define FLANGER_MIN_FEEDBACK -0.95f
#define FLANGER_MAX_FEEDBACK 0.95f
#define FLANGER_DEFAULT_DRYWETMIX 0.5f

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
} AKModulatedDelayType;

#include <math.h>

class SDDelayLine {
    double sampleRateHz;
    float fbFraction;
    float *pBuffer;
    int capacity;
    int writeIndex;
    float readIndex;
    
public:
    SDDelayLine();
    ~SDDelayLine() { deinit(); }
    
    void init(double sampleRate, double maxDelayMs);
    void deinit();
    
    void setDelayMs(double delayMs);
    void setFeedback(float feedback);
    float push(float sample);
};

class SDWaveTable {
    float *pWaveTable;
    int nTableSize;
    
public:
    SDWaveTable();
    ~SDWaveTable() { deinit(); }
    
    void init(int tableLength);
    void deinit();
    
    void initSinusoid(int tableLength);
    void initTriangle(int tableLength);
    float interp(float phase);
};

class SDTwoPhaseOscillator {
    double sampleRateHz;
    float phase;
    float phaseDelta;   // normalized frequency: cycles per sample
    SDWaveTable waveTable;
    
    void init(double sampleRate, float frequency, int tableLength);
    
public:
    ~SDTwoPhaseOscillator() { deinit(); }
    void deinit();
    
    void initSinusoid(double sampleRate, float frequency, int tableLength=256);
    void initTriangle(double sampleRate, float frequency, int tableLength=256);
    void setFrequency(float frequency);
    void getSamples(float* pSin, float* pCos);
};

struct AKModulatedDelayDSP : AKDSPBase {
    
private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp depthRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp dryWetMixRamp;
    
private:
    AKModulatedDelayType effectType;
    float minDelayMs, maxDelayMs, midDelayMs, delayRangeMs;
    SDDelayLine leftDelayLine;
    SDDelayLine rightDelayLine;
    SDTwoPhaseOscillator modOscillator;
    
public:
    
    AKModulatedDelayDSP(AKModulatedDelayType type);
    ~AKModulatedDelayDSP();
    
    void init(int _channels, double _sampleRate) override;
    void deinit() override;
    void setParameter(AUParameterAddress address, float value, bool immediate) override;
    float getParameter(AUParameterAddress address) override;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
