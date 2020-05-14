// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDynaRageCompressorDSP.hpp"

#include "Compressor.h"
#include "RageProcessor.h"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createDynaRageCompressorDSP() {
    return new AKDynaRageCompressorDSP();
}

struct AKDynaRageCompressorDSP::InternalData {
    std::unique_ptr<Compressor> left_compressor;
    std::unique_ptr<Compressor> right_compressor;

    std::unique_ptr<RageProcessor> left_rageprocessor;
    std::unique_ptr<RageProcessor> right_rageprocessor;
    
    AKLinearParameterRamp ratioRamp;
    AKLinearParameterRamp thresholdRamp;
    AKLinearParameterRamp attackRamp;
    AKLinearParameterRamp releaseRamp;
    AKLinearParameterRamp rageRamp;
    
    bool rageIsOn = true;
};

AKDynaRageCompressorDSP::AKDynaRageCompressorDSP() : data(new InternalData) {
    parameters[AKDynaRageCompressorParameterRatio] = &data->ratioRamp;
    parameters[AKDynaRageCompressorParameterThreshold] = &data->thresholdRamp;
    parameters[AKDynaRageCompressorParameterAttack] = &data->attackRamp;
    parameters[AKDynaRageCompressorParameterRelease] = &data->releaseRamp;
    parameters[AKDynaRageCompressorParameterRageAmount] = &data->rageRamp;
}

void AKDynaRageCompressorDSP::init(int channelCount, double sampleRate) {
    AKDSPBase::init(channelCount, sampleRate);
    
    float ratio = data->ratioRamp.getValue();
    float threshold = data->thresholdRamp.getValue();
    float attack = data->attackRamp.getValue();
    float release = data->releaseRamp.getValue();
    
    data->left_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
    data->right_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
    
    data->left_rageprocessor = std::make_unique<RageProcessor>((int)sampleRate);
    data->right_rageprocessor = std::make_unique<RageProcessor>((int)sampleRate);
}

void AKDynaRageCompressorDSP::deinit() {
    data->left_compressor.reset();
    data->right_compressor.reset();
    data->left_rageprocessor.reset();
    data->right_rageprocessor.reset();
}

void AKDynaRageCompressorDSP::reset() {
    float ratio = data->ratioRamp.getValue();
    float threshold = data->thresholdRamp.getValue();
    float attack = data->attackRamp.getValue();
    float release = data->releaseRamp.getValue();
    
    data->left_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
    data->right_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
}

void AKDynaRageCompressorDSP::setParameter(AUParameterAddress address, float value, bool immediate)
{
    if (address == AKDynaRageCompressorParameterRageEnabled) {
        data->rageIsOn = value > 0.5f;
    }
    else {
        AKDSPBase::setParameter(address, value, immediate);
    }
}

float AKDynaRageCompressorDSP::getParameter(AUParameterAddress address)
{
    if (address == AKDynaRageCompressorParameterRageEnabled) {
        return data->rageIsOn ? 1.f : 0.f;
    }
    else {
        return AKDSPBase::getParameter(address);
    }
}

void AKDynaRageCompressorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->ratioRamp.advanceTo(now + frameOffset);
            data->thresholdRamp.advanceTo(now + frameOffset);
            data->attackRamp.advanceTo(now + frameOffset);
            data->releaseRamp.advanceTo(now + frameOffset);
            data->rageRamp.advanceTo(now + frameOffset);
        }
        
        float ratio = data->ratioRamp.getValue();
        float threshold = data->thresholdRamp.getValue();
        float attack = data->attackRamp.getValue();
        float release = data->releaseRamp.getValue();
        float rage = data->rageRamp.getValue();

        data->left_compressor->setParameters(threshold, ratio, attack, release);
        data->right_compressor->setParameters(threshold, ratio, attack, release);

        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {

                    float rageSignal = data->left_rageprocessor->doRage(*in, rage, rage);
                    float compSignal = data->left_compressor->Process((bool)data->rageIsOn ? rageSignal : *in, false, 1);
                    *out = compSignal;
                } else {
                    float rageSignal = data->right_rageprocessor->doRage(*in, rage, rage);
                    float compSignal = data->right_compressor->Process((bool)data->rageIsOn ? rageSignal : *in, false, 1);
                    *out = compSignal;
                }
            } else {
                *out = *in;
            }
        }
    }
}
