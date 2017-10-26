//
//  AKSamplePlayerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKSoundpipeKernel.hpp"

enum {
    startPointAddress = 0,
    endPointAddress = 1,
    loopStartPointAddress = 2,
    loopEndPointAddress = 3,
    rateAddress = 4,
    volumeAddress = 5
};

class AKSamplePlayerDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions
    
    AKSamplePlayerDSPKernel() {}
    
    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
        
        sp_tabread_create(&tabread1);
        sp_tabread_create(&tabread2);
        sp_phasor_create(&phasor);
        
        startPointRamper.init();
        endPointRamper.init();
        rateRamper.init();
        volumeRamper.init();
    }
    
    void start() {
        started = true;
        
        sp_tabread_init(sp, tabread1, ftbl1, 1);
        sp_tabread_init(sp, tabread2, ftbl2, 1);
        sp_phasor_init(sp, phasor, 0.0);
        
        SPFLOAT dur;
        dur = (SPFLOAT)current_size / sp->sr;
        phasor->freq = 1.0 / dur * rate;
        lastPosition = 0.0;
        inLoopPhase = false;
        phasor->curphs = 0;
        position = 0;
        mainPlayComplete = false;
    }
    
    void stop() {
        started = false;
    }
    
    void setUpTable(UInt32 size) {
        if (current_size <= 2) {
            current_size = size / 2;
            ftbl_size = size / 2;
            sp_ftbl_create(sp, &ftbl1, ftbl_size);
            sp_ftbl_create(sp, &ftbl2, ftbl_size);
        }
    }
    
    void loadAudioData(float *table, UInt32 size) {
        current_size = fmin(size / 2, ftbl_size);
        int counter1 = 0;
        int counter2 = 0;
        for (int i = 0; i < 2 * current_size; i++) {
            if (i % 2 == 0) {
                ftbl1->tbl[counter1] = table[i];
                counter1++;
            } else {
                ftbl2->tbl[counter2] = table[i];
                counter2++;
            }
        }
    }
    
    void destroy() {
        sp_tabread_destroy(&tabread1);
        sp_tabread_destroy(&tabread2);
        sp_ftbl_destroy(&ftbl1);
        sp_ftbl_destroy(&ftbl2);
        AKSoundpipeKernel::destroy();
    }
    
    void reset() {
        resetted = true;
        startPointRamper.reset();
        endPointRamper.reset();
        rateRamper.reset();
        volumeRamper.reset();
    }
    
    void setStartPoint(float value) {
        startPoint = value;
        startPointRamper.setImmediate(startPoint);
    }
    
    void setEndPoint(float value) {
        endPoint = value;
        endPointRamper.setImmediate(endPoint);
    }
    void setLoopStartPoint(float value) {
        loopStartPoint = value;
        loopStartPointRamper.setImmediate(loopStartPoint);
    }
    void setLoopEndPoint(float value) {
        loopEndPoint = value;
        loopEndPointRamper.setImmediate(loopEndPoint);
    }
    void setLoop(bool value) {
        loop = value;
    }
    
    void setRate(float value) {
        rate = clamp(value, 0.0f, 10.0f);
        rateRamper.setImmediate(rate);
    }
    
    void setVolume(float value) {
        volume = clamp(value, 0.0f, 10.0f);
        volumeRamper.setImmediate(volume);
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case startPointAddress:
                startPointRamper.setUIValue(value);
                break;
                
            case endPointAddress:
                endPointRamper.setUIValue(value);
                break;
                
            case loopStartPointAddress:
                loopStartPointRamper.setUIValue(value);
                break;
                
            case loopEndPointAddress:
                loopEndPointRamper.setUIValue(value);
                break;
                
            case rateAddress:
                rateRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;
                
            case volumeAddress:
                volumeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case startPointAddress:
                return startPointRamper.getUIValue();
                
            case endPointAddress:
                return endPointRamper.getUIValue();
                
            case loopStartPointAddress:
                return loopStartPointRamper.getUIValue();
                
            case loopEndPointAddress:
                return loopEndPointRamper.getUIValue();
                
            case rateAddress:
                return rateRamper.getUIValue();
                
            case volumeAddress:
                return volumeRamper.getUIValue();
                
            default: return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case startPointAddress:
                startPointRamper.startRamp(value, duration);
                break;
                
            case endPointAddress:
                endPointRamper.startRamp(value, duration);
                break;
                
            case loopStartPointAddress:
                loopStartPointRamper.startRamp(value, duration);
                break;
                
            case loopEndPointAddress:
                loopEndPointRamper.startRamp(value, duration);
                break;
                
            case rateAddress:
                rateRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;
                
            case volumeAddress:
                volumeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            startPoint = double(startPointRamper.getAndStep());
            endPoint = double(endPointRamper.getAndStep());
            loopStartPoint = double(loopStartPointRamper.getAndStep());
            loopEndPoint = double(loopEndPointRamper.getAndStep());
            rate = double(rateRamper.getAndStep());
            volume = double(volumeRamper.getAndStep());
            
            SPFLOAT dur = (SPFLOAT)current_size / sp->sr;
            
            //length of playableSample vs actual
            float startPointToUse = startPoint;
            float endPointToUse = endPoint;
            float nextPosition = 2.0 * position - lastPosition;
            int nextSamplePosition = (int)(nextPosition * current_size);
            
            if (started){
                if (nextSamplePosition >= endPoint){
                    mainPlayComplete = true;
                }
                if (loop){
                    
                    if (!inLoopPhase && nextSamplePosition >= loopEndPoint && mainPlayComplete){
                        inLoopPhase = true;
                        phasor->curphs = 0;
                    }
                    if (inLoopPhase){
                        startPointToUse = loopStartPoint;
                        endPointToUse = loopEndPoint;
                    }
                    playingBackwards = (endPointToUse < startPointToUse ? true : false);
                }
                
                if (!loop && nextPosition > 1) {
                    started = false;
                    completionHandler();
                } else {
                    lastPosition = position;
                }
            }
            
            int subsectionLength = endPointToUse - startPointToUse;
            
            float percentLen = (float)subsectionLength / (float)ftbl_size;
            float speedFactor = (float)current_size / (float)ftbl_size;
            phasor->freq = fabs(1.0 / dur  * rate / percentLen * speedFactor);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_phasor_compute(sp, phasor, NULL, &position);
                        tabread1->index = position * percentLen + startPointToUse / ftbl_size;
                        tabread2->index = position * percentLen + startPointToUse / ftbl_size;
                        sp_tabread_compute(sp, tabread1, NULL, out);
                    } else {
                        sp_tabread_compute(sp, tabread2, NULL, out);
                    }
                    *out *= volume;
                } else {
                    *out = 0;
                }
            }
        }
    }
    
    // MARK: Member Variables
    
private:
    
    sp_phasor *phasor;
    sp_tabread *tabread1;
    sp_tabread *tabread2;
    sp_ftbl *ftbl1;
    sp_ftbl *ftbl2;
    
    float startPoint = 0;
    float endPoint = 1;
    float loopStartPoint = 0;
    float loopEndPoint = 1;
    float rate = 1;
    float volume = 1;
    float lastPosition = 0.0;
    bool loop = false;
    bool playingBackwards = false;  //is the sample playing backwards
    bool mainPlayComplete = false;  //has the sample played through once without looping
    bool inLoopPhase = false;       //has the main play completed and now we are in loop phase
    
public:
    bool started = false;
    bool resetted = false;
    ParameterRamper startPointRamper = 0;
    ParameterRamper endPointRamper = 1;
    ParameterRamper loopStartPointRamper = 0;
    ParameterRamper loopEndPointRamper = 1;
    ParameterRamper rateRamper = 1;
    ParameterRamper volumeRamper = 1;
    AKCCallback completionHandler = nullptr;
    UInt32 ftbl_size = 2;
    UInt32 current_size = 2;
    float position = 0.0;
};


