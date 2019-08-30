//
//  AKFilterSynthDSPKernel.hpp
//  AudioKit
//
//  Created by Colin Hallett, revision history on GitHub.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKSoundpipeKernel.hpp"
#import <vector>
#import "AKBankDSPKernel.hpp"
/*static inline double pow2(double x) {
    return x * x;
}*/

#import "AKDSPKernel.hpp"

class AKFilterSynthDSPKernel: public AKSoundpipeKernel {
    
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
        
        AKFilterSynthDSPKernel *kernel;
        
        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;
        
        float internalGate = 0;
        float amp = 0;
        float filterAmp = 0;
        
        
        sp_adsr *adsr;
        sp_moogladder *filter;
        sp_adsr *filterEnv;
        
        NoteState() {
            sp_adsr_create(&adsr);
            sp_moogladder_create(&filter);
            sp_adsr_create(&filterEnv);
        }
        
        virtual ~NoteState() {
            sp_adsr_destroy(&adsr);
            sp_moogladder_destroy(&filter);
            sp_adsr_destroy(&filterEnv);
        }
        
        virtual void init() = 0;
        
        virtual void clear() {
            stage = stageOff;
            amp = 0;
            filterAmp = 0;
        }
        
        void noteOn(int noteNumber, int velocity)
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
    enum FilterSynthAddresses {
        attackDurationAddress = 0,
        decayDurationAddress,
        sustainLevelAddress,
        releaseDurationAddress,
        pitchBendAddress,
        vibratoDepthAddress,
        vibratoRateAddress,
        filterCutoffFrequencyAddress,
        filterResonanceAddress,
        filterAttackDurationAddress,
        filterDecayDurationAddress,
        filterSustainLevelAddress,
        filterReleaseDurationAddress,
        filterEnvelopeStrengthAddress,
        filterLFODepthAddress,
        filterLFORateAddress,
        numberOfFilterSynthEnumElements
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
        filterCutoffFrequencyRamper.init();
        filterResonanceRamper.init();
        filterAttackDurationRamper.init();
        filterDecayDurationRamper.init();
        filterSustainLevelRamper.init();
        filterReleaseDurationRamper.init();
        filterEnvelopeStrengthRamper.init();
        filterLFODepthRamper.init();
        filterLFORateRamper.init();
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
        
        filterCutoffFrequencyRamper.reset();
        filterResonanceRamper.reset();
        filterAttackDurationRamper.reset();
        filterDecayDurationRamper.reset();
        filterSustainLevelRamper.reset();
        filterReleaseDurationRamper.reset();
        filterEnvelopeStrengthRamper.reset();
        
        filterLFODepthRamper.reset();
        filterLFORateRamper.reset();
    }
    
    double frequencyScale = 2. * M_PI / sampleRate;
    
    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 1.0;
    float releaseDuration = 0.1;
    
    float pitchBend = 0;
    float vibratoDepth = 0;
    float vibratoRate = 0;
    
    float filterCutoffFrequency = 22050.0;
    float filterResonance = 0.0;
    float filterAttackDuration = 0.1;
    float filterDecayDuration = 0.1;
    float filterSustainLevel = 1.0;
    float filterReleaseDuration = 0.1;
    float filterEnvelopeStrength = 0.0;
    
    float filterLFODepth = 0.0;
    float filterLFORate = 0.0;
    
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
    ParameterRamper filterCutoffFrequencyRamper = 0.1;
    ParameterRamper filterResonanceRamper = 0.1;
    ParameterRamper filterAttackDurationRamper = 0.1;
    ParameterRamper filterDecayDurationRamper = 0.1;
    ParameterRamper filterSustainLevelRamper = 1.0;
    ParameterRamper filterReleaseDurationRamper = 0.1;
    ParameterRamper filterEnvelopeStrengthRamper = 0.0;
    ParameterRamper filterLFODepthRamper = 0;
    ParameterRamper filterLFORateRamper = 0;
    
