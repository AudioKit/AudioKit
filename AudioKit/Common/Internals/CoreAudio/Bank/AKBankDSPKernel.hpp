//
//  AKBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKSoundpipeKernel.hpp"
#import <vector>

static inline double pow2(double x) {
    return x * x;
}

#import "AKDSPKernel.hpp"

class AKBankDSPKernel: public AKSoundpipeKernel {

public:

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        attackDurationRamper.init();
        decayDurationRamper.init();
        sustainLevelRamper.init();
        releaseDurationRamper.init();
        pitchBendRamper.init();
        vibratoDepthRamper.init();
        vibratoRateRamper.init();
    }

    void reset() {
        playingNotesCount = 0;
        resetted = true;

        attackDurationRamper.reset();
        decayDurationRamper.reset();
        sustainLevelRamper.reset();
        releaseDurationRamper.reset();
        pitchBendRamper.reset();
        vibratoDepthRamper.reset();
        vibratoRateRamper.reset();
    }

    double frequencyScale = 2. * M_PI / sampleRate;

    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 1.0;
    float releaseDuration = 0.1;

    float pitchBend = 0;
    float vibratoDepth = 0;
    float vibratoRate = 0;

    UInt64 currentRunningIndex = 0;

    int playingNotesCount = 0;
    bool resetted = false;

    ParameterRamper attackDurationRamper = 0.1;
    ParameterRamper decayDurationRamper = 0.1;
    ParameterRamper sustainLevelRamper = 1.0;
    ParameterRamper releaseDurationRamper = 0.1;
    ParameterRamper pitchBendRamper = 0;
    ParameterRamper vibratoDepthRamper = 0;
    ParameterRamper vibratoRateRamper = 0;
};

#define standardBankKernelFunctions() \
    void startNote(int note, int velocity) { \
        noteStates[note].noteOn(note, velocity); \
    } \
    void startNote(int note, int velocity, float frequency) { \
        noteStates[note].noteOn(note, velocity, frequency); \
    } \
    void stopNote(int note) { \
        noteStates[note].noteOn(note, 0); \
    } \
    void setAttackDuration(float value) { \
        attackDuration = clamp(value, 0.0f, 99.0f); \
        attackDurationRamper.setImmediate(attackDuration); \
    } \
    void setDecayDuration(float value) { \
        decayDuration = clamp(value, 0.0f, 99.0f); \
        decayDurationRamper.setImmediate(decayDuration); \
    } \
    void setSustainLevel(float value) { \
        sustainLevel = clamp(value, 0.0f, 99.0f); \
        sustainLevelRamper.setImmediate(sustainLevel); \
    } \
    void setReleaseDuration(float value) { \
        releaseDuration = clamp(value, 0.0f, 99.0f); \
        releaseDurationRamper.setImmediate(releaseDuration); \
    } \
    void setPitchBend(float value) { \
        pitchBend = clamp(value, (float)-48, (float)48); \
        pitchBendRamper.setImmediate(pitchBend); \
    } \
    void setVibratoDepth(float value) { \
        vibratoDepth = clamp(value, (float)0, (float)24); \
        vibratoDepthRamper.setImmediate(vibratoDepth); \
    } \
    void setVibratoRate(float value) { \
        vibratoRate = clamp(value, (float)0, (float)600); \
        vibratoRateRamper.setImmediate(vibratoRate); \
    }

#define standardBankSetParameters() \
    case attackDurationAddress: \
        attackDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f)); \
        break; \
    case decayDurationAddress: \
        decayDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f)); \
        break; \
    case sustainLevelAddress: \
        sustainLevelRamper.setUIValue(clamp(value, 0.0f, 99.0f)); \
        break; \
    case releaseDurationAddress: \
        releaseDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f)); \
        break; \
    case pitchBendAddress: \
        pitchBendRamper.setUIValue(clamp(value, (float)-24, (float)24)); \
        break; \
    case vibratoDepthAddress: \
        vibratoDepthRamper.setUIValue(clamp(value, (float)0, (float)24)); \
        break; \
    case vibratoRateAddress: \
        vibratoRateRamper.setUIValue(clamp(value, (float)0, (float)600)); \
        break;

#define standardBankGetParameters() \
    case attackDurationAddress: \
        return attackDurationRamper.getUIValue(); \
    case decayDurationAddress: \
        return decayDurationRamper.getUIValue(); \
    case sustainLevelAddress: \
        return sustainLevelRamper.getUIValue(); \
    case releaseDurationAddress: \
        return releaseDurationRamper.getUIValue(); \
    case pitchBendAddress: \
        return pitchBendRamper.getUIValue(); \
    case vibratoDepthAddress: \
        return vibratoDepthRamper.getUIValue(); \
    case vibratoRateAddress: \
        return vibratoRateRamper.getUIValue(); \
    default: return 0.0f;

#define standardBankStartRamps() \
    case attackDurationAddress:\
        attackDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration); \
        break; \
    case decayDurationAddress: \
        decayDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration); \
        break; \
    case sustainLevelAddress: \
        sustainLevelRamper.startRamp(clamp(value, 0.0f, 99.0f), duration); \
        break; \
    case releaseDurationAddress: \
        releaseDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration); \
        break; \
    case pitchBendAddress: \
        pitchBendRamper.startRamp(clamp(value, (float)-24, (float)24), duration); \
        break; \
    case vibratoDepthAddress: \
        vibratoDepthRamper.startRamp(clamp(value, (float)0, (float)24), duration); \
        break; \
    case vibratoRateAddress: \
        vibratoRateRamper.startRamp(clamp(value, (float)0, (float)600), duration); \
        break;


#define standardHandleMIDI() \
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override { \
        if (midiEvent.length != 3) return; \
        uint8_t status = midiEvent.data[0] & 0xF0; \
        switch (status) { \
            case 0x80 : {  \
                uint8_t note = midiEvent.data[1]; \
                if (note > 127) break; \
                noteStates[note].noteOn(note, 0); \
                break; \
            } \
            case 0x90 : {  \
                uint8_t note = midiEvent.data[1]; \
                uint8_t veloc = midiEvent.data[2]; \
                if (note > 127 || veloc > 127) break; \
                noteStates[note].noteOn(note, veloc); \
                break; \
            } \
            case 0xB0 : { \
                uint8_t num = midiEvent.data[1]; \
                if (num == 123) { \
                    NoteState *noteState = playingNotes; \
                    while (noteState) { \
                        noteState->clear(); \
                        noteState = noteState->next; \
                    } \
                    playingNotes = nullptr; \
                    playingNotesCount = 0; \
                } \
                break; \
            } \
        } \
    }

#define standardBankGetAndSteps() \
    attackDuration = attackDurationRamper.getAndStep(); \
    decayDuration = decayDurationRamper.getAndStep(); \
    sustainLevel = sustainLevelRamper.getAndStep(); \
    releaseDuration = releaseDurationRamper.getAndStep(); \
    pitchBend = double(pitchBendRamper.getAndStep()); \
    vibratoDepth = double(vibratoDepthRamper.getAndStep()); \
    vibratoRate = double(vibratoRateRamper.getAndStep());

#endif

