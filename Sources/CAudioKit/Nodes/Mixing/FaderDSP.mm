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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                }
            }

            float lgain = leftGainRamp.getAndStep();
            float rgain = rightGainRamp.getAndStep();

            if (isStarted) {
                if (channelCount == 2 && mixToMono) {
                    *tmpout[0] = 0.5 * (*tmpin[0] * lgain + *tmpin[1] * rgain);
                    *tmpout[1] = *tmpout[0];
                } else {
                    if (channelCount == 2 && flipStereo) {
                        float leftSaved = *tmpin[0];
                        *tmpout[0] = *tmpin[1] * lgain;
                        *tmpout[1] = leftSaved * rgain;
                    } else {
                        *tmpout[0] = *tmpin[0] * lgain;
                        *tmpout[1] = *tmpin[1] * rgain;
                    }
                }
            }
        }
    }
};

AK_REGISTER_DSP(FaderDSP, "fder")
AK_REGISTER_PARAMETER(FaderParameterLeftGain)
AK_REGISTER_PARAMETER(FaderParameterRightGain)
AK_REGISTER_PARAMETER(FaderParameterFlipStereo)
AK_REGISTER_PARAMETER(FaderParameterMixToMono)
