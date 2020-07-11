// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKVocalTractDSP.hpp"

extern "C" AKDSPRef createVocalTractDSP() {
    return new AKVocalTractDSP();
}

AKVocalTractDSP::AKVocalTractDSP() {
    parameters[AKVocalTractParameterFrequency] = &frequencyRamp;
    parameters[AKVocalTractParameterTonguePosition] = &tonguePositionRamp;
    parameters[AKVocalTractParameterTongueDiameter] = &tongueDiameterRamp;
    parameters[AKVocalTractParameterTenseness] = &tensenessRamp;
    parameters[AKVocalTractParameterNasality] = &nasalityRamp;
}

void AKVocalTractDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);

    sp_vocwrapper_create(&vocwrapper);
    sp_vocwrapper_init(sp, vocwrapper);
    vocwrapper->freq = 160.0;
    vocwrapper->pos = 0.5;
    vocwrapper->diam = 1.0;
    vocwrapper->tenseness = 0.6;
    vocwrapper->nasal = 0.0;

    isStarted = false;
}

void AKVocalTractDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_vocwrapper_destroy(&vocwrapper);
}


void AKVocalTractDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float frequency = frequencyRamp.getAndStep();
        float tonguePosition = tonguePositionRamp.getAndStep();
        float tongueDiameter = tongueDiameterRamp.getAndStep();
        float tenseness = tensenessRamp.getAndStep();
        float nasality = nasalityRamp.getAndStep();
        vocwrapper->freq = frequency;
        vocwrapper->pos = tonguePosition;
        vocwrapper->diam = tongueDiameter;
        vocwrapper->tenseness = tenseness;
        vocwrapper->nasal = nasality;

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_vocwrapper_compute(sp, vocwrapper, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
