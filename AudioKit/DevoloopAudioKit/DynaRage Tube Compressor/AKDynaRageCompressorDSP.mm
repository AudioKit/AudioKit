// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDynaRageCompressorDSP.hpp"
#import <AudioKit/AKDSPBase.hpp>

#include "Compressor.h"
#include "RageProcessor.h"
#include "ParameterRamper.hpp"

class AKDynaRageCompressorDSP : public AKDSPBase {
private:
    std::unique_ptr<Compressor> left_compressor;
    std::unique_ptr<Compressor> right_compressor;

    std::unique_ptr<RageProcessor> left_rageprocessor;
    std::unique_ptr<RageProcessor> right_rageprocessor;
    
    ParameterRamper ratioRamp;
    ParameterRamper thresholdRamp;
    ParameterRamper attackRamp;
    ParameterRamper releaseRamp;
    ParameterRamper rageRamp;
    
    bool rageIsOn = true;

public:
    AKDynaRageCompressorDSP() {
        parameters[AKDynaRageCompressorParameterRatio] = &ratioRamp;
        parameters[AKDynaRageCompressorParameterThreshold] = &thresholdRamp;
        parameters[AKDynaRageCompressorParameterAttack] = &attackRamp;
        parameters[AKDynaRageCompressorParameterRelease] = &releaseRamp;
        parameters[AKDynaRageCompressorParameterRageAmount] = &rageRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKDSPBase::init(channelCount, sampleRate);

        float ratio = ratioRamp.get();
        float threshold = thresholdRamp.get();
        float attack = attackRamp.get();
        float release = releaseRamp.get();

        left_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
        right_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);

        left_rageprocessor = std::make_unique<RageProcessor>((int)sampleRate);
        right_rageprocessor = std::make_unique<RageProcessor>((int)sampleRate);
    }

    void deinit() {
        left_compressor.reset();
        right_compressor.reset();
        left_rageprocessor.reset();
        right_rageprocessor.reset();
    }

    void reset() {
        float ratio = ratioRamp.get();
        float threshold = thresholdRamp.get();
        float attack = attackRamp.get();
        float release = releaseRamp.get();

        left_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
        right_compressor = std::make_unique<Compressor>(threshold, ratio, attack, release, (int) sampleRate);
    }

    void setParameter(AUParameterAddress address, float value, bool immediate)
    {
        if (address == AKDynaRageCompressorParameterRageEnabled) {
            rageIsOn = value > 0.5f;
        }
        else {
            AKDSPBase::setParameter(address, value, immediate);
        }
    }

    float getParameter(AUParameterAddress address)
    {
        if (address == AKDynaRageCompressorParameterRageEnabled) {
            return rageIsOn ? 1.f : 0.f;
        }
        else {
            return AKDSPBase::getParameter(address);
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float ratio = ratioRamp.getAndStep();
            float threshold = thresholdRamp.getAndStep();
            float attack = attackRamp.getAndStep();
            float release = releaseRamp.getAndStep();
            float rage = rageRamp.getAndStep();

            left_compressor->setParameters(threshold, ratio, attack, release);
            right_compressor->setParameters(threshold, ratio, attack, release);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {

                        float rageSignal = left_rageprocessor->doRage(*in, rage, rage);
                        float compSignal = left_compressor->Process((bool)rageIsOn ? rageSignal : *in, false, 1);
                        *out = compSignal;
                    } else {
                        float rageSignal = right_rageprocessor->doRage(*in, rage, rage);
                        float compSignal = right_compressor->Process((bool)rageIsOn ? rageSignal : *in, false, 1);
                        *out = compSignal;
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }
};

extern "C" AKDSPRef createDynaRageCompressorDSP() {
    return new AKDynaRageCompressorDSP();
}
