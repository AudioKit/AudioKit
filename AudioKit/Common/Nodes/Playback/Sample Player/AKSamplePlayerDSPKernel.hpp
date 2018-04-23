//
//  AKSamplePlayerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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
        
        rateRamper.init();
        volumeRamper.init();
    }

    void start() {
        started = true;

        sp_tabread_init(sp, tabread1, ftbl1, 1);
        sp_tabread_init(sp, tabread2, ftbl2, 1);
        tabread1->mode = 0;
        tabread2->mode = 0;
        
        lastPosition = 0.0;
        inLoopPhase = false;
        position = startPointViaRate();
        mainPlayComplete = false;
    }

    void stop() {
        started = false;
        useTempStartPoint = false;
        useTempEndPoint = false;
    }

    void setUpTable(UInt32 size) {
        if (current_size <= 2) {
            current_size = size / 2;
            ftbl_size = size / 2;
            sp_ftbl_create(sp, &ftbl1, ftbl_size);
            sp_ftbl_create(sp, &ftbl2, ftbl_size);
        }
    }

    void loadAudioData(float *table, UInt32 size, float sampleRate, UInt32 numChannels) {
        sourceSampleRate = sampleRate;
        current_size = size / numChannels;
        for (int i = 0; i < current_size; i++) {
            ftbl1->tbl[i] = table[i];
            if (numChannels == 1){ //mono - copy chanel to both buffers
                ftbl2->tbl[i] = table[i];
            }else if (numChannels == 2){
                ftbl2->tbl[i] = table[i + current_size]; //stereo - right data comes after left data
            }
        }
        if (loadCompletionHandler != nil){
            loadCompletionHandler();
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
        rateRamper.reset();
        volumeRamper.reset();
    }

    void setStartPoint(float value) {
        startPoint = value;
    }

    void setEndPoint(float value) {
        endPoint = value;
    }
    void setLoopStartPoint(float value) {
        loopStartPoint = value;
    }
    void setLoopEndPoint(float value) {
        loopEndPoint = value;
    }
    void setTempStartPoint(float value) {
        useTempStartPoint = true;
        tempStartPoint = value;
    }
    void setTempEndPoint(float value) {
        useTempEndPoint = true;
        tempEndPoint = value;
    }
    void setLoop(bool value) {
        loop = value;
    }

    void setRate(float value) {
        rate = clamp(value, -10.0f, 10.0f);
        rateRamper.setImmediate(rate);
    }

    void setVolume(float value) {
        volume = clamp(value, 0.0f, 10.0f);
        volumeRamper.setImmediate(volume);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case rateAddress:
                rateRamper.setUIValue(clamp(value, -10.0f, 10.0f));
                break;

            case volumeAddress:
                volumeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case rateAddress:
                return rateRamper.getUIValue();

            case volumeAddress:
                return volumeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case rateAddress:
                rateRamper.startRamp(clamp(value, -10.0f, 10.0f), duration);
                break;

            case volumeAddress:
                volumeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);
            
            rate = double(rateRamper.getAndStep());
            volume = double(volumeRamper.getAndStep());

            float startPointToUse = startPointViaRate();
            float endPointToUse = endPointViaRate();
            double nextPosition = position + sampleRateRatio() * rate;

            if (started){
                calculateMainPlayComplete(nextPosition);
                if (loop){
                    calculateLoopPhase(nextPosition);
                    if (inLoopPhase){
                        startPointToUse = loopStartPointViaRate();
                        endPointToUse = loopEndPointViaRate();
                        calculateShouldLoop(nextPosition);
                    }
                }
                if (!loop && calculateHasEnded(nextPosition)) {
                    stop();
                    completionHandler();
                } else {
                    lastPosition = position;
                }
            }
            
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        tabread1->index = position;
                        tabread2->index = position;
                        sp_tabread_compute(sp, tabread1, NULL, out);
                        position += sampleStep();
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
    
    float startPointViaRate(){
        if (rate == 0) {return 0;}
        if (useTempStartPoint){
            float currentEndPoint = endPoint;
            if (useTempEndPoint) {
                currentEndPoint = tempEndPoint;
            }
            return (rate > 0 ? tempStartPoint : currentEndPoint);
        }
        return (rate > 0 ? startPoint : endPoint);
    }
    float endPointViaRate(){
        if (rate == 0) {return 0;}
        if (useTempEndPoint){
            return (rate > 0 ? tempEndPoint : tempStartPoint);
        }
        return (rate > 0 ? endPoint : startPoint);
    }
    float loopStartPointViaRate(){
        if (rate == 0) {return 0;}
        return (rate > 0 ? loopStartPoint : loopEndPoint);
    }
    float loopEndPointViaRate(){
        if (rate == 0) {return 0;}
        return (rate > 0 ? loopEndPoint : loopStartPoint);
    }
    double sampleStep(){
        int reverseMultiplier = 1;
        if (inLoopPhase && loopReversed()){
            reverseMultiplier = -1;
        }
        if (!inLoopPhase && startEndReversed()){
            reverseMultiplier = -1;
        }
        return sampleRateRatio() * fabs(rate) * reverseMultiplier;
    }
    double sampleRateRatio(){
        return sourceSampleRate / AKSettings.sampleRate;
    }
    // MARK: Member Variables
    
    bool loopReversed(){
        if (loopEndPoint < loopStartPoint && rate > 0){
            return true;
        }
        if (loopEndPoint < loopStartPoint && rate < 0){
            return false;
        }
        if (loopEndPoint > loopStartPoint && rate < 0){
            return true;
        }
        if (loopEndPoint > loopStartPoint && rate > 0){
            return false;
        }
        return (loopEndPoint < loopStartPoint ? true : false);
    }
    bool startEndReversed(){
        return (endPointViaRate() < startPointViaRate() ? true : false);
    }
    
    void calculateMainPlayComplete(double nextPosition){
        if (nextPosition > endPointViaRate() && !startEndReversed()){
            mainPlayComplete = true;
        }else if (nextPosition < endPointViaRate() && startEndReversed()){
            mainPlayComplete = true;
        }
    }
    bool calculateHasEnded(double nextPosition){
        if ((nextPosition > endPointViaRate() && !startEndReversed()) || (nextPosition < endPointViaRate() && startEndReversed())){
            return true;
        }
        return false;
    }
    void calculateLoopPhase(double nextPosition){
        if (!inLoopPhase && mainPlayComplete){
            if (nextPosition > endPointViaRate() && !startEndReversed()){
                inLoopPhase = true;
                position = loopStartPointViaRate();
            }else if (nextPosition < endPointViaRate() && startEndReversed()){
                inLoopPhase = true;
                position = loopStartPointViaRate();
            }
        }
    }
    void calculateShouldLoop(double nextPosition){
        if (mainPlayComplete){
            if (nextPosition > loopEndPointViaRate() && !loopReversed()){
                position = loopStartPointViaRate();
            }else if (nextPosition < loopEndPointViaRate() && loopReversed()){
                position = loopStartPointViaRate();
            }
        }
    }
private:

    sp_tabread *tabread1;
    sp_tabread *tabread2;
    sp_ftbl *ftbl1;
    sp_ftbl *ftbl2;

    float startPoint = 0;
    float endPoint = 1;
    float tempStartPoint = 0;
    float tempEndPoint = 1;
    bool useTempStartPoint = false;
    bool useTempEndPoint = false;
    float loopStartPoint = 0;
    float loopEndPoint = 1;
    float volume = 1;
    float lastPosition = 0.0;
    bool loop = false;
    bool mainPlayComplete = false;  //has the sample played through once without looping
    bool inLoopPhase = false;       //has the main play completed and now we are in loop phase
    float sourceSampleRate = 0.0;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper rateRamper = 1;
    ParameterRamper volumeRamper = 1;
    AKCCallback completionHandler = nullptr;
    AKCCallback loadCompletionHandler = nullptr;
    UInt32 ftbl_size = 2;
    UInt32 current_size = 2;
    double position = 0.0;
    float rate = 1;
};


