//
//  AKMetalBarDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

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

class AKMetalBarDSPKernel : public AKSporthKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKMetalBarDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);
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
        AKSporthKernel::destroy();
    }

    void reset() {
        resetted = true;
    }

    void setLeftBoundaryCondition(float bcL) {
        leftBoundaryCondition = bcL;
        leftBoundaryConditionRamper.setImmediate(bcL);
    }

    void setRightBoundaryCondition(float bcR) {
        rightBoundaryCondition = bcR;
        rightBoundaryConditionRamper.setImmediate(bcR);
    }

    void setDecayDuration(float T30) {
        decayDuration = T30;
        decayDurationRamper.setImmediate(T30);
    }

    void setScanSpeed(float scan) {
        scanSpeed = scan;
        scanSpeedRamper.setImmediate(scan);
    }

    void setPosition(float pos) {
        position = pos;
        positionRamper.setImmediate(pos);
    }

    void setStrikeVelocity(float vel) {
        strikeVelocity = vel;
        strikeVelocityRamper.setImmediate(vel);
    }

    void setStrikeWidth(float wid) {
        strikeWidth = wid;
        strikeWidthRamper.setImmediate(wid);
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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            leftBoundaryCondition = leftBoundaryConditionRamper.getAndStep();
            bar->bcL = (float)leftBoundaryCondition;
            rightBoundaryCondition = rightBoundaryConditionRamper.getAndStep();
            bar->bcR = (float)rightBoundaryCondition;
            decayDuration = decayDurationRamper.getAndStep();
            bar->T30 = (float)decayDuration;
            scanSpeed = scanSpeedRamper.getAndStep();
            bar->scan = (float)scanSpeed;
            position = positionRamper.getAndStep();
            bar->pos = (float)position;
            strikeVelocity = strikeVelocityRamper.getAndStep();
            bar->vel = (float)strikeVelocity;
            strikeWidth = strikeWidthRamper.getAndStep();
            bar->wid = (float)strikeWidth;

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
    float internalTrigger = 0;

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
    bool resetted = false;
    ParameterRamper leftBoundaryConditionRamper = 1;
    ParameterRamper rightBoundaryConditionRamper = 1;
    ParameterRamper decayDurationRamper = 3;
    ParameterRamper scanSpeedRamper = 0.25;
    ParameterRamper positionRamper = 0.2;
    ParameterRamper strikeVelocityRamper = 500;
    ParameterRamper strikeWidthRamper = 0.05;
};

