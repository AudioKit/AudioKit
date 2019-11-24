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
    
protected:
    struct NoteState {
        
        // linked-list management
        NoteState *next;
        NoteState *prev;
        
        void remove() {
            if (prev) prev->next = next;
            else kernel->playingNotes = next;
            if (next) next->prev = prev;
            --kernel->playingNotesCount;
        }
        
        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }
        
        AKBankDSPKernel *kernel;
        
        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;
        
        float internalGate = 0;
        float amp = 0;
        
        sp_adsr *adsr;
        
        NoteState() {
            sp_adsr_create(&adsr);
        }
        
        virtual ~NoteState() {
            sp_adsr_destroy(&adsr);
        }
        
        virtual void init() = 0;
        
        virtual void clear() {
            stage = stageOff;
            amp = 0;
        }
        
        virtual void noteOn(int noteNumber, int velocity)
        {
            noteOn(noteNumber, velocity, (float)noteToHz(noteNumber));
        }
        
        virtual void noteOn(int noteNumber, int velocity, float frequency)
        {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                stage = stageOn;
                internalGate = 1;
            }
        }
        
        virtual void run(int frameCount, float *outL, float *outR) = 0;
        
    };
    
public:
    enum BankAddresses {
        attackDurationAddress = 0,
        decayDurationAddress,
        sustainLevelAddress,
        releaseDurationAddress,
        pitchBendAddress,
        vibratoDepthAddress,
        vibratoRateAddress,
        detuningOffsetAddress,
        numberOfBankEnumElements
    };
    
