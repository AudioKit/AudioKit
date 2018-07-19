//
//  AKPhaseLockedVocoderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#import "AKSoundpipeKernel.hpp"

enum {
    positionAddress = 0,
    amplitudeAddress = 1,
    pitchRatioAddress = 2
};

class AKPhaseLockedVocoderDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKPhaseLockedVocoderDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_mincer_create(&mincer);

        positionRamper.init();
        amplitudeRamper.init();
        pitchRatioRamper.init();
    }

    void start() {
        started = true;
        sp_mincer_init(sp, mincer, ftbl, 2048);
        mincer->time = 0;
        mincer->amp = 1;
        mincer->pitch = 1;
    }

    void stop() {
        started = false;
    }

    void setUpTable(float *table, UInt32 size) {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
        ftbl->tbl = table;
    }

    void destroy() {
        sp_ftbl_destroy(&ftbl);
        sp_mincer_destroy(&mincer);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        positionRamper.reset();
        amplitudeRamper.reset();
        pitchRatioRamper.reset();
    }

    void setPosition(float value) {
        position = value;
        positionRamper.setImmediate(position);
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 1.0f);
        amplitudeRamper.setImmediate(amplitude);
    }

    void setPitchRatio(float value) {
        pitchRatio = clamp(value, 0.0f, 1000.0f);
        pitchRatioRamper.setImmediate(pitchRatio);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case positionAddress:
                positionRamper.setUIValue(value);
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case pitchRatioAddress:
                pitchRatioRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case positionAddress:
                return positionRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            case pitchRatioAddress:
                return pitchRatioRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case positionAddress:
                positionRamper.startRamp(value, duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case pitchRatioAddress:
                pitchRatioRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            position = double(positionRamper.getAndStep());
            amplitude = double(amplitudeRamper.getAndStep());
            pitchRatio = double(pitchRatioRamper.getAndStep());

            mincer->time = position;
            mincer->amp = amplitude;
            mincer->pitch = pitchRatio;

            //            for (int channel = 0; channel < channels; ++channel) {
            float *outL = (float *)outBufferListPtr->mBuffers[0].mData + frameOffset;
            float *outR = (float *)outBufferListPtr->mBuffers[1].mData + frameOffset;
            if (started) {
                sp_mincer_compute(sp, mincer, NULL, outL);
                *outR = *outL;
            } else {
                *outL = 0;
                *outR = 0;
            }
            //            }
        }
    }

    // MARK: Member Variables

private:

    sp_mincer *mincer;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

    float position = 0;
    float amplitude = 1;
    float pitchRatio = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper positionRamper = 0;
    ParameterRamper amplitudeRamper = 1;
    ParameterRamper pitchRatioRamper = 1;
};


