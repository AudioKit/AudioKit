//
//  AKBoosterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBoosterDSP.hpp"
#import "ParameterRamper.hpp"

extern "C" AKDSPRef createBoosterDSP(int channelCount, double sampleRate)
{
    AKBoosterDSP *dsp = new AKBoosterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKBoosterDSP::InternalData {
//    AKParameterRamp leftGainRamp;
//    AKParameterRamp rightGainRamp;

    ParameterRamper leftGainRamp = 1.0;
    ParameterRamper rightGainRamp = 1.0;
};

AKBoosterDSP::AKBoosterDSP() : data(new InternalData)
{
//    data->leftGainRamp.setTarget(1.0, true);
//    data->leftGainRamp.setDurationInSamples(10000);
//    data->rightGainRamp.setTarget(1.0, true);
//    data->rightGainRamp.setDurationInSamples(10000);
}

// Uses the ParameterAddress as a key
void AKBoosterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate)
{
    switch (address) {
        case AKBoosterParameterLeftGain:
            printf("Setting AKBoosterParameterLeftGain %f\n", value);

            data->leftGainRamp.setUIValue(value);
            // ramp to the new value
            data->leftGainRamp.dezipperCheck(9600);
            break;
        case AKBoosterParameterRightGain:
            printf("Setting AKBoosterParameterRightGain %f\n", value);

            data->rightGainRamp.setUIValue(value);
            // ramp to the new value
            data->rightGainRamp.dezipperCheck(9600);

            break;
        case AKBoosterParameterRampDuration:
//            data->leftGainRamp.setRampDuration(value, sampleRate);
//            data->rightGainRamp.setRampDuration(value, sampleRate);

//            data->leftGainRamp.startRamp(data->leftGainRamp.get(), value);
//            data->rightGainRamp.startRamp(data->rightGainRamp.get(), value);

//            data->leftGainRamp.dezipperCheck(value);
//            data->rightGainRamp.dezipperCheck(value);

            break;
        case AKBoosterParameterRampType:
//            data->leftGainRamp.setRampType(value);
//            data->rightGainRamp.setRampType(value);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBoosterDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
//        case AKBoosterParameterLeftGain:
//            return data->leftGainRamp.getTarget();
//        case AKBoosterParameterRightGain:
//            return data->rightGainRamp.getTarget();
//        case AKBoosterParameterRampDuration:
//            return data->leftGainRamp.getRampDuration(sampleRate);

        case AKBoosterParameterLeftGain:
            return data->leftGainRamp.getUIValue();
        case AKBoosterParameterRightGain:
            return data->rightGainRamp.getUIValue();

//            case AKBoosterParameterRampDuration:
//            //    return data->leftGainRamp.getRampDuration(sampleRate);
//            return data->leftGainRamp.;
    }
    return 0;
}

void AKBoosterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        // do ramping every 8 samples
//        if ((frameOffset & 0x7) == 0) {
//            // printf("advancing ramp %i\n", frameOffset);
//            data->leftGainRamp.advanceTo(now + frameOffset);
//            data->rightGainRamp.advanceTo(now + frameOffset);
//        }

        // do actual signal processing
        // After all this scaffolding, the only thing we are doing is scaling the input
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel == 0) {
                //*out = *in * data->leftGainRamp.getValue();
                *out = *in * data->leftGainRamp.getAndStep();
            } else {
                //*out = *in * data->rightGainRamp.getValue();
                *out = *in * data->rightGainRamp.getAndStep();
            }
        }
    }
}

void AKBoosterDSP::handleParamEvent(AUParameterEvent event)
{
    printf("AKBoosterDSP.handleParamEvent() eventSampleTime %lld, value %f, rampDurationSampleFrames %d\n", event.eventSampleTime, event.value, event.rampDurationSampleFrames);

    //setParameter(event.parameterAddress, event.value, true);
    //bool immediate = event.rampDurationSampleFrames == 0;

    AUAudioFrameCount rampLength = event.rampDurationSampleFrames;

    // if (event.rampDurationSampleFrames > 0) {
    // set the ramp duration from the event data
    switch (event.parameterAddress) {
        case AKBoosterParameterLeftGain:
//            data->leftGainRamp.setTarget(event.value, immediate);
//            if (!immediate) {
//                data->leftGainRamp.setDurationInSamples(rampLength);
//            }

//            AUValue value = event.value;
//            if (value < 0) {
//                value = data->leftGainRamp.get();
//            }
            data->leftGainRamp.startRamp(event.value, rampLength);
            break;

        case AKBoosterParameterRightGain:
//            data->rightGainRamp.setTarget(event.value, immediate);
//            if (!immediate) {
//                data->rightGainRamp.setDurationInSamples(rampLength);
//            }

            //clamp(value, 0.0002f, 2.0f)    AUValue value = event.value;
//            if (value < 0) {
//                value = data->rightGainRamp.get();
//            }
            data->rightGainRamp.startRamp(event.value, rampLength);
            break;
    }
    //}
}
