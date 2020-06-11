// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKFaderDSP.hpp"
#import "ParameterRamper.hpp"

extern "C" AKDSPRef createFaderDSP()
{
    return new AKFaderDSP();
}

struct AKFaderDSP::InternalData {
    ParameterRamper leftGainRamp = 1.0;
    ParameterRamper rightGainRamp = 1.0;
    bool flipStereo = false;
    bool mixToMono = false;
};

AKFaderDSP::AKFaderDSP() : data(new InternalData)
{
    parameters[AKFaderParameterLeftGain] = &data->leftGainRamp;
    parameters[AKFaderParameterRightGain] = &data->rightGainRamp;
    
    bCanProcessInPlace = true;
}

// Uses the ParameterAddress as a key
void AKFaderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate)
{
    switch (address) {
        case AKFaderParameterFlipStereo:
            data->flipStereo = value > 0.5f;
            break;
        case AKFaderParameterMixToMono:
            data->mixToMono = value > 0.5f;
            break;
        default:
            AKDSPBase::setParameter(address, value, immediate);
    }
}

// Uses the ParameterAddress as a key
float AKFaderDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKFaderParameterFlipStereo:
            return data->flipStereo ? 1.f : 0.f;
        case AKFaderParameterMixToMono:
            return data->mixToMono ? 1.f : 0.f;
        default:
            return AKDSPBase::getParameter(address);
    }
}

void AKFaderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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
                    float leftSaved = *tmpin[0];
                    *tmpout[0] = *tmpin[1] * data->leftGainRamp.getAndStep();
                    *tmpout[1] = leftSaved * data->rightGainRamp.getAndStep();
                } else {
                    *tmpout[0] = *tmpin[0] * data->leftGainRamp.getAndStep();
                    *tmpout[1] = *tmpin[1] * data->rightGainRamp.getAndStep();
                }
            }
        }
    }
}

//void AKFaderDSP::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration)
//{
//    // Note, if duration is 0 frames, startRamp will setImmediate
//    switch (address) {
//        case AKFaderParameterLeftGain:
//            data->leftGainRamp.startRamp(value, duration);
//            break;
//        case AKFaderParameterRightGain:
//            data->rightGainRamp.startRamp(value, duration);
//            break;
//        case AKFaderParameterTaper:
//            data->leftGainRamp.setTaper(value);
//            data->rightGainRamp.setTaper(value);
//            break;
//        case AKFaderParameterSkew:
//            data->leftGainRamp.setSkew(value);
//            data->rightGainRamp.setSkew(value);
//            break;
//        case AKFaderParameterOffset:
//            data->leftGainRamp.setOffset(value);
//            data->rightGainRamp.setOffset(value);
//            break;
//    }
//}
