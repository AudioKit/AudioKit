// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "SamplerDSP.h"
#include "wavpack.h"
#include <math.h>

DSPRef akSamplerCreateDSP() {
    return new SamplerDSP();
}

void akSamplerLoadData(DSPRef pDSP, SampleDataDescriptor *pSDD) {
    ((SamplerDSP*)pDSP)->loadSampleData(*pSDD);
}

void akSamplerLoadCompressedFile(DSPRef pDSP, SampleFileDescriptor *pSFD)
{
    char errMsg[100];
    WavpackContext *wpc = WavpackOpenFileInput(pSFD->path, errMsg, OPEN_2CH_MAX, 0);
    if (wpc == 0)
    {
        printf("Wavpack error loading %s: %s\n", pSFD->path, errMsg);
        return;
    }

    SampleDataDescriptor sdd;
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

    ((SamplerDSP*)pDSP)->loadSampleData(sdd);
    delete[] sdd.data;
}

void akSamplerUnloadAllSamples(DSPRef pDSP)
{
    ((SamplerDSP*)pDSP)->unloadAllSamples();
}

void akSamplerSetNoteFrequency(DSPRef pDSP, int noteNumber, float noteFrequency)
{
    ((SamplerDSP*)pDSP)->setNoteFrequency(noteNumber, noteFrequency);
}

void akSamplerBuildSimpleKeyMap(DSPRef pDSP) {
    ((SamplerDSP*)pDSP)->buildSimpleKeyMap();
}

void akSamplerBuildKeyMap(DSPRef pDSP) {
    ((SamplerDSP*)pDSP)->buildKeyMap();
}

void akSamplerSetLoopThruRelease(DSPRef pDSP, bool value) {
    ((SamplerDSP*)pDSP)->setLoopThruRelease(value);
}

void akSamplerPlayNote(DSPRef pDSP, UInt8 noteNumber, UInt8 velocity)
{
    ((SamplerDSP*)pDSP)->playNote(noteNumber, velocity);
}

void akSamplerStopNote(DSPRef pDSP, UInt8 noteNumber, bool immediate)
{
    ((SamplerDSP*)pDSP)->stopNote(noteNumber, immediate);
}

void akSamplerStopAllVoices(DSPRef pDSP)
{
    ((SamplerDSP*)pDSP)->stopAllVoices();
}

void akSamplerRestartVoices(DSPRef pDSP)
{
    ((SamplerDSP*)pDSP)->restartVoices();
}

void akSamplerSustainPedal(DSPRef pDSP, bool pedalDown)
{
    ((SamplerDSP*)pDSP)->sustainPedal(pedalDown);
}


SamplerDSP::SamplerDSP() : CoreSampler()
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

void SamplerDSP::init(int channelCount, double sampleRate)
{
    DSPBase::init(channelCount, sampleRate);
    CoreSampler::init(sampleRate);
}

void SamplerDSP::deinit()
{
    DSPBase::deinit();
    CoreSampler::deinit();
}

