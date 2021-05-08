// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DSPBase.h"
#include "ParameterRamper.h"
#include "AudioKitCore/Modulated Delay/StereoDelay.h"

/*
 The objects marked Cyclone were derived from the Max/MSP Cyclone library source code.
 The license for this code can be found below:
 
 --------------------------------------------------------------------------------------------------------------
 LICENSE.txt
 --------------------------------------------------------------------------------------------------------------
 
 Copyright (c) <2003-2020>, <Krzysztof Czaja, Fred Jan Kraan, Alexandre Porres, Derek Kwan, Matt Barber and others>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the <organization> nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// MARK: BEGIN Cyclone RMS
#define AVERAGE_STACK    44100 //stack value
#define AVERAGE_MAXBUF  882000 //max buffer size
#define AVERAGE_DEFNPOINTS  100  /* CHECKME */
typedef struct {
    float x_accum; // sum
    float x_calib; // accumulator calibrator
    float *x_buf; // buffer pointer
    float x_stack[AVERAGE_STACK]; // buffer
    int x_alloc; // if x_buf is allocated or stack
    unsigned int x_count; // number of samples seen so far
    unsigned int x_npoints; // number of samples for moving average
    unsigned int x_sz; // allocated size for x_buf
    unsigned int x_bufrd; // readhead for buffer
    unsigned int x_max; // max size of buffer as specified by argument
} rmsaverage;

void rmsaverage_zerobuf(rmsaverage *x) {
    unsigned int i;
    for (i=0; i < x->x_sz; i++) {
        x->x_buf[i] = 0.;
    };
}

void rmsaverage_reset(rmsaverage *x) {
    // clear buffer and reset everything to 0
    x->x_count = 0;
    x->x_accum = 0;
    x->x_bufrd = 0;
    rmsaverage_zerobuf(x);
}

void rmsaverage_sz(rmsaverage *x, unsigned int newsz) {
    // helper function to deal with allocation issues if needed
    int alloc = x->x_alloc;
    unsigned int cursz = x->x_sz; //current size
    // requested size
    if (newsz < 0) {
        newsz = 0;
    } else if (newsz > AVERAGE_MAXBUF) {
        newsz = AVERAGE_MAXBUF;
    };
    if (!alloc && newsz > AVERAGE_STACK) {
        x->x_buf = (float *)malloc(sizeof(float) * newsz);
        x->x_alloc = 1;
        x->x_sz = newsz;
    } else if (alloc && newsz > cursz) {
        x->x_buf = (float *)realloc(x->x_buf, sizeof(float) * newsz);
        x->x_sz = newsz;
    } else if (alloc && newsz < AVERAGE_STACK) {
        free(x->x_buf);
        x->x_sz = AVERAGE_STACK;
        x->x_buf = x->x_stack;
        x->x_alloc = 0;
    };
    rmsaverage_reset(x);
}

double rmsaverage_rmssum(float input, float accum, int add) {
    if (add) {
        accum += (input * input);
    } else {
        accum -= (input * input);
    };
    return (accum);
}

int rmsaverage_compute(rmsaverage *x, float *inSample, float *outSample) {
    int i;
    unsigned int npoints = x->x_npoints;
    float result; // eventual result
    float input = *inSample;
    if (npoints > 1) {
        unsigned int bufrd = x->x_bufrd;
        // add input to accumulator
        x->x_accum = rmsaverage_rmssum(input, x->x_accum, 1);
        x->x_calib = rmsaverage_rmssum(input, x->x_calib, 1);
        unsigned int count = x->x_count;
        if(count < npoints) {
            // update count
            count++;
            x->x_count = count;
        } else {
            x->x_accum = rmsaverage_rmssum(x->x_buf[bufrd], x->x_accum, 0);
        };

        // overwrite/store current input value into buf
        x->x_buf[bufrd] = input;

        // calculate result
        result = x->x_accum/(float)npoints;
        result = sqrt(result);

        // incrementation step
        bufrd++;
        if (bufrd >= npoints) {
            bufrd = 0;
            x->x_accum = x->x_calib;
            x->x_calib = 0.0;
        };
        x->x_bufrd = bufrd;
    } else {
        result = fabs(input);
    }
    if (isnan(result))
        result = input;

    *outSample = result;
    return 1;
}

int rmsaverage_init(rmsaverage *x, unsigned int pointCount) {
    unsigned int maxbuf = AVERAGE_DEFNPOINTS; // default for max buf size
    // default to stack for now...
    x->x_buf = x->x_stack;
    x->x_alloc = 0;
    x->x_sz = AVERAGE_STACK;

    //now allocate x_buf if necessary
    rmsaverage_sz(x, x->x_npoints);

    rmsaverage_reset(x);
    
    x->x_npoints = pointCount;
    return 1;
}

