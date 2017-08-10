//
//  AKBankDSPKernel.hpp
//  AudioKit For macOS
//
//  Created by Aurelius Prochazka on 7/1/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"
#import <vector>

static inline double pow2(double x) {
    return x * x;
}

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
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
        detuningOffsetRamper.init();
        detuningMultiplierRamper.init();
    }
    
    void reset() {
        playingNotesCount = 0;
        resetted = true;
        
        attackDurationRamper.reset();
        decayDurationRamper.reset();
        sustainLevelRamper.reset();
        releaseDurationRamper.reset();
        detuningOffsetRamper.reset();
        detuningMultiplierRamper.reset();
    }
    
    double frequencyScale = 2. * M_PI / sampleRate;
    
    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 1.0;
    float releaseDuration = 0.1;
    
    float detuningOffset = 0;
    float detuningMultiplier = 1;

    int playingNotesCount = 0;
    bool resetted = false;

    ParameterRamper attackDurationRamper = 0.1;
    ParameterRamper decayDurationRamper = 0.1;
    ParameterRamper sustainLevelRamper = 1.0;
    ParameterRamper releaseDurationRamper = 0.1;
    
    ParameterRamper detuningOffsetRamper = 0;
    ParameterRamper detuningMultiplierRamper = 1;
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
    void setDetuningOffset(float value) { \
        detuningOffset = clamp(value, (float)-1000, (float)1000); \
        detuningOffsetRamper.setImmediate(detuningOffset); \
    } \
    void setDetuningMultiplier(float value) { \
        detuningMultiplier = value; \
        detuningMultiplierRamper.setImmediate(detuningMultiplier); \
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
    case detuningOffsetAddress: \
        detuningOffsetRamper.setUIValue(clamp(value, (float)-1000, (float)1000)); \
        break; \
    case detuningMultiplierAddress: \
        detuningMultiplierRamper.setUIValue(value); \
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
    case detuningOffsetAddress: \
        return detuningOffsetRamper.getUIValue(); \
    case detuningMultiplierAddress: \
        return detuningMultiplierRamper.getUIValue(); \
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
    case detuningOffsetAddress: \
        detuningOffsetRamper.startRamp(clamp(value, (float)-1000, (float)1000), duration); \
        break; \
    case detuningMultiplierAddress: \
        detuningMultiplierRamper.startRamp(value, duration); \
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
                    NoteState* noteState = playingNotes; \
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
    detuningOffset = double(detuningOffsetRamper.getAndStep()); \
    detuningMultiplier = double(detuningMultiplierRamper.getAndStep()); \

