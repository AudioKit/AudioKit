//
//  Synth.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "Synth.hpp"
#include "FunctionTable.hpp"
#include <math.h>

namespace AudioKitCore {
    
    Synth::Synth()
    : eventCounter(0)
    , masterVolume(1.0f)
    , pitchOffset(0.0f)
    , vibratoDepth(0.0f)
    , cutoffMultiple(4.0f)
    , cutoffEgStrength(20.0f)
    , resLinear(1.0f)
    {
        for (int i=0; i < MAX_VOICE_COUNT; i++)
        {
            voice[i].event = 0;
            voice[i].noteNumber = -1;
            voice[i].ampEG.pParameters = &ampEGParameters;
            voice[i].filterEG.pParameters = &filterEGParameters;
        }
    }
    
    Synth::~Synth()
    {
    }
    
    int Synth::init(double sampleRate)
    {
        FunctionTable waveform;
        int length = 1 << WaveStack::maxBits;
        waveform.init(length);
        waveform.sawtooth(0.2f);
        waveform1.initStack(waveform.pWaveTable);
        waveform.square(0.4f, 0.01f);
        waveform2.initStack(waveform.pWaveTable);
        waveform.triangle(0.5f);
        waveform3.initStack(waveform.pWaveTable);

        ampEGParameters.updateSampleRate((float)(sampleRate/CHUNKSIZE));
        filterEGParameters.updateSampleRate((float)(sampleRate/CHUNKSIZE));

        vibratoLFO.waveTable.sinusoid();
        vibratoLFO.init(sampleRate/CHUNKSIZE, 5.0f);

        voiceParameters.osc1.phases = 4;
        voiceParameters.osc1.freqSpread = 25.0f;
        voiceParameters.osc1.panSpread = 0.95f;
        voiceParameters.osc1.pitchOffset = 0.0f;
        voiceParameters.osc1.mixLevel = 0.7f;

        voiceParameters.osc2.phases = 2;
        voiceParameters.osc2.freqSpread = 15.0f;
        voiceParameters.osc2.panSpread = 1.0f;
        voiceParameters.osc2.pitchOffset = -12.0f;
        voiceParameters.osc2.mixLevel = 0.6f;

        voiceParameters.osc3.drawbars[0] = 0.6f;
        voiceParameters.osc3.drawbars[1] = 1.0f;
        voiceParameters.osc3.drawbars[2] = 1.0;
        voiceParameters.osc3.drawbars[3] = 1.0f;
        voiceParameters.osc3.drawbars[4] = 0.0f;
        voiceParameters.osc3.drawbars[5] = 0.0f;
        voiceParameters.osc3.drawbars[6] = 0.4f;
        voiceParameters.osc3.drawbars[7] = 0.0f;
        voiceParameters.osc3.drawbars[8] = 0.0f;
        voiceParameters.osc3.drawbars[8] = 0.0f;
        voiceParameters.osc3.drawbars[10] = 0.0f;
        voiceParameters.osc3.drawbars[11] = 0.0f;
        voiceParameters.osc3.drawbars[12] = 0.0f;
        voiceParameters.osc3.drawbars[13] = 0.0f;
        voiceParameters.osc3.drawbars[14] = 0.0f;
        voiceParameters.osc3.drawbars[15] = 0.0f;
        voiceParameters.osc3.mixLevel = 0.5f;

        voiceParameters.filterStages = 2;

        segParameters[0].initialLevel = 0.0f;   // attack: ramp quickly to 0.2
        segParameters[0].finalLevel = 0.2f;
        segParameters[0].seconds = 0.01f;
        segParameters[1].initialLevel = 0.2f;   // hold at 0.2 for 1 sec
        segParameters[1].finalLevel = 0.2;
        segParameters[1].seconds = 1.0f;
        segParameters[2].initialLevel = 0.2f;   // decay: fall to 0.0 in 0.5 sec
        segParameters[2].finalLevel = 0.0f;
        segParameters[2].seconds = 0.5f;
        segParameters[3].initialLevel = 0.0f;   // sustain pump up: up to 1.0 in 0.1 sec
        segParameters[3].finalLevel = 1.0f;
        segParameters[3].seconds = 0.1f;
        segParameters[4].initialLevel = 1.0f;   // sustain pump down: down to 0 again in 0.5 sec
        segParameters[4].finalLevel = 0.0f;
        segParameters[4].seconds = 0.5f;
        segParameters[5].initialLevel = 0.0f;   // release: from wherever we leave off
        segParameters[5].finalLevel = 0.0f;     // down to 0
        segParameters[5].seconds = 0.5f;        // in 0.5 sec

        envParameters.init((float)(sampleRate/CHUNKSIZE), 6, segParameters, 3, 0, 5);

        for (int i=0; i < MAX_VOICE_COUNT; i++)
        {
            voice[i].init(sampleRate, &waveform1, &waveform2, &waveform3, &voiceParameters, &envParameters);
        }

        return 0;   // no error
    }
    
    void Synth::deinit()
    {
    }