int rmsaverage_create(rmsaverage **x) {
    *x = (rmsaverage *)malloc(sizeof(rmsaverage));
    return 1;
}

int rmsaverage_destroy(rmsaverage **x) {
    rmsaverage *xx = *x;
    free(*x);
    return 1;
}
// MARK: END Cyclone RMS

// MARK: BEGIN Cyclone Slide
typedef struct {
    int x_slide_up;
    int x_slide_down;
    float x_last;
} slide;

int slide_compute(slide *x, float *inSample, float *outSample) {
    float last = x->x_last;
    float f = *inSample;
    float output;
    if (f >= last) {
        if (x->x_slide_up > 1.)
            output = last + ((f - last) / x->x_slide_up);
        else
            output = last = f;
    } else if (f < last) {
        if (x->x_slide_down > 1)
            output = last + ((f - last) / x->x_slide_down);
        else
            output = last = f;
    }
    if (output == last && output != f)
        output = f;
    if (isnan(output))
        output = *inSample;

    *outSample = output;
    last = output;
    x->x_last = last;
    return 1;
}

void slide_reset(slide *x) {
    x->x_last = 0;
}

void slide_slide_up(slide *x, float f) {
    int i = (int)f;
    if (i > 1) {
        x->x_slide_up = i;
    } else {
        x->x_slide_up = 0;
    }
}

void slide_slide_down(slide *x, float f) {
    int i = (int)f;
    if (i > 1) {
        x->x_slide_down = i;
    } else {
        x->x_slide_down = 0;
    }
}

int slide_init(slide *x, float slideUpSamples, float slideDownSamples) {
    float f1 = slideUpSamples;
    float f2 = slideDownSamples;
    slide_slide_up(x, f1);
    slide_slide_down(x, f2);
    x->x_last = 0.;
    return 1;
}

int slide_create(slide **x) {
    *x = (slide *)malloc(sizeof(slide));
    return 1;
}

int slide_destroy(slide **x) {
    slide *xx = *x;
    free(*x);
    return 1;
}
// MARK: END Cyclone Slide

enum TransientShaperParameter : AUParameterAddress {
    TransientShaperParameterInputAmount,
    TransientShaperParameterAttackAmount,
    TransientShaperParameterReleaseAmount,
    TransientShaperParameterOutputAmount,
};

class TransientShaperDSP : public DSPBase {
private:
    rmsaverage *leftRMSAverage1;
    rmsaverage *rightRMSAverage1;
    rmsaverage *leftRMSAverage2;
    rmsaverage *rightRMSAverage2;
    slide *leftAttackSlideUp;
    slide *rightAttackSlideUp;
    slide *leftAttackSlideDown;
    slide *rightAttackSlideDown;
    slide *leftReleaseSlideDown;
    slide *rightReleaseSlideDown;

    AudioKitCore::StereoDelay delay1;

