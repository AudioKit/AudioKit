// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include "plumber.h"
#include <string>

enum OperationGeneratorParameter : AUParameterAddress {
    OperationGeneratorParameter1,
    OperationGeneratorParameter2,
    OperationGeneratorParameter3,
    OperationGeneratorParameter4,
    OperationGeneratorParameter5,
    OperationGeneratorParameter6,
    OperationGeneratorParameter7,
    OperationGeneratorParameter8,
    OperationGeneratorParameter9,
    OperationGeneratorParameter10,
    OperationGeneratorParameter11,
    OperationGeneratorParameter12,
    OperationGeneratorParameter13,
    OperationGeneratorParameter14,
    OperationGeneratorTrigger
};

class OperationDSP : public SoundpipeDSPBase {
private:
    plumber_data pd;
    std::string sporthCode;
    ParameterRamper rampers[OperationGeneratorTrigger];

public:
    OperationDSP(bool hasInput = false) : SoundpipeDSPBase(hasInput, !hasInput) {
        for(int i=0;i<OperationGeneratorTrigger;++i) {
            parameters[i] = &rampers[i];
        }
        isStarted = false;
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
                pd.p[OperationGeneratorTrigger] = 1.0;
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
                        pd.p[channel+OperationGeneratorTrigger] = *in;
                    }
                }
            }

            for(int i=0;i<OperationGeneratorTrigger;++i) {
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

            pd.p[OperationGeneratorTrigger] = 0.0;
        }
    }
};

AK_API void akOperationGeneratorSetSporth(DSPRef dspRef, const char *sporth) {
    auto dsp = dynamic_cast<OperationDSP *>(dspRef);
    assert(dsp);
    dsp->setSporth(sporth);
}

struct OperationGeneratorDSP : public OperationDSP {
    OperationGeneratorDSP() : OperationDSP(false) { }
};

AK_REGISTER_DSP(OperationGeneratorDSP, "cstg")
AK_REGISTER_PARAMETER(OperationGeneratorParameter1)
AK_REGISTER_PARAMETER(OperationGeneratorParameter2)
AK_REGISTER_PARAMETER(OperationGeneratorParameter3)
AK_REGISTER_PARAMETER(OperationGeneratorParameter4)
AK_REGISTER_PARAMETER(OperationGeneratorParameter5)
AK_REGISTER_PARAMETER(OperationGeneratorParameter6)
AK_REGISTER_PARAMETER(OperationGeneratorParameter7)
AK_REGISTER_PARAMETER(OperationGeneratorParameter8)
AK_REGISTER_PARAMETER(OperationGeneratorParameter9)
AK_REGISTER_PARAMETER(OperationGeneratorParameter10)
AK_REGISTER_PARAMETER(OperationGeneratorParameter11)
AK_REGISTER_PARAMETER(OperationGeneratorParameter12)
AK_REGISTER_PARAMETER(OperationGeneratorParameter13)
AK_REGISTER_PARAMETER(OperationGeneratorParameter14)
