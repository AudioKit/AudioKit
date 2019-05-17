//
//  AKDiskStreamerDSPKernel.hpp
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKSoundpipeKernel.hpp"

enum {
    startPointAddress = 0,
    endPointAddress = 1,
    loopStartPointAddress = 2,
    loopEndPointAddress = 3,
    volumeAddress = 4
};

class AKDiskStreamerDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKDiskStreamerDSPKernel() {}

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeKernel::init(channelCount, sampleRate);

        sp_wavin_create(&wavin);

        rateRamper.init();
        volumeRamper.init();
    }

    void start() {
        started = true;
        
        lastPosition = 0.0;
        inLoopPhase = false;
        position = startPointViaRate();
        mainPlayComplete = false;
    }

    void stop() {
        started = false;
        useTempStartPoint = false;
        useTempEndPoint = false;
        rewind();
    }

    void rewind() {
        sp_wavin_reset_to_start(sp, wavin);
        position = startPointViaRate();
    }

    void seekTo(double sample) {
        sp_wavin_seek(sp, wavin, sample);
        position = sample;
    }

    void loadFile(const char *filename) {
        sp_wavin_init(sp, wavin, filename);
        sourceSampleRate = wavin->wav.sampleRate;
        current_size = wavin->wav.totalSampleCount / wavin->wav.channels;
        if (loadCompletionHandler != nil){
            loadCompletionHandler();
        }
    }

    void destroy() {
        sp_wavin_destroy(&wavin);
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

    void setRate(double value) {
        rate = value;
    }

    void setVolume(float value) {
        volume = clamp(value, 0.0f, 10.0f);
        volumeRamper.setImmediate(volume);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {

            case volumeAddress:
                volumeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case volumeAddress:
                return volumeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {

            case volumeAddress:
                volumeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;
        }
    }
    
    long loopPhase = -1;
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

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
                        wavin->pos = (unsigned long)floor(position);
                        sp_wavin_get_sample(sp, wavin, out, position);
                        position += sampleStep();
                    } else {
//                        sp_wavplay_compute(sp, wavin, NULL, out);
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
                doLoopActions();
            }else if (nextPosition < loopEndPointViaRate() && loopReversed()){
                doLoopActions();
            }
        }
    }
    void doLoopActions(){
        sp_wavin_reset_to_start(sp, wavin);
        position = loopStartPointViaRate();
        if (loopCallback != NULL) {
            loopCallback();
        }
    }
private:
    sp_wavin *wavin;

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
    AKCCallback loopCallback = nullptr;
    UInt32 ftbl_size = 2;
    unsigned long long current_size = 2;
    double position = 0.0;
    double rate = 1;
};