    // standard filter synth kernel functions
    void startNote(int note, int velocity) {
        noteStates[note]->noteOn(note, velocity);
    }
    void startNote(int note, int velocity, float frequency) {
        noteStates[note]->noteOn(note, velocity, frequency);
    }
    void stopNote(int note) {
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
    void setFilterCutoffFrequency(float value) {
        filterCutoffFrequency = clamp(value, 0.0f, 22050.0f);
        filterCutoffFrequencyRamper.setImmediate(filterCutoffFrequency);
    }
    
    void setFilterResonance(float value) {
        filterResonance = clamp(value, 0.0f, 0.99f);
        filterResonanceRamper.setImmediate(filterResonance);
    }
    
    void setFilterAttackDuration(float value) {
        filterAttackDuration = clamp(value, 0.0f, 99.0f);
        filterAttackDurationRamper.setImmediate(filterAttackDuration);
    }
    
    void setFilterDecayDuration(float value) {
        filterDecayDuration = clamp(value, 0.0f, 99.0f);
        filterDecayDurationRamper.setImmediate(filterDecayDuration);
    }
    
    void setFilterSustainLevel(float value) {
        filterSustainLevel = clamp(value, 0.0f, 99.0f);
        filterSustainLevelRamper.setImmediate(filterSustainLevel);
    }
    
    void setFilterReleaseDuration(float value) {
        filterReleaseDuration = clamp(value, 0.0f, 99.0f);
        filterReleaseDurationRamper.setImmediate(filterReleaseDuration);
    }
    void setFilterEnvelopeStength(float value) {
        filterEnvelopeStrength = clamp(value, 0.0f, 1.0f);
        filterEnvelopeStrengthRamper.setImmediate(filterEnvelopeStrength);
    }
    void setFilterLFODepth(float value) {
        filterLFODepth = clamp(value, 0.0f, 1.0f);
        filterLFODepthRamper.setImmediate(filterLFODepth);
    }
    void setFilterLFORate(float value) {
        filterLFORate = clamp(value, 0.0f, 600.0f);
        filterLFORateRamper.setImmediate(filterLFORate);
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
    
    void standardFilterSynthGetAndSteps() {
        attackDuration = attackDurationRamper.getAndStep();
        decayDuration = decayDurationRamper.getAndStep();
        sustainLevel = sustainLevelRamper.getAndStep();
        releaseDuration = releaseDurationRamper.getAndStep();
        pitchBend = double(pitchBendRamper.getAndStep());
        vibratoDepth = double(vibratoDepthRamper.getAndStep());
        vibratoRate = double(vibratoRateRamper.getAndStep());
        filterCutoffFrequency = double(filterCutoffFrequencyRamper.getAndStep());
        filterResonance = double(filterResonanceRamper.getAndStep());
        filterAttackDuration = filterAttackDurationRamper.getAndStep();
        filterDecayDuration = filterDecayDurationRamper.getAndStep();
        filterSustainLevel = filterSustainLevelRamper.getAndStep();
        filterReleaseDuration = filterReleaseDurationRamper.getAndStep();
        filterEnvelopeStrength = filterEnvelopeStrengthRamper.getAndStep();
        filterLFODepth = filterLFODepthRamper.getAndStep();
        filterLFORate = filterLFORateRamper.getAndStep();
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
            case filterCutoffFrequencyAddress:
                filterCutoffFrequencyRamper.setUIValue(clamp(value, 0.0f, 22050.0f));
                break;
            case filterResonanceAddress:
                filterResonanceRamper.setUIValue(clamp(value, 0.0f, 0.99f));
                break;
            case filterAttackDurationAddress:
                filterAttackDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterDecayDurationAddress:
                filterDecayDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterSustainLevelAddress:
                filterSustainLevelRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterReleaseDurationAddress:
                filterReleaseDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;
            case filterEnvelopeStrengthAddress:
                filterEnvelopeStrengthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            case filterLFODepthAddress:
                filterLFODepthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            case filterLFORateAddress:
                filterLFORateRamper.setUIValue(clamp(value, 0.0f, 600.0f));
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
            case filterCutoffFrequencyAddress:
                return filterCutoffFrequencyRamper.getUIValue(); \
            case filterResonanceAddress:
                return filterResonanceRamper.getUIValue(); \
            case filterAttackDurationAddress:
                return filterAttackDurationRamper.getUIValue(); \
            case filterDecayDurationAddress:
                return filterDecayDurationRamper.getUIValue(); \
            case filterSustainLevelAddress:
                return filterSustainLevelRamper.getUIValue(); \
            case filterReleaseDurationAddress:
                return filterReleaseDurationRamper.getUIValue(); \
            case filterEnvelopeStrengthAddress:
                return filterEnvelopeStrengthRamper.getUIValue(); \
            case filterLFODepthAddress:
                return filterLFODepthRamper.getUIValue(); \
            case filterLFORateAddress:
                return filterLFORateRamper.getUIValue(); \
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
            case filterCutoffFrequencyAddress:
                filterCutoffFrequencyRamper.startRamp(clamp(value, 0.0f, 22050.0f), duration);
                break;
            case filterResonanceAddress:
                filterResonanceRamper.startRamp(clamp(value, 0.0f, 0.99f), duration);
                break;
            case filterAttackDurationAddress:
                filterAttackDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterDecayDurationAddress:
                filterDecayDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterSustainLevelAddress:
                filterSustainLevelRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterReleaseDurationAddress:
                filterReleaseDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;
            case filterEnvelopeStrengthAddress:
                filterEnvelopeStrengthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            case filterLFODepthAddress:
                filterLFODepthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            case filterLFORateAddress:
                filterLFORateRamper.startRamp(clamp(value, 0.0f, 600.0f), duration);
                break;
        }
    }
};

#endif  // #ifdef __cplusplus
