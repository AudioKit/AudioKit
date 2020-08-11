// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSamplerDSP.hpp"
#include "wavpack.h"
#include <math.h>

AKDSPRef akAKSamplerCreateDSP() {
    return new AKSamplerDSP();
}

void akSamplerLoadData(AKDSPRef pDSP, AKSampleDataDescriptor *pSDD) {
    ((AKSamplerDSP*)pDSP)->loadSampleData(*pSDD);
}

void akSamplerLoadCompressedFile(AKDSPRef pDSP, AKSampleFileDescriptor *pSFD)
{
    char errMsg[100];
    WavpackContext *wpc = WavpackOpenFileInput(pSFD->path, errMsg, OPEN_2CH_MAX, 0);
    if (wpc == 0)
    {
        printf("Wavpack error loading %s: %s\n", pSFD->path, errMsg);
        return;
    }

    AKSampleDataDescriptor sdd;
    sdd.sampleDescriptor = pSFD->sampleDescriptor;
    sdd.sampleRate = (float)WavpackGetSampleRate(wpc);
    sdd.channelCount = WavpackGetReducedChannels(wpc);
    sdd.sampleCount = WavpackGetNumSamples(wpc);
    sdd.isInterleaved = sdd.channelCount > 1;
    sdd.data = new float[sdd.channelCount * sdd.sampleCount];

    int mode = WavpackGetMode(wpc);
    WavpackUnpackSamples(wpc, (int32_t*)sdd.data, sdd.sampleCount);
    if ((mode & MODE_FLOAT) == 0)
    {
        // convert samples to floating-point
        int bps = WavpackGetBitsPerSample(wpc);
        float scale = 1.0f / (1 << (bps - 1));
        float *pf = sdd.data;
        int32_t *pi = (int32_t*)pf;
        for (int i = 0; i < (sdd.sampleCount * sdd.channelCount); i++)
            *pf++ = scale * *pi++;
    }
    WavpackCloseFile(wpc);

    ((AKSamplerDSP*)pDSP)->loadSampleData(sdd);
    delete[] sdd.data;
}

void akSamplerUnloadAllSamples(AKDSPRef pDSP)
{
    ((AKSamplerDSP*)pDSP)->unloadAllSamples();
}

void akSamplerSetNoteFrequency(AKDSPRef pDSP, int noteNumber, float noteFrequency)
{
    ((AKSamplerDSP*)pDSP)->setNoteFrequency(noteNumber, noteFrequency);
}

void akSamplerBuildSimpleKeyMap(AKDSPRef pDSP) {
    ((AKSamplerDSP*)pDSP)->buildSimpleKeyMap();
}

void akSamplerBuildKeyMap(AKDSPRef pDSP) {
    ((AKSamplerDSP*)pDSP)->buildKeyMap();
}

void akSamplerSetLoopThruRelease(AKDSPRef pDSP, bool value) {
    ((AKSamplerDSP*)pDSP)->setLoopThruRelease(value);
}

void akSamplerPlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity)
{
    ((AKSamplerDSP*)pDSP)->playNote(noteNumber, velocity);
}

void akSamplerStopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate)
{
    ((AKSamplerDSP*)pDSP)->stopNote(noteNumber, immediate);
}

void akSamplerStopAllVoices(AKDSPRef pDSP)
{
    ((AKSamplerDSP*)pDSP)->stopAllVoices();
}

void akSamplerRestartVoices(AKDSPRef pDSP)
{
    ((AKSamplerDSP*)pDSP)->restartVoices();
}

void akSamplerSustainPedal(AKDSPRef pDSP, bool pedalDown)
{
    ((AKSamplerDSP*)pDSP)->sustainPedal(pedalDown);
}


AKSamplerDSP::AKSamplerDSP() : AKCoreSampler()
{
    masterVolumeRamp.setTarget(1.0, true);
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
    vibratoFrequencyRamp.setTarget(5.0, true);
    voiceVibratoDepthRamp.setTarget(0.0, true);
    voiceVibratoFrequencyRamp.setTarget(5.0, true);
    filterCutoffRamp.setTarget(4, true);
    filterStrengthRamp.setTarget(20.0f, true);
    filterResonanceRamp.setTarget(1.0, true);
    pitchADSRSemitonesRamp.setTarget(1.0, true);
    glideRateRamp.setTarget(0.0, true);
}

void AKSamplerDSP::init(int channelCount, double sampleRate)
{
    AKDSPBase::init(channelCount, sampleRate);
    AKCoreSampler::init(sampleRate);
}

void AKSamplerDSP::deinit()
{
    AKDSPBase::deinit();
    AKCoreSampler::deinit();
}

