//
//  AKDynaRageCompressorDSPKernel.hpp
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2017 Mike Gazzaruso, Devoloop Srls. All rights reserved.
//

#pragma once

#import "AKDSPKernel.hpp"
#import "Compressor.h"
#import "RageProcessor.h"

enum {
    ratioAddress = 0,
    thresholdAddress = 1,
    attackTimeAddress = 2,
    releaseTimeAddress = 3,
    rageAmountAddress = 4
};

class AKDynaRageCompressorDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions
    
    AKDynaRageCompressorDSPKernel() {}
    
    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        left_compressor = new Compressor(threshold, ratio, attackTime, releaseTime, (int)_sampleRate);
        right_compressor = new Compressor(threshold, ratio, attackTime, releaseTime, (int)_sampleRate);
        
        left_rageprocessor = new RageProcessor((int)_sampleRate);
        right_rageprocessor = new RageProcessor((int)_sampleRate);
        
        ratioRamper.init();
        thresholdRamper.init();
        attackTimeRamper.init();
        releaseTimeRamper.init();
        rageAmountRamper.init();
    }
    
    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }
    
    void destroy() {
        //        AKSoundpipeKernel::destroy();
    }
    
    void reset() {
        resetted = true;
        ratioRamper.reset();
        thresholdRamper.reset();
        attackTimeRamper.reset();
        releaseTimeRamper.reset();
        rageAmountRamper.reset();
    }
    
    void setRatio(float value) {
        ratio = clamp(value, 1.0f, 20.0f);
        ratioRamper.setImmediate(ratio);
    }
    
    void setThreshold(float value) {
        threshold = clamp(value, -100.0f, 0.0f);
        thresholdRamper.setImmediate(threshold);
    }
    
    void setAttackTime(float value) {
        attackTime = clamp(value, 20.0f, 500.0f);
        attackTimeRamper.setImmediate(attackTime);
    }
    
    void setReleaseTime(float value) {
        releaseTime = clamp(value, 20.0f, 500.0f);
        releaseTimeRamper.setImmediate(releaseTime);
    }
    
    void setRageAmount(float value) {
        rageAmount = clamp(value, 0.1f, 20.0f);
        rageAmountRamper.setImmediate(rageAmount);
    }
    
    void setRageIsOn(bool value) {
        rageIsOn = value;
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case ratioAddress:
                ratioRamper.setUIValue(clamp(value, 1.0f, 20.0f));
                break;
                
            case thresholdAddress:
                thresholdRamper.setUIValue(clamp(value, -100.0f, 0.0f));
                break;
                
            case attackTimeAddress:
                attackTimeRamper.setUIValue(clamp(value, 0.1f, 500.0f));
                break;
                
            case releaseTimeAddress:
                releaseTimeRamper.setUIValue(clamp(value, 0.1f, 500.0f));
                break;
                
            case rageAmountAddress:
                rageAmountRamper.setUIValue(clamp(value, 0.1f, 20.0f));
                break;
                
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case ratioAddress:
                return ratioRamper.getUIValue();
                
            case thresholdAddress:
                return thresholdRamper.getUIValue();
                
            case attackTimeAddress:
                return attackTimeRamper.getUIValue();
                
            case releaseTimeAddress:
                return releaseTimeRamper.getUIValue();
                
            case rageAmountAddress:
                return rageAmountRamper.getUIValue();
                
            default: return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case ratioAddress:
                ratioRamper.startRamp(clamp(value, 1.0f, 20.0f), duration);
                break;
                
            case thresholdAddress:
                thresholdRamper.startRamp(clamp(value, -100.0f, 0.0f), duration);
                break;
                
            case attackTimeAddress:
                attackTimeRamper.startRamp(clamp(value, 0.1f, 500.0f), duration);
                break;
                
            case releaseTimeAddress:
                releaseTimeRamper.startRamp(clamp(value, 0.1f, 500.0f), duration);
                break;
                
            case rageAmountAddress:
                rageAmountRamper.startRamp(clamp(value, 0.1f, 20.0f), duration);
                break;
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            ratio = ratioRamper.getAndStep();
            threshold = thresholdRamper.getAndStep();
            attackTime = attackTimeRamper.getAndStep();
            releaseTime = releaseTimeRamper.getAndStep();
            rageAmount = rageAmountRamper.getAndStep();
            
            left_compressor->setParameters(threshold, ratio, attackTime, releaseTime);
            right_compressor->setParameters(threshold, ratio, attackTime, releaseTime);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    if (channel == 0) {
                        
                        float rageSignal = left_rageprocessor->doRage(*in, rageAmount, rageAmount);
                        float compSignal = left_compressor->Process((bool)rageIsOn ? rageSignal : *in, false, 1);
                        *out = compSignal;
                    } else {
                        float rageSignal = right_rageprocessor->doRage(*in, rageAmount, rageAmount);
                        float compSignal = right_compressor->Process((bool)rageIsOn ? rageSignal : *in, false, 1);
                        *out = compSignal;
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }
    
    // MARK: Member Variables
    
private:
    Compressor *left_compressor;
    Compressor *right_compressor;
    
    RageProcessor *left_rageprocessor;
    RageProcessor *right_rageprocessor;
    
    float ratio = 1.0;
    float threshold = 0.0;
    float attackTime = 0.1;
    float releaseTime = 0.1;
    float rageAmount = 0.1;
    BOOL rageIsOn = true;
    
public:
    bool started = true;
    bool resetted = false;
    ParameterRamper ratioRamper = 1;
    ParameterRamper thresholdRamper = 0.0;
    ParameterRamper attackTimeRamper = 0.1;
    ParameterRamper releaseTimeRamper = 0.1;
    ParameterRamper rageAmountRamper = 0.1;
};
