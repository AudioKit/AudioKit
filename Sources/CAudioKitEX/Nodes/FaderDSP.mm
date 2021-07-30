// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DSPBase.h"
#include "ParameterRamper.h"

enum FaderParameter : AUParameterAddress {
    FaderParameterLeftGain,
    FaderParameterRightGain,
    FaderParameterFlipStereo,
    FaderParameterMixToMono
};


struct FaderDSP : DSPBase {
private:
    ParameterRamper leftGainRamp{1.0};
    ParameterRamper rightGainRamp{1.0};
    bool flipStereo = false;
    bool mixToMono = false;

public:
    FaderDSP() : DSPBase(1, true) {
        parameters[FaderParameterLeftGain] = &leftGainRamp;
        parameters[FaderParameterRightGain] = &rightGainRamp;
    }

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        switch (address) {
            case FaderParameterFlipStereo:
                flipStereo = value > 0.5f;
                break;
            case FaderParameterMixToMono:
                mixToMono = value > 0.5f;
                break;
            default:
                DSPBase::setParameter(address, value, immediate);
        }
    }

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case FaderParameterFlipStereo:
                return flipStereo ? 1.f : 0.f;
            case FaderParameterMixToMono:
                return mixToMono ? 1.f : 0.f;
            default:
                return DSPBase::getParameter(address);
        }
    }

    void startRamp(const AUParameterEvent &event) override {
        auto address = event.parameterAddress;
        switch (address) {
            case FaderParameterFlipStereo:
                flipStereo = event.value > 0.5f;
                break;
            case FaderParameterMixToMono:
                mixToMono = event.value > 0.5f;
                break;
            default:
                DSPBase::startRamp(event);
        }
    }

    void process(FrameRange range) override {
        for (auto i : range) {

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float& leftOut = outputSample(0, i);
            float& rightOut = outputSample(1, i);

            float leftGain = leftGainRamp.getAndStep();
            float rightGain = rightGainRamp.getAndStep();

            if (mixToMono) {
                leftOut = rightOut = 0.5 * (leftIn * leftGain + rightIn * rightGain);
            } else {

                if (flipStereo) {
                    std::swap(leftIn, rightIn);
                }

                leftOut = leftIn * leftGain;
                rightOut = rightIn * rightGain;

            }
        }
    }
};

AK_REGISTER_DSP(FaderDSP, "fder")
AK_REGISTER_PARAMETER(FaderParameterLeftGain)
AK_REGISTER_PARAMETER(FaderParameterRightGain)
AK_REGISTER_PARAMETER(FaderParameterFlipStereo)
AK_REGISTER_PARAMETER(FaderParameterMixToMono)