    ParameterRamper inputAmountRamp;
    ParameterRamper attackAmountRamp;
    ParameterRamper releaseAmountRamp;
    ParameterRamper outputAmountRamp;
public:
    TransientShaperDSP() : DSPBase(1, true) {
        parameters[TransientShaperParameterInputAmount] = &inputAmountRamp;
        parameters[TransientShaperParameterAttackAmount] = &attackAmountRamp;
        parameters[TransientShaperParameterReleaseAmount] = &releaseAmountRamp;
        parameters[TransientShaperParameterOutputAmount] = &outputAmountRamp;
    }

    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        DSPBase::setParameter(address, value, immediate);
    }

    float getParameter(uint64_t address) override {
        return DSPBase::getParameter(address);
    }

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

        rmsaverage_create(&leftRMSAverage1);
        rmsaverage_init(leftRMSAverage1, 441);
        rmsaverage_create(&rightRMSAverage1);
        rmsaverage_init(rightRMSAverage1, 441);
        rmsaverage_create(&leftRMSAverage2);
        rmsaverage_init(leftRMSAverage2, 882);
        rmsaverage_create(&rightRMSAverage2);
        rmsaverage_init(rightRMSAverage2, 882);
        slide_create(&leftAttackSlideUp);
        slide_init(leftAttackSlideUp, 882, 0);
        slide_create(&rightAttackSlideUp);
        slide_init(rightAttackSlideUp, 882, 0);
        slide_create(&leftAttackSlideDown);
        slide_init(leftAttackSlideDown, 0, 882);
        slide_create(&rightAttackSlideDown);
        slide_init(rightAttackSlideDown, 0, 882);
        slide_create(&leftReleaseSlideDown);
        slide_init(leftReleaseSlideDown, 0, 44100);
        slide_create(&rightReleaseSlideDown);
        slide_init(rightReleaseSlideDown, 0, 44100);

        delay1.init(sampleRate, 10);
    }

    void deinit() override {
        DSPBase::deinit();

        rmsaverage_destroy(&leftRMSAverage1);
        rmsaverage_destroy(&rightRMSAverage1);
        rmsaverage_destroy(&leftRMSAverage2);
        rmsaverage_destroy(&rightRMSAverage2);
        slide_destroy(&leftAttackSlideUp);
        slide_destroy(&rightAttackSlideUp);
        slide_destroy(&leftAttackSlideDown);
        slide_destroy(&rightAttackSlideDown);
        slide_destroy(&leftReleaseSlideDown);
        slide_destroy(&rightReleaseSlideDown);

        delay1.deinit();
    }

    void reset() override {
        DSPBase::reset();

        rmsaverage_create(&leftRMSAverage1);
        rmsaverage_init(leftRMSAverage1, 441);
        rmsaverage_create(&rightRMSAverage1);
        rmsaverage_init(rightRMSAverage1, 441);
        rmsaverage_create(&leftRMSAverage2);
        rmsaverage_init(leftRMSAverage2, 882);
        rmsaverage_create(&rightRMSAverage2);
        rmsaverage_init(rightRMSAverage2, 882);
        slide_create(&leftAttackSlideUp);
        slide_init(leftAttackSlideUp, 882, 0);
        slide_create(&rightAttackSlideUp);
        slide_init(rightAttackSlideUp, 882, 0);
        slide_create(&leftAttackSlideDown);
        slide_init(leftAttackSlideDown, 0, 882);
        slide_create(&rightAttackSlideDown);
        slide_init(rightAttackSlideDown, 0, 882);
        slide_create(&leftReleaseSlideDown);
        slide_init(leftReleaseSlideDown, 0, 44100);
        slide_create(&rightReleaseSlideDown);
        slide_init(rightReleaseSlideDown, 0, 44100);

        delay1.init(sampleRate, 10);

        delay1.clear();
    }

    float convertMsToSamples(float fMilleseconds, float fSampleRate) {
        return fMilleseconds * (fSampleRate / 1000.0);
    }

    float convertMsToSeconds(float fMilleseconds) {
        return fMilleseconds / 1000;
    }

    float convertSecondsToCutoffFrequency(float fSeconds) {
        return 1.0 / (2 * M_PI * fSeconds);
    }

    int compute_attackLR(float *inChannels[2],
                         float *outChannels[2],
                         rmsaverage *leftAverage,
                         rmsaverage *rightAverage,
                         slide *leftSlideUp,
                         slide *rightSlideUp,
                         slide *leftSlideDown,
                         slide *rightSlideDown,
                         const int frameOffset)
    {
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            float *out = (float *)outChannels[channel];
            float *basicout = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                inChannels[channel] = in;
                outChannels[channel] = out;
            }
            if (!isStarted) {
                *basicout = *in;
                continue;
            }
        }

        float *tmpRMSOut[2];
        float *leftRMSOut;
        float leftRMS;
        leftRMSOut = &leftRMS;
        float *rightRMSOut;
        float rightRMS;
        rightRMSOut = &rightRMS;
        tmpRMSOut[0] = leftRMSOut;
        tmpRMSOut[1] = rightRMSOut;

        rmsaverage_compute(leftAverage, inChannels[0], tmpRMSOut[0]);
        rmsaverage_compute(rightAverage, inChannels[1], tmpRMSOut[1]);

        float *tmpMixOut[2];
        float *leftMixOut;
        float leftMix;
        leftMixOut = &leftMix;
        float *rightMixOut;
        float rightMix;
        rightMixOut = &rightMix;
        tmpMixOut[0] = leftMixOut;
        tmpMixOut[1] = rightMixOut;

        // Mix Left and Right Channel (on left channel) and half them
        *tmpMixOut[0] = (*tmpRMSOut[0] + *tmpRMSOut[1]) * 0.5;

        // Set the channels equal
        *tmpMixOut[1] = *tmpMixOut[0];

        // Copy this signal for later comparison
        float attackMixCopy = *tmpMixOut[0];

        float *tmpSlideOut[2];
        float *leftSlideOut;
        float leftSlide;
        leftSlideOut = &leftSlide;
        float *rightSlideOut;
        float rightSlide;
        rightSlideOut = &rightSlide;
        tmpSlideOut[0] = leftSlideOut;
        tmpSlideOut[1] = rightSlideOut;

        slide_compute(leftSlideUp, tmpMixOut[0], tmpSlideOut[0]);
        slide_compute(rightSlideUp, tmpMixOut[1], tmpSlideOut[1]);

        // Make channels equivalent again
        if (*tmpSlideOut[0] != *tmpSlideOut[1])
            *tmpSlideOut[0] = *tmpSlideOut[1];
        float slideMixCopy = *tmpSlideOut[0];

        // MARK: BEGIN Logic

        float slideToCompare = slideMixCopy + 0.0; // FIXME: later replace this with attack sensitivity
        
        float comparator1 = 0.0;

        if (attackMixCopy >= slideToCompare)
            comparator1 = 1.0;
        else
            comparator1 = 0.0;

        float subtractedMix1 = attackMixCopy - slideMixCopy;

        *outChannels[0] = comparator1 * subtractedMix1;
        *outChannels[1] = comparator1 * subtractedMix1;

        // MARK: END Logic
        slide_compute(leftSlideDown, outChannels[0], outChannels[0]);
        slide_compute(rightSlideDown, outChannels[1], outChannels[1]);
        return 1;
    }

    int compute_releaseLR(float *inChannels[2],
                         float *outChannels[2],
                         rmsaverage *leftAverage,
                         rmsaverage *rightAverage,
                         slide *leftSlideDown,
                         slide *rightSlideDown,
                         const int frameOffset)
    {
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            float *out = (float *)outChannels[channel];
            float *basicout = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                inChannels[channel] = in;
                outChannels[channel] = out;
            }
            if (!isStarted) {
                *basicout = *in;
                continue;
            }
        }

        float *tmpRMSOut[2];
        float *leftRMSOut;
        float leftRMS;
        leftRMSOut = &leftRMS;
        float *rightRMSOut;
        float rightRMS;
        rightRMSOut = &rightRMS;
        tmpRMSOut[0] = leftRMSOut;
        tmpRMSOut[1] = rightRMSOut;

        rmsaverage_compute(leftAverage, inChannels[0], tmpRMSOut[0]);
        rmsaverage_compute(rightAverage, inChannels[1], tmpRMSOut[1]);

        float *tmpMixOut[2];
        float *leftMixOut;
        float leftMix;
        leftMixOut = &leftMix;
        float *rightMixOut;
        float rightMix;
        rightMixOut = &rightMix;
        tmpMixOut[0] = leftMixOut;
        tmpMixOut[1] = rightMixOut;

        // Mix Left and Right Channel (on left channel) and half them
        *tmpMixOut[0] = (*tmpRMSOut[0] + *tmpRMSOut[1]) * 0.5;

        // Set the channels equal
        *tmpMixOut[1] = *tmpMixOut[0];
        
        // Copy this signal for later comparison
        float releaseMixCopy = *tmpMixOut[0];

        float *tmpSlideOut[2];
        float *leftSlideOut;
        float leftSlide;
        leftSlideOut = &leftSlide;
        float *rightSlideOut;
        float rightSlide;
        rightSlideOut = &rightSlide;
        tmpSlideOut[0] = leftSlideOut;
        tmpSlideOut[1] = rightSlideOut;

        slide_compute(leftSlideDown, tmpMixOut[0], tmpSlideOut[0]);
        slide_compute(rightSlideDown, tmpMixOut[1], tmpSlideOut[1]);

        // Make channels equivalent again
        if (*tmpSlideOut[0] != *tmpSlideOut[1])
            *tmpSlideOut[0] = *tmpSlideOut[1];
        float slideMixCopy = *tmpSlideOut[0];

        // MARK: BEGIN Logic

        float slideToCompare = slideMixCopy + 0.0; // FIXME: later replace this with release sensitivity
        
        float comparator1 = 0.0;

        if (releaseMixCopy <= slideToCompare)
            comparator1 = 1.0;
        else
            comparator1 = 0.0;

        float subtractedMix1 = slideMixCopy - releaseMixCopy;

        *outChannels[0] = comparator1 * subtractedMix1;
        *outChannels[1] = comparator1 * subtractedMix1;

        // MARK: END Logic
        return 1;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        const float *inBuffers[2];
        float *outBuffers[2];
        inBuffers[0]  = (const float *)inputBufferLists[0]->mBuffers[0].mData  + bufferOffset;
        inBuffers[1]  = (const float *)inputBufferLists[0]->mBuffers[1].mData  + bufferOffset;
        outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + bufferOffset;
        outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + bufferOffset;
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            const int frameOffset = int(frameIndex + bufferOffset);

            delay1.setDelayMs(10.0);
            delay1.setFeedback(0.0);
            delay1.setDryWetMix(0.0);

            float *tmpAttackIn[2];
            float *tmpAttackOut[2];
            float *tmpReleaseIn[2];
            float *tmpReleaseOut[2];
            float *tmpLeftMixOut;
            float tmpLeftMixOutVal;
            tmpLeftMixOut = &tmpLeftMixOutVal;
            float *tmpRightMixOut;
            float tmpRightMixOutVal;
            tmpRightMixOut = &tmpRightMixOutVal;

            // get input volume
            float inputAmount = inputAmountRamp.getAndStep();

            // convert decibels to amplitude
            *outBuffers[0] = *outBuffers[0] * pow(10., inputAmount / 20.0);
            *outBuffers[1]= *outBuffers[1] * pow(10., inputAmount / 20.0);

            float attackA = attackAmountRamp.getAndStep() * 2.5;
            float releaseA = releaseAmountRamp.getAndStep() * 2.5;

            float *leftAttackOut;
            float leftAttackOutVal;
            leftAttackOut = &leftAttackOutVal;
            float *rightAttackOut;
            float rightAttackOutVal;
            rightAttackOut = &rightAttackOutVal;

            float *leftReleaseOut;
            float leftReleaseOutVal;
            leftReleaseOut = &leftReleaseOutVal;
            float *rightReleaseOut;
            float rightReleaseOutVal;
            rightReleaseOut = &rightReleaseOutVal;

            tmpAttackOut[0] = leftAttackOut;
            tmpAttackOut[1] = rightAttackOut;
            tmpReleaseOut[0] = leftReleaseOut;
            tmpReleaseOut[1] = rightReleaseOut;

            compute_attackLR(tmpAttackIn, tmpAttackOut, leftRMSAverage1, rightRMSAverage1, leftAttackSlideUp, rightAttackSlideUp, leftAttackSlideDown, rightAttackSlideDown, frameOffset);

            compute_releaseLR(tmpReleaseIn, tmpReleaseOut, leftRMSAverage2, rightRMSAverage2, leftReleaseSlideDown, rightReleaseSlideDown, frameOffset);

            *tmpAttackOut[0] = *leftAttackOut * attackA;
            *tmpAttackOut[1] = *rightAttackOut * attackA;
            *tmpReleaseOut[0] = *leftReleaseOut * releaseA;
            *tmpReleaseOut[1] = *rightReleaseOut * releaseA;

            // mix release and attack
            *tmpRightMixOut = *tmpAttackOut[0] + *tmpReleaseOut[0];
            *tmpLeftMixOut = *tmpAttackOut[1] + *tmpReleaseOut[1];

            // convert decibels to amplitude
            *tmpLeftMixOut = pow(10., *tmpLeftMixOut / 20.0);
            *tmpRightMixOut = pow(10., *tmpRightMixOut / 20.0);

            // reduce/increase output decibels

            float output = outputAmountRamp.getAndStep();

            *tmpLeftMixOut = *tmpLeftMixOut * pow(10., output / 20.0);
            *tmpRightMixOut = *tmpRightMixOut * pow(10., output / 20.0);

            float *tmpDelayOut[2];
            float *leftDelayOut;
            float leftDelayOutVal;
            leftDelayOut = &leftDelayOutVal;
            float *rightDelayOut;
            float rightDelayOutVal;
            rightDelayOut = &rightDelayOutVal;
            tmpDelayOut[0] = leftDelayOut;
            tmpDelayOut[1] = rightDelayOut;

            delay1.render(1, inBuffers, tmpDelayOut);

            // multiply delay buffers by the mix
            *outBuffers[0] = *tmpDelayOut[0] * *tmpLeftMixOut;
            *outBuffers[1] = *tmpDelayOut[1] * *tmpRightMixOut;

            inBuffers[0]++;
            inBuffers[1]++;
            outBuffers[0]++;
            outBuffers[1]++;
        }
    }
};
AK_REGISTER_DSP(TransientShaperDSP, "trsh")
AK_REGISTER_PARAMETER(TransientShaperParameterInputAmount)
AK_REGISTER_PARAMETER(TransientShaperParameterAttackAmount)
AK_REGISTER_PARAMETER(TransientShaperParameterReleaseAmount)
AK_REGISTER_PARAMETER(TransientShaperParameterOutputAmount)
