//
//  AKMetalBarDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMetalBarDSPKernel_hpp
#define AKMetalBarDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    leftBoundaryConditionAddress = 0,
    rightBoundaryConditionAddress = 1,
    decayDurationAddress = 2,
    scanSpeedAddress = 3,
    positionAddress = 4,
    strikeVelocityAddress = 5,
    strikeWidthAddress = 6
};

class AKMetalBarDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKMetalBarDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_bar_create(&bar);
        sp_bar_init(sp, bar, 3, 0.0001);
//        bar->bcL = 2;
//        bar->bcR = 2;
//        bar->T30 = 0.5;
//        bar->scan = 0.2;
//        bar->pos = 0.01;
//        bar->vel = 1500;
//        bar->wid = 0.02;
    }


    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_bar_destroy(&bar);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setLeftboundarycondition(float bcL) {
        leftBoundaryCondition = bcL;
        leftBoundaryConditionRamper.setUIValue(clamp(bcL, (float)1, (float)3));
    }

    void setRightboundarycondition(float bcR) {
        rightBoundaryCondition = bcR;
        rightBoundaryConditionRamper.setUIValue(clamp(bcR, (float)1, (float)3));
    }

    void setDecayduration(float T30) {
        decayDuration = T30;
        decayDurationRamper.setUIValue(clamp(T30, (float)0, (float)10));
    }

    void setScanspeed(float scan) {
        scanSpeed = scan;
        scanSpeedRamper.setUIValue(clamp(scan, (float)0, (float)100));
    }

    void setPosition(float pos) {
        position = pos;
        positionRamper.setUIValue(clamp(pos, (float)0, (float)1));
    }

    void setStrikevelocity(float vel) {
        strikeVelocity = vel;
        strikeVelocityRamper.setUIValue(clamp(vel, (float)0, (float)1000));
    }

    void setStrikewidth(float wid) {
        strikeWidth = wid;
        strikeWidthRamper.setUIValue(clamp(wid, (float)0, (float)1));
    }
    void trigger() {
        internalTrigger = 1;
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case leftBoundaryConditionAddress:
                leftBoundaryConditionRamper.setUIValue(clamp(value, (float)1, (float)3));
                break;

            case rightBoundaryConditionAddress:
                rightBoundaryConditionRamper.setUIValue(clamp(value, (float)1, (float)3));
                break;

            case decayDurationAddress:
                decayDurationRamper.setUIValue(clamp(value, (float)0, (float)10));
                break;

            case scanSpeedAddress:
                scanSpeedRamper.setUIValue(clamp(value, (float)0, (float)100));
                break;

            case positionAddress:
                positionRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

            case strikeVelocityAddress:
                strikeVelocityRamper.setUIValue(clamp(value, (float)0, (float)1000));
                break;

            case strikeWidthAddress:
                strikeWidthRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case leftBoundaryConditionAddress:
                return leftBoundaryConditionRamper.getUIValue();

            case rightBoundaryConditionAddress:
                return rightBoundaryConditionRamper.getUIValue();

            case decayDurationAddress:
                return decayDurationRamper.getUIValue();

            case scanSpeedAddress:
                return scanSpeedRamper.getUIValue();

            case positionAddress:
                return positionRamper.getUIValue();

            case strikeVelocityAddress:
                return strikeVelocityRamper.getUIValue();

            case strikeWidthAddress:
                return strikeWidthRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case leftBoundaryConditionAddress:
                leftBoundaryConditionRamper.startRamp(clamp(value, (float)1, (float)3), duration);
                break;

            case rightBoundaryConditionAddress:
                rightBoundaryConditionRamper.startRamp(clamp(value, (float)1, (float)3), duration);
                break;

            case decayDurationAddress:
                decayDurationRamper.startRamp(clamp(value, (float)0, (float)10), duration);
                break;

            case scanSpeedAddress:
                scanSpeedRamper.startRamp(clamp(value, (float)0, (float)100), duration);
                break;

            case positionAddress:
                positionRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

            case strikeVelocityAddress:
                strikeVelocityRamper.startRamp(clamp(value, (float)0, (float)1000), duration);
                break;

            case strikeWidthAddress:
                strikeWidthRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

//            bar->bcL = leftBoundaryConditionRamper.getAndStep();
//            bar->bcR = rightBoundaryConditionRamper.getAndStep();
//            bar->T30 = decayDurationRamper.getAndStep();
//            bar->scan = scanSpeedRamper.getAndStep();
//            bar->pos = positionRamper.getAndStep();
//            bar->vel = strikeVelocityRamper.getAndStep();
//            bar->wid = strikeWidthRamper.getAndStep();

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    sp_bar_compute(sp, bar, &internalTrigger, out);
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    float internalTrigger = 0;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_bar *bar;


    float leftBoundaryCondition = 1;
    float rightBoundaryCondition = 1;
    float decayDuration = 3;
    float scanSpeed = 0.25;
    float position = 0.2;
    float strikeVelocity = 500;
    float strikeWidth = 0.05;

public:
    bool started = false;
    AKParameterRamper leftBoundaryConditionRamper = 1;
    AKParameterRamper rightBoundaryConditionRamper = 1;
    AKParameterRamper decayDurationRamper = 3;
    AKParameterRamper scanSpeedRamper = 0.25;
    AKParameterRamper positionRamper = 0.2;
    AKParameterRamper strikeVelocityRamper = 500;
    AKParameterRamper strikeWidthRamper = 0.05;
};

#endif /* AKMetalBarDSPKernel_hpp */
