//
//  AKAmplitudeTrackerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

class AKAmplitudeTrackerDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKAmplitudeTrackerDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
        sp_rms_create(&rms);
        rms->ihp = halfPowerPoint;
        sp_rms_init(sp, rms);
    }
    
    void setThreshold(float value) {
        threshold = value;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        //printf("AKAmplitudeTrackerDSPKernel.destroy() \n");
        AKSoundpipeKernel::destroy();
        sp_rms_destroy(&rms);
    }

    void reset() {
    }
    
    void setHalfPowerPoint(float value) {
        halfPowerPoint = value;
    }
    
//    void setSmoothness(float value) {
//        smoothness = value;
//    } //in development

    void setParameter(AUParameterAddress address, AUValue value) {
    }
    
    AUValue getParameter(AUParameterAddress address) {
        return 0.0f;
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float temp = *in;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    sp_rms_compute(sp, rms, in, out);
                    trackedAmplitude = *out;
                } else {
                    trackedAmplitude = 0;
                }
                *out = temp;
            }
        }
        
        bool wasAboveThreshold = isAboveThreshold;
        
        if (trackedAmplitude > threshold * 1.05 && !wasAboveThreshold) {
            isAboveThreshold = true;
            thresholdCallback(true);
        }
        if (wasAboveThreshold && trackedAmplitude < threshold * 0.95) {
            isAboveThreshold = false;
            thresholdCallback(false);
        }
        
    }

    // MARK: Member Variables

private:

    sp_rms *rms;
    float threshold = 1.0;
    float halfPowerPoint = 10;
public:
    bool started = true;
    bool resetted = false;
    float trackedAmplitude = 0.0;
    bool isAboveThreshold = false;
    //float smoothness = 0.05; //in development
    AKThresholdCallback thresholdCallback = nullptr;
};
