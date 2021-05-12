// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include <vector>

enum DynamicOscillatorParameter : AUParameterAddress {
    DynamicOscillatorParameterFrequency,
    DynamicOscillatorParameterAmplitude,
    DynamicOscillatorParameterDetuningOffset,
    DynamicOscillatorParameterDetuningMultiplier,
};

struct WavetableInfo {
    sp_ftbl* table;

    ~WavetableInfo() {
        sp_ftbl_destroy(&table);
    }

    /// Is the audio thread done with the wavetable?
    std::atomic<bool> done{false};
};

class DynamicOscillatorDSP : public SoundpipeDSPBase {
private:
    sp_dynamicosc *osc = nullptr;
    std::vector<float> initialWavetable;
    WavetableInfo *oldTable = nullptr;
    WavetableInfo *newTable = nullptr;
    double crossfade = 1.0;
    
    ParameterRamper frequencyRamp;
    ParameterRamper tremoloFrequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

    std::atomic<WavetableInfo*> nextWavetable;
    std::vector<std::unique_ptr<WavetableInfo>> oldTables;

public:
    DynamicOscillatorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[DynamicOscillatorParameterFrequency] = &frequencyRamp;
        parameters[DynamicOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[DynamicOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[DynamicOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
        isStarted = false;
    }

    void collectTables() {

        // Once we find a finished table, all older tables can be released.
        int i;
        for(i=(int)oldTables.size()-1; i>=0; --i) {
            if(oldTables[i]->done)
                break;
        }

        oldTables.erase(oldTables.begin(), oldTables.begin()+i+1);
    }

    void setWavetable(const float* table, size_t length, int index) override {

        if(sp) {
            sendWavetable(table, length);
        } else {
            initialWavetable = std::vector<float>(table, table + length);
        }

    }

    void sendWavetable(const float* table, size_t length) {

        auto info = new WavetableInfo;

        sp_ftbl_create(sp, &info->table, length);
        std::copy(table, table+length, info->table->tbl);

        nextWavetable = info;

        // Store the table for collection later.
        oldTables.push_back(std::unique_ptr<WavetableInfo>(info));

        // Clean up any tables that are done.
        collectTables();

    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);

        sp_dynamicosc_create(&osc);
        sp_dynamicosc_init(sp, osc, 0);

        sendWavetable(initialWavetable.data(), initialWavetable.size());
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_dynamicosc_destroy(&osc);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_dynamicosc_init(sp, osc, 0);
    }

    void updateTables() {

        // Check for new waveforms.
        int32_t bytes;

        auto next = nextWavetable.load();
        if(next != newTable) {
            if(oldTable) { oldTable->done = true; }
            oldTable = newTable;
            if(oldTable) { crossfade = 0; }
            newTable = next;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        updateTables();

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            float frequency = frequencyRamp.getAndStep();
            float detuneMultiplier = detuningMultiplierRamp.getAndStep();
            float detuneOffset = detuningOffsetRamp.getAndStep();
            osc->freq = frequency * detuneMultiplier + detuneOffset;
            osc->amp = amplitudeRamp.getAndStep();

            if(isStarted) {
                crossfade += 0.005;
                if(crossfade > 1) { crossfade = 1; }

                float temp1 = 0;
                float temp2 = 0;

                if(oldTable) {
                    sp_dynamicosc_compute(sp, osc, oldTable->table, nil, &temp1, false); // does not move phase
                }

                if(newTable) {
                    sp_dynamicosc_compute(sp, osc, newTable->table, nil, &temp2, true); // does move phase
                }

                for (int channel = 0; channel < channelCount; ++channel) {
                    float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                    *out = temp1 * (1-crossfade) + temp2 * crossfade;
                }
            } else {
                for (int channel = 0; channel < channelCount; ++channel) {
                    float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                    *out = 0.0;
                }
            }
        }
    }
    
};

AK_REGISTER_DSP(DynamicOscillatorDSP, "csto")
AK_REGISTER_PARAMETER(DynamicOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(DynamicOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(DynamicOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(DynamicOscillatorParameterDetuningMultiplier)