void AKSamplerDSP::setParameter(AUParameterAddress address, float value, bool immediate)
{
    switch (address) {
        case AKSamplerParameterRampDuration:
            masterVolumeRamp.setRampDuration(value, sampleRate);
            pitchBendRamp.setRampDuration(value, sampleRate);
            vibratoDepthRamp.setRampDuration(value, sampleRate);
            vibratoFrequencyRamp.setRampDuration(value, sampleRate);
            voiceVibratoDepthRamp.setRampDuration(value, sampleRate);
            voiceVibratoFrequencyRamp.setRampDuration(value, sampleRate);
            filterCutoffRamp.setRampDuration(value, sampleRate);
            filterStrengthRamp.setRampDuration(value, sampleRate);
            filterResonanceRamp.setRampDuration(value, sampleRate);
            pitchADSRSemitonesRamp.setRampDuration(value, sampleRate);
            glideRateRamp.setRampDuration(value, sampleRate);
            break;

        case AKSamplerParameterMasterVolume:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterPitchBend:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterVibratoDepth:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterVibratoFrequency:
            vibratoFrequencyRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterVoiceVibratoDepth:
            voiceVibratoDepthRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterVoiceVibratoFrequency:
            voiceVibratoFrequencyRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterFilterCutoff:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterFilterStrength:
            filterStrengthRamp.setTarget(value, immediate);
            break;
        case AKSamplerParameterFilterResonance:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;
        case AKSamplerParameterGlideRate:
            glideRateRamp.setTarget(value, immediate);
            break;

        case AKSamplerParameterAttackDuration:
            setADSRAttackDurationSeconds(value);
            break;
        case AKSamplerParameterHoldDuration:
            setADSRHoldDurationSeconds(value);
            break;
        case AKSamplerParameterDecayDuration:
            setADSRDecayDurationSeconds(value);
            break;
        case AKSamplerParameterSustainLevel:
            setADSRSustainFraction(value);
            break;
        case AKSamplerParameterReleaseHoldDuration:
            setADSRReleaseHoldDurationSeconds(value);
            break;
        case AKSamplerParameterReleaseDuration:
            setADSRReleaseDurationSeconds(value);
            break;

        case AKSamplerParameterFilterAttackDuration:
            setFilterAttackDurationSeconds(value);
            break;
        case AKSamplerParameterFilterDecayDuration:
            setFilterDecayDurationSeconds(value);
            break;
        case AKSamplerParameterFilterSustainLevel:
            setFilterSustainFraction(value);
            break;
        case AKSamplerParameterFilterReleaseDuration:
            setFilterReleaseDurationSeconds(value);
            break;

        case AKSamplerParameterPitchAttackDuration:
            setPitchAttackDurationSeconds(value);
            break;
        case AKSamplerParameterPitchDecayDuration:
            setPitchDecayDurationSeconds(value);
            break;
        case AKSamplerParameterPitchSustainLevel:
            setPitchSustainFraction(value);
            break;
        case AKSamplerParameterPitchReleaseDuration:
            setPitchReleaseDurationSeconds(value);
            break;
        case AKSamplerParameterPitchADSRSemitones:
            pitchADSRSemitonesRamp.setTarget(value, immediate);
            break;

        case AKSamplerParameterRestartVoiceLFO:
            restartVoiceLFO = value > 0.5f;
            break;

        case AKSamplerParameterFilterEnable:
            isFilterEnabled = value > 0.5f;
            break;
        case AKSamplerParameterLoopThruRelease:
            loopThruRelease = value > 0.5f;
            break;
        case AKSamplerParameterMonophonic:
            isMonophonic = value > 0.5f;
            break;
        case AKSamplerParameterLegato:
            isLegato = value > 0.5f;
            break;
        case AKSamplerParameterKeyTrackingFraction:
            keyTracking = value;
            break;
        case AKSamplerParameterFilterEnvelopeVelocityScaling:
            filterEnvelopeVelocityScaling = value;
            break;
    }
}

float AKSamplerDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKSamplerParameterRampDuration:
            return pitchBendRamp.getRampDuration(sampleRate);

        case AKSamplerParameterMasterVolume:
            return masterVolumeRamp.getTarget();
        case AKSamplerParameterPitchBend:
            return pitchBendRamp.getTarget();
        case AKSamplerParameterVibratoDepth:
            return vibratoDepthRamp.getTarget();
        case AKSamplerParameterVibratoFrequency:
            return vibratoFrequencyRamp.getTarget();
        case AKSamplerParameterVoiceVibratoDepth:
            return voiceVibratoDepthRamp.getTarget();
        case AKSamplerParameterVoiceVibratoFrequency:
            return voiceVibratoFrequencyRamp.getTarget();
        case AKSamplerParameterFilterCutoff:
            return filterCutoffRamp.getTarget();
        case AKSamplerParameterFilterStrength:
            return filterStrengthRamp.getTarget();
        case AKSamplerParameterFilterResonance:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case AKSamplerParameterGlideRate:
            return glideRateRamp.getTarget();

        case AKSamplerParameterAttackDuration:
            return getADSRAttackDurationSeconds();
        case AKSamplerParameterHoldDuration:
            return getADSRHoldDurationSeconds();
        case AKSamplerParameterDecayDuration:
            return getADSRDecayDurationSeconds();
        case AKSamplerParameterSustainLevel:
            return getADSRSustainFraction();
        case AKSamplerParameterReleaseHoldDuration:
            return getADSRReleaseHoldDurationSeconds();
        case AKSamplerParameterReleaseDuration:
            return getADSRReleaseDurationSeconds();

        case AKSamplerParameterFilterAttackDuration:
            return getFilterAttackDurationSeconds();
        case AKSamplerParameterFilterDecayDuration:
            return getFilterDecayDurationSeconds();
        case AKSamplerParameterFilterSustainLevel:
            return getFilterSustainFraction();
        case AKSamplerParameterFilterReleaseDuration:
            return getFilterReleaseDurationSeconds();

        case AKSamplerParameterPitchAttackDuration:
            return getPitchAttackDurationSeconds();
        case AKSamplerParameterPitchDecayDuration:
            return getPitchDecayDurationSeconds();
        case AKSamplerParameterPitchSustainLevel:
            return getPitchSustainFraction();
        case AKSamplerParameterPitchReleaseDuration:
            return getPitchReleaseDurationSeconds();
        case AKSamplerParameterPitchADSRSemitones:
            return pitchADSRSemitonesRamp.getTarget();
        case AKSamplerParameterRestartVoiceLFO:
            return restartVoiceLFO ? 1.0f : 0.0f;

        case AKSamplerParameterFilterEnable:
            return isFilterEnabled ? 1.0f : 0.0f;
        case AKSamplerParameterLoopThruRelease:
            return loopThruRelease ? 1.0f : 0.0f;
        case AKSamplerParameterMonophonic:
            return isMonophonic ? 1.0f : 0.0f;
        case AKSamplerParameterLegato:
            return isLegato ? 1.0f : 0.0f;
        case AKSamplerParameterKeyTrackingFraction:
            return keyTracking;
        case AKSamplerParameterFilterEnvelopeVelocityScaling:
            return filterEnvelopeVelocityScaling;
    }
    return 0;
}

void AKSamplerDSP::handleMIDIEvent(const AUMIDIEvent &midiEvent)
{
    if (midiEvent.length != 3) return;
    uint8_t status = midiEvent.data[0] & 0xF0;
    //uint8_t channel = midiEvent.data[0] & 0x0F; // works in omni mode.
    switch (status) {
        case 0x80 : { // note off
            uint8_t note = midiEvent.data[1];
            if (note > 127) break;
            stopNote(note, false);
            break;
        }
        case 0x90 : { // note on
            uint8_t note = midiEvent.data[1];
            uint8_t veloc = midiEvent.data[2];
            if (note > 127 || veloc > 127) break;
            playNote(note, veloc);
            break;
        }
        case 0xB0 : { // control
            uint8_t num = midiEvent.data[1];
            if (num == 123) { // all notes off
                stopAllVoices();
            }
            break;
        }
    }
}

void AKSamplerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    // process in chunks of maximum length AKCORESAMPLER_CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += AKCORESAMPLER_CHUNKSIZE) {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > AKCORESAMPLER_CHUNKSIZE) chunkSize = AKCORESAMPLER_CHUNKSIZE;

        // ramp parameters
        masterVolumeRamp.advanceTo(now + frameOffset);
        masterVolume = (float)masterVolumeRamp.getValue();
        pitchBendRamp.advanceTo(now + frameOffset);
        pitchOffset = (float)pitchBendRamp.getValue();
        vibratoDepthRamp.advanceTo(now + frameOffset);
        vibratoDepth = (float)vibratoDepthRamp.getValue();
        vibratoFrequencyRamp.advanceTo(now + frameOffset);
        vibratoFrequency = (float)vibratoFrequencyRamp.getValue();
        voiceVibratoDepthRamp.advanceTo(now + frameOffset);
        voiceVibratoDepth = (float)voiceVibratoDepthRamp.getValue();
        voiceVibratoFrequencyRamp.advanceTo(now + frameOffset);
        voiceVibratoFrequency = (float)voiceVibratoFrequencyRamp.getValue();
        filterCutoffRamp.advanceTo(now + frameOffset);
        cutoffMultiple = (float)filterCutoffRamp.getValue();
        filterStrengthRamp.advanceTo(now + frameOffset);
        cutoffEnvelopeStrength = (float)filterStrengthRamp.getValue();
        filterResonanceRamp.advanceTo(now + frameOffset);
        linearResonance = (float)filterResonanceRamp.getValue();
        
        pitchADSRSemitonesRamp.advanceTo(now + frameOffset);
        pitchADSRSemitones = (float)pitchADSRSemitonesRamp.getValue();

        glideRateRamp.advanceTo(now + frameOffset);
        glideRate = (float)glideRateRamp.getValue();

        // get data
        float *outBuffers[2];
        outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + frameOffset;
        unsigned channelCount = outputBufferList->mNumberBuffers;
        AKCoreSampler::render(channelCount, chunkSize, outBuffers);
    }
}
