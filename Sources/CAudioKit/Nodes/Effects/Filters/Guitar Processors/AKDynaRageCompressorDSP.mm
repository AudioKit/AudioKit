// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDSPBase.hpp"

#include "Compressor.h"
#include "RageProcessor.h"
#include "ParameterRamper.hpp"

enum AKDynaRageCompressorParameter : AUParameterAddress {
    AKDynaRageCompressorParameterRatio,
    AKDynaRageCompressorParameterThreshold,
    AKDynaRageCompressorParameterAttackDuration,
    AKDynaRageCompressorParameterReleaseDuration,
    AKDynaRageCompressorParameterRage,
    AKDynaRageCompressorParameterRageEnabled
};

class AKDynaRageCompressorDSP : public AKDSPBase {
private:
    std::unique_ptr<Compressor> left_compressor;
    std::unique_ptr<Compressor> right_compressor;

    std::unique_ptr<RageProcessor> left_rageprocessor;
    std::unique_ptr<RageProcessor> right_rageprocessor;
    
    ParameterRamper ratioRamp;
    ParameterRamper thresholdRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper releaseDurationRamp;
    ParameterRamper rageRamp;
    
    bool rageIsOn = true;

public:
    AKDynaRageCompressorDSP() {
        parameters[AKDynaRageCompressorParameterRatio] = &ratioRamp;
        parameters[AKDynaRageCompressorParameterThreshold] = &thresholdRamp;
        parameters[AKDynaRageCompressorParameterAttackDuration] = &attackDurationRamp;
        parameters[AKDynaRageCompressorParameterReleaseDuration] = &releaseDurationRamp;
        parameters[AKDynaRageCompressorParameterRage] = &rageRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        float ratio = ratioRamp.get();
        float threshold = thresholdRamp.get();
        float attackDuration = attackDurationRamp.get();
        float releaseDuration = releaseDurationRamp.get();

        left_compressor = std::make_unique<Compressor>(threshold, ratio, attackDuration, releaseDuration, (int)sampleRate);
        right_compressor = std::make_unique<Compressor>(threshold, ratio, attackDuration, releaseDuration, (int)sampleRate);

        left_rageprocessor = std::make_unique<RageProcessor>((int)sampleRate);
        right_rageprocessor = std::make_unique<RageProcessor>((int)sampleRate);
    }

    void deinit() override {
        left_compressor.reset();
        right_compressor.reset();
        left_rageprocessor.reset();
        right_rageprocessor.reset();
    }

    void reset() override {
        float ratio = ratioRamp.get();
        float threshold = thresholdRamp.get();
        float attackDuration = attackDurationRamp.get();
        float releaseDuration = releaseDurationRamp.get();

        left_compressor = std::make_unique<Compressor>(threshold, ratio, attackDuration, releaseDuration, (int)sampleRate);
        right_compressor = std::make_unique<Compressor>(threshold, ratio, attackDuration, releaseDuration, (int)sampleRate);
    }

    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        if (address == AKDynaRageCompressorParameterRageEnabled) {
            rageIsOn = value > 0.5f;
        }
        else {
            AKDSPBase::setParameter(address, value, immediate);
        }
    }

    float getParameter(AUParameterAddress address) override {
        if (address == AKDynaRageCompressorParameterRageEnabled) {
            return rageIsOn ? 1.f : 0.f;
        }
        else {
            return AKDSPBase::getParameter(address);
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float ratio = ratioRamp.getAndStep();
            float threshold = thresholdRamp.getAndStep();
            float attackDuration = attackDurationRamp.getAndStep();
            float releaseDuration = releaseDurationRamp.getAndStep();
            float rage = rageRamp.getAndStep();

            left_compressor->setParameters(threshold, ratio, attackDuration, releaseDuration);
            right_compressor->setParameters(threshold, ratio, attackDuration, releaseDuration);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

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

AK_REGISTER_DSP(AKDynaRageCompressorDSP)
AK_REGISTER_PARAMETER(AKDynaRageCompressorParameterRatio)
AK_REGISTER_PARAMETER(AKDynaRageCompressorParameterThreshold)
AK_REGISTER_PARAMETER(AKDynaRageCompressorParameterAttackDuration)
AK_REGISTER_PARAMETER(AKDynaRageCompressorParameterReleaseDuration)
AK_REGISTER_PARAMETER(AKDynaRageCompressorParameterRage)
AK_REGISTER_PARAMETER(AKDynaRageCompressorParameterRageEnabled)