void SamplerDSP::setParameter(AUParameterAddress address, float value, bool immediate)
{
    switch (address) {
        case SamplerParameterRampDuration:
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

        case SamplerParameterMasterVolume:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case SamplerParameterPitchBend:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVibratoDepth:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVibratoFrequency:
            vibratoFrequencyRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVoiceVibratoDepth:
            voiceVibratoDepthRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVoiceVibratoFrequency:
            voiceVibratoFrequencyRamp.setTarget(value, immediate);
            break;
        case SamplerParameterFilterCutoff:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case SamplerParameterFilterStrength:
            filterStrengthRamp.setTarget(value, immediate);
            break;
        case SamplerParameterFilterResonance:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;
        case SamplerParameterGlideRate:
            glideRateRamp.setTarget(value, immediate);
            break;

        case SamplerParameterAttackDuration:
            setADSRAttackDurationSeconds(value);
            break;
        case SamplerParameterHoldDuration:
            setADSRHoldDurationSeconds(value);
            break;
        case SamplerParameterDecayDuration:
            setADSRDecayDurationSeconds(value);
            break;
        case SamplerParameterSustainLevel:
            setADSRSustainFraction(value);
            break;
        case SamplerParameterReleaseHoldDuration:
            setADSRReleaseHoldDurationSeconds(value);
            break;
        case SamplerParameterReleaseDuration:
            setADSRReleaseDurationSeconds(value);
            break;

        case SamplerParameterFilterAttackDuration:
            setFilterAttackDurationSeconds(value);
            break;
        case SamplerParameterFilterDecayDuration:
            setFilterDecayDurationSeconds(value);
            break;
        case SamplerParameterFilterSustainLevel:
            setFilterSustainFraction(value);
            break;
        case SamplerParameterFilterReleaseDuration:
            setFilterReleaseDurationSeconds(value);
            break;

        case SamplerParameterPitchAttackDuration:
            setPitchAttackDurationSeconds(value);
            break;
        case SamplerParameterPitchDecayDuration:
            setPitchDecayDurationSeconds(value);
            break;
        case SamplerParameterPitchSustainLevel:
            setPitchSustainFraction(value);
            break;
        case SamplerParameterPitchReleaseDuration:
            setPitchReleaseDurationSeconds(value);
            break;
        case SamplerParameterPitchADSRSemitones:
            pitchADSRSemitonesRamp.setTarget(value, immediate);
            break;

        case SamplerParameterRestartVoiceLFO:
            restartVoiceLFO = value > 0.5f;
            break;

        case SamplerParameterFilterEnable:
            isFilterEnabled = value > 0.5f;
            break;
        case SamplerParameterLoopThruRelease:
            loopThruRelease = value > 0.5f;
            break;
        case SamplerParameterMonophonic:
            isMonophonic = value > 0.5f;
            break;
        case SamplerParameterLegato:
            isLegato = value > 0.5f;
            break;
        case SamplerParameterKeyTrackingFraction:
            keyTracking = value;
            break;
        case SamplerParameterFilterEnvelopeVelocityScaling:
            filterEnvelopeVelocityScaling = value;
            break;
    }
}

float SamplerDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case SamplerParameterRampDuration:
            return pitchBendRamp.getRampDuration(sampleRate);

        case SamplerParameterMasterVolume:
            return masterVolumeRamp.getTarget();
        case SamplerParameterPitchBend:
            return pitchBendRamp.getTarget();
        case SamplerParameterVibratoDepth:
            return vibratoDepthRamp.getTarget();
        case SamplerParameterVibratoFrequency:
            return vibratoFrequencyRamp.getTarget();
        case SamplerParameterVoiceVibratoDepth:
            return voiceVibratoDepthRamp.getTarget();
        case SamplerParameterVoiceVibratoFrequency:
            return voiceVibratoFrequencyRamp.getTarget();
        case SamplerParameterFilterCutoff:
            return filterCutoffRamp.getTarget();
        case SamplerParameterFilterStrength:
            return filterStrengthRamp.getTarget();
        case SamplerParameterFilterResonance:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case SamplerParameterGlideRate:
            return glideRateRamp.getTarget();

        case SamplerParameterAttackDuration:
            return getADSRAttackDurationSeconds();
        case SamplerParameterHoldDuration:
            return getADSRHoldDurationSeconds();
        case SamplerParameterDecayDuration:
            return getADSRDecayDurationSeconds();
        case SamplerParameterSustainLevel:
            return getADSRSustainFraction();
        case SamplerParameterReleaseHoldDuration:
            return getADSRReleaseHoldDurationSeconds();
        case SamplerParameterReleaseDuration:
            return getADSRReleaseDurationSeconds();

        case SamplerParameterFilterAttackDuration:
            return getFilterAttackDurationSeconds();
        case SamplerParameterFilterDecayDuration:
            return getFilterDecayDurationSeconds();
        case SamplerParameterFilterSustainLevel:
            return getFilterSustainFraction();
        case SamplerParameterFilterReleaseDuration:
            return getFilterReleaseDurationSeconds();

        case SamplerParameterPitchAttackDuration:
            return getPitchAttackDurationSeconds();
        case SamplerParameterPitchDecayDuration:
            return getPitchDecayDurationSeconds();
        case SamplerParameterPitchSustainLevel:
            return getPitchSustainFraction();
        case SamplerParameterPitchReleaseDuration:
            return getPitchReleaseDurationSeconds();
        case SamplerParameterPitchADSRSemitones:
            return pitchADSRSemitonesRamp.getTarget();
        case SamplerParameterRestartVoiceLFO:
            return restartVoiceLFO ? 1.0f : 0.0f;

        case SamplerParameterFilterEnable:
            return isFilterEnabled ? 1.0f : 0.0f;
        case SamplerParameterLoopThruRelease:
            return loopThruRelease ? 1.0f : 0.0f;
        case SamplerParameterMonophonic:
            return isMonophonic ? 1.0f : 0.0f;
        case SamplerParameterLegato:
            return isLegato ? 1.0f : 0.0f;
        case SamplerParameterKeyTrackingFraction:
            return keyTracking;
        case SamplerParameterFilterEnvelopeVelocityScaling:
            return filterEnvelopeVelocityScaling;
    }
    return 0;
}

