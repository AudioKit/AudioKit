//
//  SynthVoice.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "SynthVoice.hpp"
#include <stdio.h>

namespace AudioKitCore
{

    void SynthVoice::init(double sampleRate, WaveStack *pOsc1Stack, WaveStack* pOsc2Stack, WaveStack* pOsc3Stack, SynthVoiceParameters *pParams, EnvelopeParameters* pEnvParameters)
    {
        pParameters = pParams;
        event = 0;
        noteNumber = -1;

        osc1.init(sampleRate, pOsc1Stack);
        osc1.setPhases(pParameters->osc1.phases);
        osc1.setFreqSpread(pParameters->osc1.freqSpread);
        osc1.setPanSpread(pParameters->osc1.panSpread);

        osc2.init(sampleRate, pOsc2Stack);
        osc2.setPhases(pParameters->osc2.phases);
        osc2.setFreqSpread(pParameters->osc2.freqSpread);
        osc2.setPanSpread(pParameters->osc2.panSpread);

        osc3.init(sampleRate, pOsc3Stack);
        osc3.setDrawbars(pParameters->osc3.drawbars);

        fltL.init(sampleRate);
        fltR.init(sampleRate);
        fltL.setStages(pParameters->filterStages);
        fltR.setStages(pParameters->filterStages);

        ampEG.init();
        filterEG.init();
        pumpEG.init(pEnvParameters);
    }

    void SynthVoice::start(unsigned evt, unsigned noteNum, float freqHz, float volume)
    {
        event = evt;
        noteVol = volume;
        osc1.setFrequency(freqHz * pow(2.0f, pParameters->osc1.pitchOffset / 12.0f));
        osc2.setFrequency(freqHz * pow(2.0f, pParameters->osc2.pitchOffset / 12.0f));
        osc3.setFrequency(freqHz);
        ampEG.start();
        filterEG.start();
        pumpEG.start();
        
        noteHz = freqHz;
        noteNumber = noteNum;
    }
    
    void SynthVoice::restart(unsigned evt, float volume)
    {
        event = evt;
        newNoteNumber = -1;
        newNoteVol = volume;
        ampEG.restart();
        pumpEG.restart();
    }
    
    void SynthVoice::restart(unsigned evt, unsigned noteNum, float freqHz, float volume)
    {
        event = evt;
        newNoteNumber = noteNum;
        newNoteVol = volume;
        noteHz = freqHz;
        ampEG.restart();
        pumpEG.restart();
    }

    void SynthVoice::release(unsigned evt)
    {
        event = evt;
        ampEG.release();
        filterEG.release();
        pumpEG.release();
    }
    
    void SynthVoice::stop(unsigned evt)
    {
        event = evt;
        noteNumber = -1;
        ampEG.reset();
        filterEG.reset();
        pumpEG.reset();
    }
    
    bool SynthVoice::prepToGetSamples(float masterVol, float phaseDeltaMul,
                                      float cutoffMultiple, float cutoffEgStrength,
                                      float resLinear)
    {
        if (ampEG.isIdle()) return true;

        if (ampEG.isPreStarting())
        {
            float ampeg = ampEG.getSample();
            tempGain = masterVol * noteVol * ampeg;
            if (!ampEG.isPreStarting())
            {
                noteVol = newNoteVol;
                tempGain = masterVol * noteVol * ampeg;

                if (newNoteNumber >= 0)
                {
                    // restarting a "stolen" voice with a new note number
                    osc1.setFrequency(noteHz * pow(2.0f, pParameters->osc1.pitchOffset / 12.0f));
                    osc2.setFrequency(noteHz * pow(2.0f, pParameters->osc2.pitchOffset / 12.0f));
                    osc3.setFrequency(noteHz);
                    noteNumber = newNoteNumber;
                }
                ampEG.start();
                filterEG.start();
                pumpEG.start();
            }
        }
        else
            tempGain = masterVol * noteVol * ampEG.getSample();

#if 0
        // pumping effect using multi-segment EG
        float pump = pumpEG.getSample();
        double cutoffHz = noteHz * (1.0f + cutoffMultiple + cutoffEgStrength * pump);
#else
        // standard ADSR EG
        double cutoffHz = noteHz * (1.0f + cutoffMultiple + cutoffEgStrength * filterEG.getSample());
#endif
        fltL.setParameters(cutoffHz, resLinear);
        fltR.setParameters(cutoffHz, resLinear);

        osc1.phaseDeltaMul = phaseDeltaMul;
        osc2.phaseDeltaMul = phaseDeltaMul;
        osc3.phaseDeltaMul = phaseDeltaMul;

        return false;
    }
    
    bool SynthVoice::getSamples(int nSamples, float* pOutLeft, float* pOutRight)
    {
        for (int i=0; i < nSamples; i++)
        {
            float leftSample = 0.0f;
            float rightSample = 0.0f;
            osc1.getSamples(&leftSample, &rightSample, pParameters->osc1.mixLevel);
            osc2.getSamples(&leftSample, &rightSample, pParameters->osc2.mixLevel);
            osc3.getSamples(&leftSample, &rightSample, pParameters->osc3.mixLevel);

            if (pParameters->filterStages == 0)
            {
                *pOutLeft++ += tempGain * leftSample;
                *pOutRight++ += tempGain * rightSample;
            }
            else
            {
                *pOutLeft++ += fltL.process(tempGain * leftSample);
                *pOutRight++ += fltR.process(tempGain * rightSample);
            }
        }
        return false;
    }

}
