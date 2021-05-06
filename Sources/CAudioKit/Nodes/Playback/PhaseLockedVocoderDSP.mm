// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include <vector>

enum PhaseLockedVocoderParameter : AUParameterAddress {
    PhaseLockedVocoderParameterPosition,
    PhaseLockedVocoderParameterAmplitude,
    PhaseLockedVocoderParameterPitchRatio,
};

class PhaseLockedVocoderDSP : public SoundpipeDSPBase {
private:
    sp_mincer *mincer;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;

    ParameterRamper positionRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper pitchRatioRamp;

public:
    PhaseLockedVocoderDSP() {
        parameters[PhaseLockedVocoderParameterPosition] = &positionRamp;
        parameters[PhaseLockedVocoderParameterAmplitude] = &amplitudeRamp;
        parameters[PhaseLockedVocoderParameterPitchRatio] = &pitchRatioRamp;
    }

    void setWavetable(const float *table, size_t length, int index) override {
        wavetable = std::vector<float>(table, table + length);
        if (!isInitialized) return;
        sp_ftbl_destroy(&ftbl);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        sp_mincer_create(&mincer);
        sp_mincer_init(sp, mincer, ftbl, 2048);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_ftbl_destroy(&ftbl);
        sp_mincer_destroy(&mincer);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_mincer_init(sp, mincer, ftbl, 2048);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            mincer->time = positionRamp.getAndStep();
            mincer->amp = amplitudeRamp.getAndStep();
            mincer->pitch = pitchRatioRamp.getAndStep();

            float *outL = (float *)outputBufferList->mBuffers[0].mData  + frameOffset;
            float *outR = (float *)outputBufferList->mBuffers[1].mData + frameOffset;
            if (isStarted) {
                sp_mincer_compute(sp, mincer, NULL, outL);
                *outR = *outL;
            } else {
                *outL = 0;
                *outR = 0;
            }
        }
    }
};

AK_REGISTER_DSP(PhaseLockedVocoderDSP, "minc")
AK_REGISTER_PARAMETER(PhaseLockedVocoderParameterPosition)
AK_REGISTER_PARAMETER(PhaseLockedVocoderParameterAmplitude)
AK_REGISTER_PARAMETER(PhaseLockedVocoderParameterPitchRatio)