void SamplerDSP::handleMIDIEvent(const AUMIDIEvent &midiEvent)
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

void SamplerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{

    float *pLeft = (float *)outputBufferList->mBuffers[0].mData + bufferOffset;
    float *pRight = (float *)outputBufferList->mBuffers[1].mData + bufferOffset;

    memset(pLeft, 0, frameCount * sizeof(float));
    memset(pRight, 0, frameCount * sizeof(float));

    // process in chunks of maximum length CORESAMPLER_CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += CORESAMPLER_CHUNKSIZE) {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > CORESAMPLER_CHUNKSIZE) chunkSize = CORESAMPLER_CHUNKSIZE;

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
        CoreSampler::render(channelCount, chunkSize, outBuffers);
    }
}

AK_REGISTER_DSP(SamplerDSP, "samp")
AK_REGISTER_PARAMETER(SamplerParameterMasterVolume)
AK_REGISTER_PARAMETER(SamplerParameterPitchBend)
AK_REGISTER_PARAMETER(SamplerParameterVibratoDepth)
AK_REGISTER_PARAMETER(SamplerParameterVibratoFrequency)
AK_REGISTER_PARAMETER(SamplerParameterVoiceVibratoDepth)
AK_REGISTER_PARAMETER(SamplerParameterVoiceVibratoFrequency)
AK_REGISTER_PARAMETER(SamplerParameterFilterCutoff)
AK_REGISTER_PARAMETER(SamplerParameterFilterStrength)
AK_REGISTER_PARAMETER(SamplerParameterFilterResonance)
AK_REGISTER_PARAMETER(SamplerParameterGlideRate)
AK_REGISTER_PARAMETER(SamplerParameterAttackDuration)
AK_REGISTER_PARAMETER(SamplerParameterHoldDuration)
AK_REGISTER_PARAMETER(SamplerParameterDecayDuration)
AK_REGISTER_PARAMETER(SamplerParameterSustainLevel)
AK_REGISTER_PARAMETER(SamplerParameterReleaseHoldDuration)
AK_REGISTER_PARAMETER(SamplerParameterReleaseDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterAttackDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterDecayDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterSustainLevel)
AK_REGISTER_PARAMETER(SamplerParameterFilterReleaseDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterEnable)
AK_REGISTER_PARAMETER(SamplerParameterRestartVoiceLFO)
AK_REGISTER_PARAMETER(SamplerParameterPitchAttackDuration)
AK_REGISTER_PARAMETER(SamplerParameterPitchDecayDuration)
AK_REGISTER_PARAMETER(SamplerParameterPitchSustainLevel)
AK_REGISTER_PARAMETER(SamplerParameterPitchReleaseDuration)
AK_REGISTER_PARAMETER(SamplerParameterPitchADSRSemitones)
AK_REGISTER_PARAMETER(SamplerParameterLoopThruRelease)
AK_REGISTER_PARAMETER(SamplerParameterMonophonic)
AK_REGISTER_PARAMETER(SamplerParameterLegato)
AK_REGISTER_PARAMETER(SamplerParameterKeyTrackingFraction)
AK_REGISTER_PARAMETER(SamplerParameterFilterEnvelopeVelocityScaling)
AK_REGISTER_PARAMETER(SamplerParameterRampDuration)
