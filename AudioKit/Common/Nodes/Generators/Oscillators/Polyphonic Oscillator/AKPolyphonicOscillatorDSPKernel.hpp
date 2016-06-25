//
//  AKPolyphonicOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPolyphonicOscillatorDSPKernel_hpp
#define AKPolyphonicOscillatorDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"
#import <vector>

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    detuningOffsetAddress = 2,
    detuningMultiplierAddress = 3
};

static inline double pow2(double x) {
    return x * x;
}

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

class AKPolyphonicOscillatorDSPKernel : public DSPKernel {
public:
    // MARK: Types
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        AKPolyphonicOscillatorDSPKernel* kernel;
        
        enum { stageOff, stageAttack, stageSustain, stageRelease };
        double oscFreq = 0.;
        double oscPhase = 0.;
        double envLevel = 0.;
        double envSlope = 0.;
        double ampL = 1.;
        double ampR = 1.;
        
        sp_data *sp;
        sp_osc *osc;
        sp_ftbl *ftbl;
        UInt32 ftbl_size = 4096;
        
        void init() {
            NSLog(@"Init NoteState");

            sp_create(&sp);
            sp->sr = 44100.; // AOP
            sp->nchan = 2; // AOP
            sp_ftbl_create(sp, &ftbl, 2048);  //AOP TEMP
            sp_osc_create(&osc);
            
            sp_gen_sine(sp, ftbl); //AOP TEMP
            sp_osc_init(sp, osc, ftbl, 0);
            osc->freq = 440;
            osc->amp = 1;
            NSLog(@"Finished Init NoteState");
        }
        
        int stage = stageOff;
        int envRampSamples = 0;
        
        void clear() {
            stage = stageOff;
            envLevel = 0.;
            oscPhase = 0.;
        }
        
        // linked list management
        void remove() {
            if (prev) prev->next = next;
            else kernel->playingNotes = next;
            
            if (next) next->prev = prev;
            
            prev = next = nullptr;
            
            --kernel->playingNotesCount;

            sp_osc_destroy(&osc);
            sp_destroy(&sp);

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
            NSLog(@"Got to the NoteState noteOn");
            if (velocity == 0) {
                if (stage == stageAttack || stage == stageSustain) {
                    stage = stageRelease;
//                    envRampSamples = kernel->releaseSamples;
//                    envSlope = -envLevel / envRampSamples;
                }
            } else {
                if (stage == stageOff) { add(); }
                oscFreq = noteToHz(noteNumber); //* kernel->frequencyScale;
//                double pan = (noteNumber - 66.) / 42.; // pan from note number
                double amp = pow2(velocity / 127.) * .2; // amplitude from velocity
                osc->freq = (float)oscFreq;
                osc->amp = (float)amp;
//                ampL = amp * panValue(-pan);
//                ampR = amp * panValue(pan);
//                oscPhase = 0.;
                stage = stageAttack;
//                envRampSamples = kernel->attackSamples;
//                envSlope = (1.0 - envLevel) / envRampSamples;
            }
        }
        
        
        void run(int n, float* outL, float* outR)
        {
            int framesRemaining = n;

            while (framesRemaining) {
                switch (stage) {
                    case stageOff :
                        NSLog(@"stageOff on playingNotes list!");
                        return;
                    case stageAttack : {
                        NSLog(@"attack %f %f", osc->freq, osc->amp);

                        int framesThisTime = std::min(framesRemaining, envRampSamples);
                        for (int i = 0; i < framesThisTime; ++i) {
                            float x = 0;
                            sp_osc_compute(sp, osc, nil, &x);
//                            double x = envLevel * pow3(sin(oscPhase)); // cubing the sine adds 3rd harmonic.
                            *outL++ += ampL * x;
                            *outR++ += ampR * x;
                            
                            envLevel += envSlope;
//                            oscPhase += oscFreq;
//                            if (oscPhase >= kTwoPi) oscPhase -= kTwoPi;
                        }
                        framesRemaining -= framesThisTime;
                        envRampSamples -= framesThisTime;
                        if (envRampSamples == 0) {
                            stage = stageSustain;
                        }
                        break;
                    }
                    case stageSustain : {
                        for (int i = 0; i < framesRemaining; ++i) {
                            float x = 0;
                            sp_osc_compute(sp, osc, nil, &x);
//                            double x = pow3(sin(oscPhase));
                            *outL++ += ampL * x;
                            *outR++ += ampR * x;
//                            oscPhase += oscFreq;
//                            if (oscPhase >= kTwoPi) oscPhase -= kTwoPi;
                        }
                        return;
                    }
                    case stageRelease : {
                        NSLog(@"rel");
                              
                        int framesThisTime = std::min(framesRemaining, envRampSamples);
                        for (int i = 0; i < framesThisTime; ++i) {
                            float x = 0;
                            sp_osc_compute(sp, osc, nil, &x);
//                            double x = envLevel * pow3(sin(oscPhase));
                            *outL++ += ampL * x;
                            *outR++ += ampR * x;
                            envLevel += envSlope;
//                            oscPhase += oscFreq;
                        }
                        envRampSamples -= framesThisTime;
                        if (envRampSamples == 0) {
                            clear();
                            remove();
                        }
                        return;
                    }
                    default:
                        NSLog(@"bad stage on playingNotes list!");
                        return;
                }
            }
        }
        
    };

    // MARK: Member Functions

    AKPolyphonicOscillatorDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
    }

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

