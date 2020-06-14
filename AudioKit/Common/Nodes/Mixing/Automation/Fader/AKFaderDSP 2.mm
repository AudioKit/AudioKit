//
//  AKFaderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka and Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#include "AKFaderDSP.hpp"
#import "ParameterRamper.hpp"

extern "C" AKDSPRef createFaderDSP(int channelCount, double sampleRate)
{
    AKFaderDSP *dsp = new AKFaderDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKFaderDSP::InternalData {
    ParameterRamper leftGainRamp = 1.0;
    ParameterRamper rightGainRamp = 1.0;
    Boolean flipStereo = false;
    Boolean mixToMono = false;
};

AKFaderDSP::AKFaderDSP() : data(new InternalData)
{
}




// Uses the ParameterAddress as a key
void AKFaderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate)
{
    switch (address) {
        case AKFaderParameterLeftGain:
            data->leftGainRamp.setUIValue(value);
            // ramp to the new value
            data->leftGainRamp.dezipperCheck(1024);
            break;
        case AKFaderParameterRightGain:
            data->rightGainRamp.setUIValue(value);
            // ramp to the new value
            data->rightGainRamp.dezipperCheck(1024);
            break;
        case AKFaderParameterTaper:
            data->leftGainRamp.setTaper(value);
            data->rightGainRamp.setTaper(value);
            break;
        case AKFaderParameterSkew:
            data->leftGainRamp.setSkew(value);
            data->rightGainRamp.setSkew(value);
            break;
        case AKFaderParameterOffset:
            data->leftGainRamp.setOffset((AUAudioFrameCount)value);
            data->rightGainRamp.setOffset((AUAudioFrameCount)value);
            break;
        case AKFaderParameterFlipStereo:
            if (value > 0) {
                data->flipStereo = true;
            } else {
                data->flipStereo = false;
            }
            break;
        case AKFaderParameterMixToMono:
            if (value > 0) {
                data->mixToMono = true;
            } else {
                data->mixToMono = false;
            }
    }
}

// Uses the ParameterAddress as a key
float AKFaderDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKFaderParameterLeftGain:
            return data->leftGainRamp.getUIValue();
        case AKFaderParameterRightGain:
            return data->rightGainRamp.getUIValue();
        case AKFaderParameterTaper:
            // assume both channels are the same taper?
            return data->leftGainRamp.getTaper();
        case AKFaderParameterSkew:
            return data->leftGainRamp.getSkew();
        case AKFaderParameterOffset:
            return data->leftGainRamp.getOffset();
        case AKFaderParameterFlipStereo:
            return data->flipStereo;
        case AKFaderParameterMixToMono:
            return data->mixToMono;
    }
    return 0;
}

void AKFaderDSP::start()
{
    isStarted = true;
}

void AKFaderDSP::stop()
{
    isStarted = false;
}

void AKFaderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
            }
        }
        if (isStarted) {
            if (channelCount == 2 && data->mixToMono) {
                *tmpout[0] = 0.5 * (*tmpin[0] * data->leftGainRamp.getAndStep() + *tmpin[1] * data->rightGainRamp.getAndStep());
                *tmpout[1] = *tmpout[0];
            } else {
                if (channelCount == 2 && data->flipStereo) {
                    *tmpout[0] = *tmpin[1] * data->leftGainRamp.getAndStep();
                    *tmpout[1] = *tmpin[0] * data->rightGainRamp.getAndStep();
                } else {
                    *tmpout[0] = *tmpin[0] * data->leftGainRamp.getAndStep();
                    *tmpout[1] = *tmpin[1] * data->rightGainRamp.getAndStep();
                }
            }
        }
    }
}

void AKFaderDSP::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration)
{
    // Note, if duration is 0 frames, startRamp will setImmediate
    switch (address) {
        case AKFaderParameterLeftGain:
            data->leftGainRamp.startRamp(value, duration);
            break;
        case AKFaderParameterRightGain:
            data->rightGainRamp.startRamp(value, duration);
            break;
        case AKFaderParameterTaper:
            data->leftGainRamp.setTaper(value);
            data->rightGainRamp.setTaper(value);
            break;
        case AKFaderParameterSkew:
            data->leftGainRamp.setSkew(value);
            data->rightGainRamp.setSkew(value);
            break;
        case AKFaderParameterOffset:
            data->leftGainRamp.setOffset(value);
            data->rightGainRamp.setOffset(value);
            break;
    }
}
