//
//  TransientShaperDSP.m
//  CAudioKit
//
//  Created by Evan Murray on 1/6/21.
//

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include "AudioKitCore/Modulated Delay/StereoDelay.hpp"

// MARK: BEGIN RMS Average Class
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
// MARK: END RMS Average Class

// MARK: BEGIN Slide Class
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
// MARK: END Slide Class

enum TransientShaperParameter : AUParameterAddress {
    TransientShaperParameterInputAmount,
    TransientShaperParameterAttackAmount,
    TransientShaperParameterReleaseAmount,
    TransientShaperParameterOutputAmount,
};

class TransientShaperDSP : public SoundpipeDSPBase {
private:
    int timer1;

    rmsaverage *rmsAverage1L;
    rmsaverage *rmsAverage1R;
    rmsaverage *rmsAverage2L;
    rmsaverage *rmsAverage2R;
    slide *attackSlideUpL;
    slide *attackSlideUpR;
    slide *attackSlideDownL;
    slide *attackSlideDownR;
    slide *releaseSlideDownL;
    slide *releaseSlideDownR;

    AudioKitCore::StereoDelay delay1;

    ParameterRamper inputAmountRamp;
    ParameterRamper attackAmountRamp;
    ParameterRamper releaseAmountRamp;
    ParameterRamper outputAmountRamp;
public:
    TransientShaperDSP() {
        parameters[TransientShaperParameterInputAmount] = &inputAmountRamp;
        parameters[TransientShaperParameterAttackAmount] = &attackAmountRamp;
        parameters[TransientShaperParameterReleaseAmount] = &releaseAmountRamp;
        parameters[TransientShaperParameterOutputAmount] = &outputAmountRamp;

        bCanProcessInPlace = true;
    }

    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        SoundpipeDSPBase::setParameter(address, value, immediate);
    }

    float getParameter(uint64_t address) override {
        return SoundpipeDSPBase::getParameter(address);
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);

        timer1 = 0;

        rmsaverage_create(&rmsAverage1L);
        rmsaverage_init(rmsAverage1L, 441);
        rmsaverage_create(&rmsAverage1R);
        rmsaverage_init(rmsAverage1R, 441);
        rmsaverage_create(&rmsAverage2L);
        rmsaverage_init(rmsAverage2L, 882);
        rmsaverage_create(&rmsAverage2R);
        rmsaverage_init(rmsAverage2R, 882);
        slide_create(&attackSlideUpL);
        slide_init(attackSlideUpL, 882, 882);
        slide_create(&attackSlideUpR);
        slide_init(attackSlideUpR, 882, 882);
        slide_create(&attackSlideDownL);
        slide_init(attackSlideDownL, 882, 882);
        slide_create(&attackSlideDownR);
        slide_init(attackSlideDownR, 882, 882);
        slide_create(&releaseSlideDownL);
        slide_init(releaseSlideDownL, 882, 44100);
        slide_create(&releaseSlideDownR);
        slide_init(releaseSlideDownR, 882, 44100);

        delay1.init(sampleRate, 2000);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();

        timer1 = 0;

        rmsaverage_destroy(&rmsAverage1L);
        rmsaverage_destroy(&rmsAverage1R);
        rmsaverage_destroy(&rmsAverage2L);
        rmsaverage_destroy(&rmsAverage2R);
        slide_destroy(&attackSlideUpL);
        slide_destroy(&attackSlideUpR);
        slide_destroy(&attackSlideDownL);
        slide_destroy(&attackSlideDownR);
        slide_destroy(&releaseSlideDownL);
        slide_destroy(&releaseSlideDownR);

        delay1.deinit();
    }

    void reset() override {
        SoundpipeDSPBase::reset();

        timer1 = 0;

        rmsaverage_create(&rmsAverage1L);
        rmsaverage_init(rmsAverage1L, 441);
        rmsaverage_create(&rmsAverage1R);
        rmsaverage_init(rmsAverage1R, 441);
        rmsaverage_create(&rmsAverage2L);
        rmsaverage_init(rmsAverage2L, 882);
        rmsaverage_create(&rmsAverage2R);
        rmsaverage_init(rmsAverage2R, 882);
        slide_create(&attackSlideUpL);
        slide_init(attackSlideUpL, 882, 882);
        slide_create(&attackSlideUpR);
        slide_init(attackSlideUpR, 882, 882);
        slide_create(&attackSlideDownL);
        slide_init(attackSlideDownL, 882, 882);
        slide_create(&attackSlideDownR);
        slide_init(attackSlideDownR, 882, 882);
        slide_create(&releaseSlideDownL);
        slide_init(releaseSlideDownL, 882, 44100);
        slide_create(&releaseSlideDownR);
        slide_init(releaseSlideDownR, 882, 44100);

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
                         rmsaverage *averageL,
                         rmsaverage *averageR,
                         slide *slideupL,
                         slide *slideupR,
                         slide *slidedownL,
                         slide *slidedownR,
                         const int frameOffset)
    {
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
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

        rmsaverage_compute(averageL, inChannels[0], outChannels[0]);
        rmsaverage_compute(averageR, inChannels[1], outChannels[1]);

        // Mix Left and Right Channel (on left channel) and half them
        *outChannels[0] = (*outChannels[0] + *outChannels[1]) * 0.5;

        // Set the channels equal
        *outChannels[0] = *outChannels[1];
        
        // Copy this signal for later comparison
        float attackMixCopy = *outChannels[0];

        slide_compute(slideupL, inChannels[0], outChannels[0]);
        slide_compute(slideupR, inChannels[1], outChannels[1]);

        // Make channels equivalent again
        if (*outChannels[0] != *outChannels[1])
            *outChannels[0] = *outChannels[1];
        float slideMixCopy = *outChannels[0];

        // MARK: BEGIN Logic

        slideMixCopy = slideMixCopy + 0.0; // FIXME: later replace this with attack sensitivity
        
        float comparator1 = 0.0;

        if (attackMixCopy >= slideMixCopy)
            comparator1 = 1.0;
        else
            comparator1 = 0.0;

        float subtractedMix1 = attackMixCopy - slideMixCopy;

        *outChannels[0] = comparator1 * subtractedMix1;
        *outChannels[1] = comparator1 * subtractedMix1;

        // MARK: END Logic
        slide_compute(attackSlideDownL, inChannels[0], outChannels[0]);
        slide_compute(attackSlideDownR, inChannels[1], outChannels[1]);
        return 1;
    }

    int compute_releaseLR(float *inChannels[2],
                         float *outChannels[2],
                         rmsaverage *averageL,
                         rmsaverage *averageR,
                         slide *slidedownL,
                         slide *slidedownR,
                         const int frameOffset)
    {
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
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

        rmsaverage_compute(averageL, inChannels[0], outChannels[0]);
        rmsaverage_compute(averageR, inChannels[1], outChannels[1]);

        // Mix Left and Right Channel (on left channel) and half them
        *outChannels[0] = (*outChannels[0] + *outChannels[1]) * 0.5;

        // Set the channels equal
        *outChannels[0] = *outChannels[1];
        
        // Copy this signal for later comparison
        float releaseMixCopy = *outChannels[0];

        slide_compute(slidedownL, inChannels[0], outChannels[0]);
        slide_compute(slidedownR, inChannels[1], outChannels[1]);

        // Make channels equivalent again
        if (*outChannels[0] != *outChannels[1])
            *outChannels[0] = *outChannels[1];
        float slideMixCopy = *outChannels[0];

        // MARK: BEGIN Logic

        slideMixCopy = slideMixCopy + 0.0; // FIXME: later replace this with release sensitivity
        
        float comparator1 = 0.0;

        if (releaseMixCopy <= slideMixCopy)
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

            float *tmpinattack[2];
            float *tmpoutattack[2];
            float *tmpinrelease[2];
            float *tmpoutrelease[2];
            float *tmpOutMixL;
            float tmpOutMixValL;
            tmpOutMixL = &tmpOutMixValL;
            float *tmpOutMixR;
            float tmpOutMixValR;
            tmpOutMixR = &tmpOutMixValR;

            // get input volume
            float inputAmount = inputAmountRamp.getAndStep();

            // convert decibels to amplitude
            *outBuffers[0] = *outBuffers[0] * pow(10., inputAmount / 20.0);
            *outBuffers[1]= *outBuffers[1] * pow(10., inputAmount / 20.0);

            delay1.render(1, inBuffers, outBuffers);

            float attackA = attackAmountRamp.getAndStep() * 2.5;
            float releaseA = releaseAmountRamp.getAndStep() * 2.5;

            float *attackOutL;
            float attackL;
            attackOutL = &attackL;
            float *attackOutR;
            float attackR;
            attackOutR = &attackR;

            float *releaseOutL;
            float releaseL;
            releaseOutL = &releaseL;
            float *releaseOutR;
            float releaseR;
            releaseOutR = &releaseR;

            tmpoutattack[0] = attackOutL;
            tmpoutattack[1] = attackOutR;
            tmpoutrelease[0] = releaseOutL;
            tmpoutrelease[1] = releaseOutR;

            compute_attackLR(tmpinattack, tmpoutattack, rmsAverage1L, rmsAverage1R, attackSlideUpL, attackSlideUpR, attackSlideDownL, attackSlideDownR, frameOffset);

            compute_releaseLR(tmpinrelease, tmpoutrelease, rmsAverage2L, rmsAverage2R, releaseSlideDownL, releaseSlideDownR, frameOffset);

            *tmpoutattack[0] = *attackOutL * attackA;
            *tmpoutattack[1] = *attackOutR * attackA;
            *tmpoutrelease[0] = *releaseOutL * releaseA;
            *tmpoutrelease[1] = *releaseOutR * releaseA;

            // mix release and attack
            *tmpOutMixL = *tmpoutattack[0] + *tmpoutrelease[0];
            *tmpOutMixR = *tmpoutattack[1] + *tmpoutrelease[1];

            // convert decibels to amplitude
            *tmpOutMixL = pow(10., *tmpOutMixL / 20.0);
            *tmpOutMixR = pow(10., *tmpOutMixR / 20.0);

            // reduce/increase output decibels

            float output = outputAmountRamp.getAndStep();

            *tmpOutMixL = *tmpOutMixL * pow(10., output / 20.0);
            *tmpOutMixR = *tmpOutMixR * pow(10., output / 20.0);

            // multiply delay buffers by the mix
            *outBuffers[0] = *outBuffers[0] * *tmpOutMixL;
            *outBuffers[1] = *outBuffers[1] * *tmpOutMixR;

            inBuffers[0]++;
            inBuffers[1]++;
            outBuffers[0]++;
            outBuffers[1]++;
        }
    }
};
AK_REGISTER_DSP(TransientShaperDSP)
AK_REGISTER_PARAMETER(TransientShaperParameterInputAmount)
AK_REGISTER_PARAMETER(TransientShaperParameterAttackAmount)
AK_REGISTER_PARAMETER(TransientShaperParameterReleaseAmount)
AK_REGISTER_PARAMETER(TransientShaperParameterOutputAmount)
