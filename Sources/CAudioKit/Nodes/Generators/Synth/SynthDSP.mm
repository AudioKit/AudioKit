// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "SynthDSP.h"
#include <math.h>

DSPRef akSynthCreateDSP() {
    return new SynthDSP();
}

SynthDSP::SynthDSP() : DSPBase(/*inputBusCount*/0), CoreSynth()
{
    masterVolumeRamp.setTarget(1.0, true);
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
    filterCutoffRamp.setTarget(1000.0, true);
    filterResonanceRamp.setTarget(1.0, true);
}

void SynthDSP::init(int channelCount, double sampleRate)
{
    DSPBase::init(channelCount, sampleRate);
    CoreSynth::init(sampleRate);
}

void SynthDSP::deinit()
{
    DSPBase::deinit();
    CoreSynth::deinit();
}

void SynthDSP::setParameter(uint64_t address, float value, bool immediate)
{
    switch (address) {
        case SynthParameterRampDuration:
            masterVolumeRamp.setRampDuration(value, sampleRate);
            pitchBendRamp.setRampDuration(value, sampleRate);
            vibratoDepthRamp.setRampDuration(value, sampleRate);
            filterCutoffRamp.setRampDuration(value, sampleRate);
            filterResonanceRamp.setRampDuration(value, sampleRate);
            break;

        case SynthParameterMasterVolume:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case SynthParameterPitchBend:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case SynthParameterVibratoDepth:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case SynthParameterFilterCutoff:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case SynthParameterFilterStrength:
            filterStrengthRamp.setTarget(value, immediate);
            break;
        case SynthParameterFilterResonance:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;

        case SynthParameterAttackDuration:
            setAmpAttackDurationSeconds(value);
            break;
        case SynthParameterDecayDuration:
            setAmpDecayDurationSeconds(value);
            break;
        case SynthParameterSustainLevel:
            setAmpSustainFraction(value);
            break;
        case SynthParameterReleaseDuration:
            setAmpReleaseDurationSeconds(value);
            break;

        case SynthParameterFilterAttackDuration:
            setFilterAttackDurationSeconds(value);
            break;
        case SynthParameterFilterDecayDuration:
            setFilterDecayDurationSeconds(value);
            break;
        case SynthParameterFilterSustainLevel:
            setFilterSustainFraction(value);
            break;
        case SynthParameterFilterReleaseDuration:
            setFilterReleaseDurationSeconds(value);
            break;
    }
}

float SynthDSP::getParameter(uint64_t address)
{
    switch (address) {
        case SynthParameterRampDuration:
            return pitchBendRamp.getRampDuration(sampleRate);

        case SynthParameterMasterVolume:
            return masterVolumeRamp.getTarget();
        case SynthParameterPitchBend:
            return pitchBendRamp.getTarget();
        case SynthParameterVibratoDepth:
            return vibratoDepthRamp.getTarget();
        case SynthParameterFilterCutoff:
            return filterCutoffRamp.getTarget();
        case SynthParameterFilterStrength:
            return filterStrengthRamp.getTarget();
        case SynthParameterFilterResonance:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case SynthParameterAttackDuration:
            return getAmpAttackDurationSeconds();
        case SynthParameterDecayDuration:
            return getAmpDecayDurationSeconds();
        case SynthParameterSustainLevel:
            return getAmpSustainFraction();
        case SynthParameterReleaseDuration:
            return getAmpReleaseDurationSeconds();

        case SynthParameterFilterAttackDuration:
            return getFilterAttackDurationSeconds();
        case SynthParameterFilterDecayDuration:
            return getFilterDecayDurationSeconds();
        case SynthParameterFilterSustainLevel:
            return getFilterSustainFraction();
        case SynthParameterFilterReleaseDuration:
            return getFilterReleaseDurationSeconds();
    }
    return 0;
}

void SynthDSP::handleMIDIEvent(const AUMIDIEvent &midiEvent)
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
            auto f = pow(2.0, (note - 69.0) / 12.0) * 440.0;
            playNote(note, veloc, f);
            break;
        }
    }
}

void SynthDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{

    float *pLeft = (float *)outputBufferList->mBuffers[0].mData + bufferOffset;
    float *pRight = (float *)outputBufferList->mBuffers[1].mData + bufferOffset;

    memset(pLeft, 0, frameCount * sizeof(float));
    memset(pRight, 0, frameCount * sizeof(float));
    
    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += SYNTH_CHUNKSIZE) {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > SYNTH_CHUNKSIZE) chunkSize = SYNTH_CHUNKSIZE;

        // ramp parameters
        masterVolumeRamp.advanceTo(now + frameOffset);
        masterVolume = (float)masterVolumeRamp.getValue();
        pitchBendRamp.advanceTo(now + frameOffset);
        pitchOffset = (float)pitchBendRamp.getValue();
        vibratoDepthRamp.advanceTo(now + frameOffset);
        vibratoDepth = (float)vibratoDepthRamp.getValue();
        filterCutoffRamp.advanceTo(now + frameOffset);
        cutoffMultiple = (float)filterCutoffRamp.getValue();
        filterStrengthRamp.advanceTo(now + frameOffset);
        cutoffEnvelopeStrength = (float)filterStrengthRamp.getValue();
        filterResonanceRamp.advanceTo(now + frameOffset);
        linearResonance = (float)filterResonanceRamp.getValue();

        // get data
        float *outBuffers[2];
        outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + frameOffset;
        unsigned channelCount = outputBufferList->mNumberBuffers;
        CoreSynth::render(channelCount, chunkSize, outBuffers);
    }
}

AK_REGISTER_DSP(SynthDSP, "snth")
AK_REGISTER_PARAMETER(SynthParameterMasterVolume)
AK_REGISTER_PARAMETER(SynthParameterPitchBend)
AK_REGISTER_PARAMETER(SynthParameterVibratoDepth)
AK_REGISTER_PARAMETER(SynthParameterFilterCutoff)
AK_REGISTER_PARAMETER(SynthParameterFilterStrength)
AK_REGISTER_PARAMETER(SynthParameterFilterResonance)
AK_REGISTER_PARAMETER(SynthParameterAttackDuration)
AK_REGISTER_PARAMETER(SynthParameterDecayDuration)
AK_REGISTER_PARAMETER(SynthParameterSustainLevel)
AK_REGISTER_PARAMETER(SynthParameterReleaseDuration)
AK_REGISTER_PARAMETER(SynthParameterFilterAttackDuration)
AK_REGISTER_PARAMETER(SynthParameterFilterDecayDuration)
AK_REGISTER_PARAMETER(SynthParameterFilterSustainLevel)
AK_REGISTER_PARAMETER(SynthParameterFilterReleaseDuration)
AK_REGISTER_PARAMETER(SynthParameterRampDuration)