public:
    
    // MARK: Member Functions
    void init(int channelCount, double sampleRate) override {
        AKSoundpipeKernel::init(channelCount, sampleRate);
        
        attackDurationRamper.init();
        decayDurationRamper.init();
        sustainLevelRamper.init();
        releaseDurationRamper.init();
        pitchBendRamper.init();
        vibratoDepthRamper.init();
        vibratoRateRamper.init();
        detuningOffsetRamper.init();
    }
    
    virtual void reset() {
        for (auto& state : noteStates) state->clear();
        playingNotes = nullptr;
        playingNotesCount = 0;
        resetted = true;
        
        attackDurationRamper.reset();
        decayDurationRamper.reset();
        sustainLevelRamper.reset();
        releaseDurationRamper.reset();
        pitchBendRamper.reset();
        vibratoDepthRamper.reset();
        vibratoRateRamper.reset();
        detuningOffsetRamper.reset();
    }
    
    double frequencyScale = 2. * M_PI / sampleRate;
    
    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 1.0;
    float releaseDuration = 0.1;
    
    float pitchBend = 0;
    float vibratoDepth = 0;
    float vibratoRate = 0;
    float detuningOffset = 0;
    int transposition = 0;

    UInt64 currentRunningIndex = 0;
    
    std::vector< std::unique_ptr<NoteState> > noteStates;
    NoteState *playingNotes = nullptr;
    int playingNotesCount = 0;
    bool resetted = false;
    
    ParameterRamper attackDurationRamper = 0.1;
    ParameterRamper decayDurationRamper = 0.1;
    ParameterRamper sustainLevelRamper = 1.0;
    ParameterRamper releaseDurationRamper = 0.1;
    ParameterRamper pitchBendRamper = 0;
    ParameterRamper vibratoDepthRamper = 0;
    ParameterRamper vibratoRateRamper = 0;
    ParameterRamper detuningOffsetRamper = 0;

    // standard bank kernel functions
    virtual void startNote(int note, int velocity) {
        noteStates[note]->noteOn(note, velocity);
    }
    virtual void startNote(int note, int velocity, float frequency) {
        noteStates[note]->noteOn(note, velocity, frequency);
    }
    virtual void stopNote(int note) {
        noteStates[note]->noteOn(note, 0);
    }
    void setAttackDuration(float value) {
        attackDuration = clamp(value, 0.0f, 99.0f);
        attackDurationRamper.setImmediate(attackDuration);
    }
    void setDecayDuration(float value) {
        decayDuration = clamp(value, 0.0f, 99.0f);
        decayDurationRamper.setImmediate(decayDuration);
    }
    void setSustainLevel(float value) {
        sustainLevel = clamp(value, 0.0f, 99.0f);
        sustainLevelRamper.setImmediate(sustainLevel);
    }
    void setReleaseDuration(float value) {
        releaseDuration = clamp(value, 0.0f, 99.0f);
        releaseDurationRamper.setImmediate(releaseDuration);
    }
    void setPitchBend(float value) {
        pitchBend = clamp(value, (float)-48, (float)48);
        pitchBendRamper.setImmediate(pitchBend);
    }
    void setVibratoDepth(float value) {
        vibratoDepth = clamp(value, (float)0, (float)24);
        vibratoDepthRamper.setImmediate(vibratoDepth);
    }
    void setVibratoRate(float value) {
        vibratoRate = clamp(value, (float)0, (float)600);
        vibratoRateRamper.setImmediate(vibratoRate);
    }
    void setDetuningOffset(float value) {
        detuningOffset = clamp(value, (float)-100, (float)100);
        detuningOffsetRamper.setImmediate(detuningOffset);
    }
    
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if (midiEvent.length != 3) return;
        uint8_t status = midiEvent.data[0] & 0xF0;
        switch (status) {
            case 0x80 : {
                uint8_t note = midiEvent.data[1];
                if (note > 127) break;
                noteStates[note]->noteOn(note, 0);
                break;
            }
            case 0x90 : {
                uint8_t note = midiEvent.data[1];
                uint8_t veloc = midiEvent.data[2];
                if (note > 127 || veloc > 127) break;
                noteStates[note]->noteOn(note, veloc);
                break;
            }
            case 0xB0 : {
                uint8_t num = midiEvent.data[1];
                if (num == 123) {
                    NoteState *noteState = playingNotes;
                    while (noteState) {
                        noteState->clear();
                        noteState = noteState->next;
                    }
                    playingNotes = nullptr;
                    playingNotesCount = 0;
                }
                break;
            }
        }
    }
    
    void standardBankGetAndSteps() {
        attackDuration = attackDurationRamper.getAndStep();
        decayDuration = decayDurationRamper.getAndStep();
        sustainLevel = sustainLevelRamper.getAndStep();
        releaseDuration = releaseDurationRamper.getAndStep();
        pitchBend = double(pitchBendRamper.getAndStep());
        vibratoDepth = double(vibratoDepthRamper.getAndStep());
        vibratoRate = double(vibratoRateRamper.getAndStep());
        detuningOffset = double(detuningOffsetRamper.getAndStep());
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case attackDurationAddress:
                attackDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case decayDurationAddress:
                decayDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case sustainLevelAddress:
                sustainLevelRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case releaseDurationAddress:
                releaseDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case pitchBendAddress:
                pitchBendRamper.setUIValue(clamp(value, (float)-24, (float)24));
                break;
            case vibratoDepthAddress:
                vibratoDepthRamper.setUIValue(clamp(value, (float)0, (float)24));
                break;
            case vibratoRateAddress:
                vibratoRateRamper.setUIValue(clamp(value, (float)0, (float)600));
                break;
            case detuningOffsetAddress:
                detuningOffsetRamper.setUIValue(clamp(value, (float)-100, (float)100));
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
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
            case detuningOffsetAddress: \
                return detuningOffsetRamper.getUIValue(); \
            default: return 0.0f;
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case attackDurationAddress:
                attackDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case decayDurationAddress:
                decayDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case sustainLevelAddress:
                sustainLevelRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case releaseDurationAddress:
                releaseDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case pitchBendAddress:
                pitchBendRamper.startRamp(clamp(value, (float)-24, (float)24), duration);
                break;
            case vibratoDepthAddress:
                vibratoDepthRamper.startRamp(clamp(value, (float)0, (float)24), duration);
                break;
            case vibratoRateAddress:
                vibratoRateRamper.startRamp(clamp(value, (float)0, (float)600), duration);
                break;
            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, (float)-100, (float)100), duration);
                break;
        }
    }
};

#endif  // #ifdef __cplusplus