//        sp_create(&sp);
//        sp->sr = sampleRate;
//        sp->nchan = channels;
//        sp_osc_create(&osc);
//        sp_osc_init(sp, osc, ftbl, 0);
//        osc->freq = 440;
//        osc->amp = 1;
    }

    void setupWaveform(uint32_t size) {
//        ftbl_size = size;
//        sp_ftbl_create(sp, &ftbl, ftbl_size);
    }

    void setWaveformValue(uint32_t index, float value) {
//        ftbl->tbl[index] = value;
    }

    void startNote(int note, int velocity) {
        NSLog(@"Got to the DSPKernal startNote");
        noteStates[note].noteOn(note, 127);
    }

    void stopNote(int note) {
        noteStates[note].noteOn(note, 0);
    }

    void destroy() {
//        sp_osc_destroy(&osc);
//        sp_destroy(&sp);
    }

    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        playingNotesCount = 0;
        resetted = true;
    }

    void setDetuningOffset(float value) {
        detuningOffset = clamp(value, (float)-1000, (float)1000);
        detuningOffsetRamper.setImmediate(detuningOffset);
    }

    void setDetuningMultiplier(float value) {
        detuningMultiplier = clamp(value, (float)0.9, (float)1.11);
        detuningMultiplierRamper.setImmediate(detuningMultiplier);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {

            case detuningOffsetAddress:
                detuningOffsetRamper.setUIValue(clamp(value, (float)-1000, (float)1000));
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.setUIValue(clamp(value, (float)0.9, (float)1.11));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case detuningOffsetAddress:
                return detuningOffsetRamper.getUIValue();

            case detuningMultiplierAddress:
                return detuningMultiplierRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {

            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, (float)-1000, (float)1000), duration);
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.startRamp(clamp(value, (float)0.9, (float)1.11), duration);
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
        
        NoteState* noteState = playingNotes;
        while (noteState) {
            noteState->run(frameCount, outL, outR);
            noteState = noteState->next;
        }

        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] *= .1f;
            outR[i] *= .1f;
        }
        
//        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
//            int frameOffset = int(frameIndex + bufferOffset);
//
//            detuningOffset = double(detuningOffsetRamper.getAndStep());
//            detuningMultiplier = double(detuningMultiplierRamper.getAndStep());
//
//            osc->freq = frequency * detuningMultiplier + detuningOffset;
//            osc->amp = amplitude;
//
//            float temp = 0;
//            for (int channel = 0; channel < channels; ++channel) {
//                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
//                if (started) {
//                    if (channel == 0) {
//                        sp_osc_compute(sp, osc, nil, &temp);
//                    }
//                    *out = temp;
//                } else {
//                    *out = 0.0;
//                }
//            }
//        }
    }

    // MARK: Member Variables

private:
    std::vector<NoteState> noteStates;

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    double frequencyScale = 2. * M_PI / sampleRate;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;
    
    float detuningOffset = 0;
    float detuningMultiplier = 1;

public:
    NoteState* playingNotes = nullptr;
    int playingNotesCount = 0;
    bool resetted = false;
    
    ParameterRamper detuningOffsetRamper = 0;
    ParameterRamper detuningMultiplierRamper = 1;
};

#endif /* AKPolyphonicOscillatorDSPKernel_hpp */