    void Synth::playNote(unsigned noteNumber, unsigned velocity, float noteHz)
    {
        eventCounter++;
        pedalLogic.keyDownAction(noteNumber);
        play(noteNumber, velocity, noteHz);
    }
    
    void Synth::stopNote(unsigned noteNumber, bool immediate)
    {
        eventCounter++;
        if (immediate || pedalLogic.keyUpAction(noteNumber))
            stop(noteNumber, immediate);
    }
    
    void Synth::sustainPedal(bool down)
    {
        eventCounter++;
        if (down) pedalLogic.pedalDown();
        else {
            for (int nn=0; nn < MIDI_NOTENUMBERS; nn++)
            {
                if (pedalLogic.isNoteSustaining(nn))
                    stop(nn, false);
            }
            pedalLogic.pedalUp();
        }
    }

    SynthVoice *Synth::voicePlayingNote(unsigned noteNumber)
    {
        SynthVoice *pVoice = voice;
        for (int i=0; i < MAX_VOICE_COUNT; i++, pVoice++)
        {
            if (pVoice->noteNumber == noteNumber) return pVoice;
        }
        return 0;
    }
    
    void Synth::play(unsigned noteNumber, unsigned velocity, float noteHz)
    {
        //printf("playNote nn=%d vel=%d %.2f Hz\n", noteNumber, velocity, noteHz);

        // is any voice already playing this note?
        SynthVoice *pVoice = voicePlayingNote(noteNumber);
        if (pVoice)
        {
            // re-start the note
            pVoice->restart(eventCounter, velocity / 127.0f);
            //printf("Restart note %d as %d\n", noteNumber, pVoice->noteNumber);
            return;
        }
        
        // find a free voice (with noteNumber < 0) to play the note
        for (int i=0; i < MAX_VOICE_COUNT; i++)
        {
            SynthVoice *pVoice = &voice[i];
            if (pVoice->noteNumber < 0)
            {
                // found a free voice: assign it to play this note
                pVoice->start(eventCounter, noteNumber, noteHz, velocity / 127.0f);
                //printf("Play note %d (%.2f Hz) vel %d\n", noteNumber, noteHz, velocity);
                return;
            }
        }
        
        // all oscillators in use: find "stalest" voice to steal
        unsigned greatestDiffOfAll = 0;
        SynthVoice *pStalestVoiceOfAll = 0;
        unsigned greatestDiffInRelease = 0;
        SynthVoice *pStalestVoiceInRelease = 0;
        for (int i=0; i < MAX_VOICE_COUNT; i++)
        {
            SynthVoice *pVoice = &voice[i];
            unsigned diff = eventCounter - pVoice->event;
            if (pVoice->ampEG.isReleasing())
            {
                if (diff > greatestDiffInRelease)
                {
                    greatestDiffInRelease = diff;
                    pStalestVoiceInRelease = pVoice;
                }
            }
            if (diff > greatestDiffOfAll)
            {
                greatestDiffOfAll = diff;
                pStalestVoiceOfAll = pVoice;
            }
        }

        if (pStalestVoiceInRelease != 0)
        {
            // We have a stalest note in its release phase: restart that one
            pStalestVoiceInRelease->restart(eventCounter, noteNumber, noteHz, velocity / 127.0f);
        }
        else
        {
            // No notes in release phase: restart the "stalest" one we could find
            pStalestVoiceOfAll->restart(eventCounter, noteNumber, noteHz, velocity / 127.0f);
        }
    }
    
    void Synth::stop(unsigned noteNumber, bool immediate)
    {
        //printf("stopNote nn=%d %s\n", noteNumber, immediate ? "immediate" : "release");
        SynthVoice *pVoice = voicePlayingNote(noteNumber);
        if (pVoice == 0) return;
        //printf("stopNote pVoice is %p\n", pVoice);
        
        if (immediate)
        {
            pVoice->stop(eventCounter);
            //printf("Stop note %d immediate\n", noteNumber);
        }
        else
        {
            pVoice->release(eventCounter);
            //printf("Stop note %d release\n", noteNumber);
        }
    }
    
    void Synth::Render(unsigned channelCount, unsigned sampleCount, float *outBuffers[])
    {
        float *pOutLeft = outBuffers[0];
        float *pOutRight = outBuffers[1];
        
        float pitchDev = pitchOffset + vibratoDepth * vibratoLFO.getSample();
        float phaseDeltaMul = pow(2.0f, pitchDev / 12.0);

        SynthVoice *pVoice = &voice[0];
        for (int i=0; i < MAX_VOICE_COUNT; i++, pVoice++)
        {
            int nn = pVoice->noteNumber;
            if (nn >= 0)
            {
                if (pVoice->prepToGetSamples(masterVolume, phaseDeltaMul, cutoffMultiple, cutoffEgStrength, resLinear) ||
                    pVoice->getSamples(sampleCount, pOutLeft, pOutRight))
                {
                    stopNote(nn, true);
                }
            }
        }
    }
}
