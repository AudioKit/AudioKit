// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DSPBase.h"

#include "Compressor.h"
#include "RageProcessor.h"
#include "ParameterRamper.h"

enum DynaRageCompressorParameter : AUParameterAddress {
    DynaRageCompressorParameterRatio,
    DynaRageCompressorParameterThreshold,
    DynaRageCompressorParameterAttackDuration,
    DynaRageCompressorParameterReleaseDuration,
    DynaRageCompressorParameterRage,
    DynaRageCompressorParameterRageEnabled
};

class DynaRageCompressorDSP : public DSPBase {
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
    DynaRageCompressorDSP() {
        parameters[DynaRageCompressorParameterRatio] = &ratioRamp;
        parameters[DynaRageCompressorParameterThreshold] = &thresholdRamp;
        parameters[DynaRageCompressorParameterAttackDuration] = &attackDurationRamp;
        parameters[DynaRageCompressorParameterReleaseDuration] = &releaseDurationRamp;
        parameters[DynaRageCompressorParameterRage] = &rageRamp;
    }

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

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
        if (address == DynaRageCompressorParameterRageEnabled) {
            rageIsOn = value > 0.5f;
        }
        else {
            DSPBase::setParameter(address, value, immediate);
        }
    }

    float getParameter(AUParameterAddress address) override {
        if (address == DynaRageCompressorParameterRageEnabled) {
            return rageIsOn ? 1.f : 0.f;
        }
        else {
            return DSPBase::getParameter(address);
        }
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float ratio = ratioRamp.getAndStep();
            float threshold = thresholdRamp.getAndStep();
            float attackDuration = attackDurationRamp.getAndStep();
            float releaseDuration = releaseDurationRamp.getAndStep();
            float rage = rageRamp.getAndStep();

            left_compressor->setParameters(threshold, ratio, attackDuration, releaseDuration);
            right_compressor->setParameters(threshold, ratio, attackDuration, releaseDuration);
            
            float leftRageSignal = left_rageprocessor->doRage(inputSample(0, i), rage, rage);
            outputSample(0, i) = left_compressor->Process((bool)rageIsOn ? leftRageSignal : inputSample(0, i), false, 1);
            float rightRageSignal = right_rageprocessor->doRage(inputSample(1, i), rage, rage);
            outputSample(1, i) = right_compressor->Process((bool)rageIsOn ? rightRageSignal : inputSample(1, i), false, 1);
        }
    }
};

AK_REGISTER_DSP(DynaRageCompressorDSP, "dyrc")
AK_REGISTER_PARAMETER(DynaRageCompressorParameterRatio)
AK_REGISTER_PARAMETER(DynaRageCompressorParameterThreshold)
AK_REGISTER_PARAMETER(DynaRageCompressorParameterAttackDuration)
AK_REGISTER_PARAMETER(DynaRageCompressorParameterReleaseDuration)
AK_REGISTER_PARAMETER(DynaRageCompressorParameterRage)
AK_REGISTER_PARAMETER(DynaRageCompressorParameterRageEnabled)
