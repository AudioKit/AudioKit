//
//  AKAmplitudeTrackerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

class AKAmplitudeTrackerDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKAmplitudeTrackerDSPKernel() {}

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeKernel::init(channelCount, sampleRate);
        sp_rms_create(&leftRMS);
        sp_rms_create(&rightRMS);
        leftRMS->ihp = halfPowerPoint;
        rightRMS->ihp = halfPowerPoint;
        sp_rms_init(sp, leftRMS);
        sp_rms_init(sp, rightRMS);
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
        AKSoundpipeKernel::destroy();
        sp_rms_destroy(&leftRMS);
        sp_rms_destroy(&rightRMS);
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
        for (int channel = 0; channel < channels; ++channel) {
            float computedAmp = 0;
            float lastAmp = 0;
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                int frameOffset = int(frameIndex + bufferOffset);
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                float passthrough = *in;
                if (started) {
                    if (mode == 0 || mode == 1) {
                        if (channel == 0) {
                            sp_rms_compute(sp, leftRMS, in, out);
                        } else if (channel == 1) {
                            sp_rms_compute(sp, rightRMS, in, out);
                        }
                        lastAmp = *out;
                        if (mode == 0) {
                            computedAmp = lastAmp;
                        } else if (mode == 1) {
                            if (lastAmp > computedAmp) {
                                computedAmp = lastAmp;
                            }
                        }
                    } else if (mode == 2) {
                        lastAmp = fabs(*in);
                        if (lastAmp > computedAmp) {
                            computedAmp = lastAmp;
                        }
                    }
                }
                *out = passthrough;
            }
            if (channel == 0) {
                leftAmplitude = computedAmp;
            } else if (channel == 1) {
                rightAmplitude = computedAmp;
            }
        }

        bool wasAboveThreshold = isAboveThreshold;

        if ((leftAmplitude + rightAmplitude) / 2.0  > threshold * 1.05 && !wasAboveThreshold) {
            isAboveThreshold = true;
            thresholdCallback(true);
        }
        if (wasAboveThreshold && (leftAmplitude + rightAmplitude) / 2.0 < threshold * 0.95) {
            isAboveThreshold = false;
            thresholdCallback(false);
        }

    }

    // MARK: Member Variables

private:

    sp_rms *leftRMS;
    sp_rms *rightRMS;
    float threshold = 1.0;
    float halfPowerPoint = 10;
public:
    bool started = true;
    bool resetted = false;
    float leftAmplitude = 0.0;
    float rightAmplitude = 0.0;
    bool isAboveThreshold = false;
    int mode = 0; // 0 = last RMS, 1 = max RMS, 2 = peak
    //float smoothness = 0.05; //in development
    AKThresholdCallback thresholdCallback = nullptr;
};
