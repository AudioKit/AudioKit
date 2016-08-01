//
//  AKPhaseDistortionOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPhaseDistortionOscillatorBankDSPKernel_hpp
#define AKPhaseDistortionOscillatorBankDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"
#import <vector>

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    phaseDistortionAddress = 0,
    attackDurationAddress = 1,
    decayDurationAddress = 2,
    sustainLevelAddress = 3,
    releaseDurationAddress = 4,
    detuningOffsetAddress = 5,
    detuningMultiplierAddress = 6
};

static inline double pow2(double x) {
    return x * x;
}

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

class AKPhaseDistortionOscillatorBankDSPKernel : public DSPKernel {
public:
    // MARK: Types
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        AKPhaseDistortionOscillatorBankDSPKernel* kernel;
        
        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;
        
        float internalGate = 0;
        float amp = 0;
        float velocityAmp = 0;
        
        sp_adsr *adsr;
        sp_tabread *tab;
        sp_phasor *phs;
        sp_pdhalf *pdhalf;
        
        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);
            
            sp_pdhalf_create(&pdhalf);
            sp_tabread_create(&tab);
            sp_tabread_init(kernel->sp, tab, kernel->ftbl, 1);
            sp_phasor_create(&phs);
            
            sp_pdhalf_init(kernel->sp, pdhalf);
            sp_phasor_init(kernel->sp, phs, 0);

            phs->freq = 0;
        }

        
        void clear() {
            stage = stageOff;
            amp = 0;
        }
        
        // linked list management
        void remove() {
            if (prev) prev->next = next;
            else kernel->playingNotes = next;
            
            if (next) next->prev = prev;
            
            //prev = next = nullptr; Had to remove due to a click, potentially bad
            
            --kernel->playingNotesCount;

            sp_pdhalf_destroy(&pdhalf);
            sp_tabread_destroy(&tab);
            sp_phasor_destroy(&phs);
        }
        
        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }
        
        void noteOn(int noteNumber, int velocity)
        {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                phs->freq = (float)noteToHz(noteNumber);
                velocityAmp = (float)pow2(velocity / 127.);
                stage = stageOn;
                internalGate = 1;
            }
        }
        
        
        void run(int frameCount, float* outL, float* outR)
        {
            float originalFrequency = phs->freq;
            phs->freq *= kernel->detuningMultiplier;
            phs->freq += kernel->detuningOffset;
            phs->freq = clamp(phs->freq, 0.0f, 22050.0f);
            pdhalf->amount = kernel->phaseDistortion;

            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float temp = 0;
                float pd = 0;
                float ph = 0;
                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);

                sp_phasor_compute(kernel->sp, phs, NULL, &ph);
                sp_pdhalf_compute(kernel->sp, pdhalf, &ph, &pd);
                tab->index = pd;
                sp_tabread_compute(kernel->sp, tab, NULL, &temp);

                *outL++ += velocityAmp * amp * temp;
                *outR++ += velocityAmp * amp * temp;
                
            }
            phs->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }
        
    };

    // MARK: Member Functions

    AKPhaseDistortionOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
    }

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        
        attackDurationRamper.init();
        decayDurationRamper.init();
        sustainLevelRamper.init();
        releaseDurationRamper.init();
        detuningOffsetRamper.init();
        detuningMultiplierRamper.init();
    }

    void setupWaveform(uint32_t size) {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
    }

    void setWaveformValue(uint32_t index, float value) {
        ftbl->tbl[index] = value;
    }

    void startNote(int note, int velocity) {
        noteStates[note].noteOn(note, velocity);
    }

    void stopNote(int note) {
        noteStates[note].noteOn(note, 0);
    }

    void destroy() {
        sp_destroy(&sp);
    }

    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        playingNotesCount = 0;
        resetted = true;
        
        phaseDistortionRamper.reset();
        attackDurationRamper.reset();
        decayDurationRamper.reset();
        sustainLevelRamper.reset();
        releaseDurationRamper.reset();
        detuningOffsetRamper.reset();
        detuningMultiplierRamper.reset();
    }
    
    void setPhaseDistortion(float value) {
        phaseDistortion = clamp(value, -1.0f, 1.0f);
        phaseDistortionRamper.setImmediate(phaseDistortion);
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
    
    void setDetuningOffset(float value) {
        detuningOffset = clamp(value, (float)-1000, (float)1000);
        detuningOffsetRamper.setImmediate(detuningOffset);
    }

    void setDetuningMultiplier(float value) {
        detuningMultiplier = clamp(value, (float)0.5, (float)2.0);
        detuningMultiplierRamper.setImmediate(detuningMultiplier);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
                
            case phaseDistortionAddress:
                phaseDistortionRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;

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
                
            case detuningOffsetAddress:
                detuningOffsetRamper.setUIValue(clamp(value, (float)-1000, (float)1000));
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.setUIValue(clamp(value, (float)0.5, (float)2.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case phaseDistortionAddress:
                return phaseDistortionRamper.getUIValue();
                
            case attackDurationAddress:
                return attackDurationRamper.getUIValue();
                
            case decayDurationAddress:
                return decayDurationRamper.getUIValue();
                
            case sustainLevelAddress:
                return sustainLevelRamper.getUIValue();
                
            case releaseDurationAddress:
                return releaseDurationRamper.getUIValue();
            
            case detuningOffsetAddress:
                return detuningOffsetRamper.getUIValue();

            case detuningMultiplierAddress:
                return detuningMultiplierRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
                
            case phaseDistortionAddress:
                phaseDistortionRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;
                
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

            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, (float)-1000, (float)1000), duration);
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.startRamp(clamp(value, (float)0.5, (float)2.0), duration);
                break;

        }
    }

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }
    
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if (midiEvent.length != 3) return;
        uint8_t status = midiEvent.data[0] & 0xF0;
        //uint8_t channel = midiEvent.data[0] & 0x0F; // works in omni mode.
        switch (status) {
            case 0x80 : { // note off
                uint8_t note = midiEvent.data[1];
                if (note > 127) break;
                noteStates[note].noteOn(note, 0);
                break;
            }
            case 0x90 : { // note on
                uint8_t note = midiEvent.data[1];
                uint8_t veloc = midiEvent.data[2];
                if (note > 127 || veloc > 127) break;
                noteStates[note].noteOn(note, veloc);
                break;
            }
            case 0xB0 : { // control
                uint8_t num = midiEvent.data[1];
                if (num == 123) { // all notes off
                    NoteState* noteState = playingNotes;
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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        phaseDistortion = double(phaseDistortionRamper.getAndStep());
        attackDuration = attackDurationRamper.getAndStep();
        decayDuration = decayDurationRamper.getAndStep();
        sustainLevel = sustainLevelRamper.getAndStep();
        releaseDuration = releaseDurationRamper.getAndStep();
        detuningOffset = double(detuningOffsetRamper.getAndStep());
        detuningMultiplier = double(detuningMultiplierRamper.getAndStep());
        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] = 0.0f;
            outR[i] = 0.0f;
        }
        
        NoteState* noteState = playingNotes;
        while (noteState) {
            noteState->run(frameCount, outL, outR);
            noteState = noteState->next;
        }

        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] *= .5f;
            outR[i] *= .5f;
        }
    }

    // MARK: Member Variables

private:
    std::vector<NoteState> noteStates;

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    double frequencyScale = 2. * M_PI / sampleRate;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;
    
    float phaseDistortion = 0.0;

    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 1.0;
    float releaseDuration = 0.1;

    float detuningOffset = 0;
    float detuningMultiplier = 1;

public:
    NoteState* playingNotes = nullptr;
    int playingNotesCount = 0;
    bool resetted = false;

    ParameterRamper phaseDistortionRamper = 0.0;

    ParameterRamper attackDurationRamper = 0.1;
    ParameterRamper decayDurationRamper = 0.1;
    ParameterRamper sustainLevelRamper = 1.0;
    ParameterRamper releaseDurationRamper = 0.1;

    ParameterRamper detuningOffsetRamper = 0;
    ParameterRamper detuningMultiplierRamper = 1;
};

#endif /* AKPhaseDistortionOscillatorBankDSPKernel_hpp */
