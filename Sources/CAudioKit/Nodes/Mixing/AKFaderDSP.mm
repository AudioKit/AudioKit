// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDSPBase.hpp"
#include "ParameterRamper.hpp"

enum AKFaderParameter : AUParameterAddress {
    AKFaderParameterLeftGain,
    AKFaderParameterRightGain,
    AKFaderParameterFlipStereo,
    AKFaderParameterMixToMono
};


struct AKFaderDSP : AKDSPBase {
private:
    ParameterRamper leftGainRamp{1.0};
    ParameterRamper rightGainRamp{1.0};
    bool flipStereo = false;
    bool mixToMono = false;

public:
    AKFaderDSP() {
        parameters[AKFaderParameterLeftGain] = &leftGainRamp;
        parameters[AKFaderParameterRightGain] = &rightGainRamp;

        bCanProcessInPlace = true;
    }

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        switch (address) {
            case AKFaderParameterFlipStereo:
                flipStereo = value > 0.5f;
                break;
            case AKFaderParameterMixToMono:
                mixToMono = value > 0.5f;
                break;
            default:
                AKDSPBase::setParameter(address, value, immediate);
        }
    }

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKFaderParameterFlipStereo:
                return flipStereo ? 1.f : 0.f;
            case AKFaderParameterMixToMono:
                return mixToMono ? 1.f : 0.f;
            default:
                return AKDSPBase::getParameter(address);
        }
    }

    void startRamp(const AUParameterEvent &event) override {
        auto address = event.parameterAddress;
        switch (address) {
            case AKFaderParameterFlipStereo:
                flipStereo = event.value > 0.5f;
                break;
            case AKFaderParameterMixToMono:
                mixToMono = event.value > 0.5f;
                break;
            default:
                AKDSPBase::startRamp(event);
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
            if (isStarted) {
                if (channelCount == 2 && mixToMono) {
                    *tmpout[0] = 0.5 * (*tmpin[0] * leftGainRamp.getAndStep() + *tmpin[1] * rightGainRamp.getAndStep());
                    *tmpout[1] = *tmpout[0];
                } else {
                    if (channelCount == 2 && flipStereo) {
                        float leftSaved = *tmpin[0];
                        *tmpout[0] = *tmpin[1] * leftGainRamp.getAndStep();
                        *tmpout[1] = leftSaved * rightGainRamp.getAndStep();
                    } else {
                        *tmpout[0] = *tmpin[0] * leftGainRamp.getAndStep();
                        *tmpout[1] = *tmpin[1] * rightGainRamp.getAndStep();
                    }
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKFaderDSP)
AK_REGISTER_PARAMETER(AKFaderParameterLeftGain)
AK_REGISTER_PARAMETER(AKFaderParameterRightGain)
AK_REGISTER_PARAMETER(AKFaderParameterFlipStereo)
AK_REGISTER_PARAMETER(AKFaderParameterMixToMono)
