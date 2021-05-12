// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include "plumber.h"
#include <string>

enum OperationParameter : AUParameterAddress {
    OperationParameter1,
    OperationParameter2,
    OperationParameter3,
    OperationParameter4,
    OperationParameter5,
    OperationParameter6,
    OperationParameter7,
    OperationParameter8,
    OperationParameter9,
    OperationParameter10,
    OperationParameter11,
    OperationParameter12,
    OperationParameter13,
    OperationParameter14,
    OperationTrigger
};

class OperationDSP : public SoundpipeDSPBase {
private:
    plumber_data pd;
    std::string sporthCode;
    ParameterRamper rampers[OperationTrigger];

public:
    OperationDSP(bool hasInput = false) : SoundpipeDSPBase(hasInput, /*canProcessInPlace*/!hasInput) {
        for(int i=0;i<OperationTrigger;++i) {
            parameters[i] = &rampers[i];
        }
        isStarted = hasInput;
    }

    void setSporth(const char *sporth) {
        sporthCode = sporth;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        plumber_register(&pd);
        plumber_init(&pd);

        pd.sp = sp;
        if (!sporthCode.empty()) {
            plumber_parse_string(&pd, sporthCode.c_str());
            plumber_compute(&pd, PLUMBER_INIT);
        }
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        plumber_clean(&pd);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        plumber_init(&pd);

        pd.sp = sp;
        if (!sporthCode.empty()) {
            plumber_parse_string(&pd, sporthCode.c_str());
            plumber_compute(&pd, PLUMBER_INIT);
        }
    }

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if(!inputBufferLists.empty()) {
            uint8_t status = midiEvent.data[0] & 0xF0;
            if(status == 0x90) { // note on
                pd.p[OperationTrigger] = 1.0;
            }
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            if(!inputBufferLists.empty()) {
                for (int channel = 0; channel < channelCount; ++channel) {
                    float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                    if (channel < 2) {
                        pd.p[channel+OperationTrigger] = *in;
                    }
                }
            }

            for(int i=0;i<OperationTrigger;++i) {
                pd.p[i] = rampers[i].getAndStep();
            }

            if (isStarted)
                plumber_compute(&pd, PLUMBER_COMPUTE);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                if (isStarted) {
                    *out = sporth_stack_pop_float(&pd.sporth.stack);
                } else {
                    *out = 0;
                }
            }

            pd.p[OperationTrigger] = 0.0;
        }
    }
};

AK_API void akOperationSetSporth(DSPRef dspRef, const char *sporth) {
    auto dsp = dynamic_cast<OperationDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth);
}

struct OperationGeneratorDSP : public OperationDSP {
    OperationGeneratorDSP() : OperationDSP(/*hasInput*/false) { }
};

struct OperationEffectDSP : public OperationDSP {
    OperationEffectDSP() : OperationDSP(/*hasInput*/true) { }
};

AK_REGISTER_DSP(OperationGeneratorDSP, "cstg")
AK_REGISTER_DSP(OperationEffectDSP, "cstm")
AK_REGISTER_PARAMETER(OperationParameter1)
AK_REGISTER_PARAMETER(OperationParameter2)
AK_REGISTER_PARAMETER(OperationParameter3)
AK_REGISTER_PARAMETER(OperationParameter4)
AK_REGISTER_PARAMETER(OperationParameter5)
AK_REGISTER_PARAMETER(OperationParameter6)
AK_REGISTER_PARAMETER(OperationParameter7)
AK_REGISTER_PARAMETER(OperationParameter8)
AK_REGISTER_PARAMETER(OperationParameter9)
AK_REGISTER_PARAMETER(OperationParameter10)
AK_REGISTER_PARAMETER(OperationParameter11)
AK_REGISTER_PARAMETER(OperationParameter12)
AK_REGISTER_PARAMETER(OperationParameter13)
AK_REGISTER_PARAMETER(OperationParameter14)
