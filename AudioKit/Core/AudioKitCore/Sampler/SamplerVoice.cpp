//
//  SamplerVoice.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "SamplerVoice.hpp"
#include <stdio.h>

namespace AudioKitCore
{
    void SamplerVoice::init(double sampleRate)
    {
        samplingRate = float(sampleRate);
        leftFilter.init(sampleRate);
        rightFilter.init(sampleRate);
        adsrEnvelope.init();
        filterEnvelope.init();
    }

    void SamplerVoice::start(unsigned note, float sampleRate, float frequency, float volume, SampleBuffer *buffer)
    {
        sampleBuffer = buffer;
        oscillator.indexPoint = buffer->startPoint;
        oscillator.increment = (buffer->sampleRate / sampleRate) * (frequency / buffer->noteFrequency);
        oscillator.multiplier = 1.0;
        oscillator.isLooping = buffer->isLooping;
        
        noteVolume = volume;
        adsrEnvelope.start();
        
        samplingRate = sampleRate;
        leftFilter.updateSampleRate(double(samplingRate));
        rightFilter.updateSampleRate(double(samplingRate));
        filterEnvelope.start();
        
        glideSemitones = 0.0f;
        if (*glideSecPerOctave != 0.0f && noteFrequency != 0.0 && noteFrequency != frequency)
        {
            // prepare to glide
            glideSemitones = -12.0f * log2f(frequency / noteFrequency);
            if (fabsf(glideSemitones) < 0.01f) glideSemitones = 0.0f;
        }
        noteFrequency = frequency;
        noteNumber = note;
    }
    
    void SamplerVoice::restart(unsigned note, float sampleRate, float frequency)
    {
        oscillator.increment = (sampleBuffer->sampleRate / sampleRate) * (frequency / sampleBuffer->noteFrequency);
        glideSemitones = 0.0f;
        if (*glideSecPerOctave != 0.0f && noteFrequency != 0.0 && noteFrequency != frequency)
        {
            // prepare to glide
            glideSemitones = -12.0f * log2f(frequency / noteFrequency);
            if (fabsf(glideSemitones) < 0.01f) glideSemitones = 0.0f;
        }
        noteFrequency = frequency;
        noteNumber = note;
    }

    void SamplerVoice::restart(float volume, SampleBuffer *buffer)
    {
        tempNoteVolume = noteVolume;
        newSampleBuffer = buffer;
        adsrEnvelope.restart();
        noteVolume = volume;
        filterEnvelope.restart();
    }
    
    void SamplerVoice::release(bool loopThruRelease)
    {
        if (!loopThruRelease) oscillator.isLooping = false;
        adsrEnvelope.release();
        filterEnvelope.release();
    }
    
    void SamplerVoice::stop()
    {
        noteNumber = -1;
        adsrEnvelope.reset();
        filterEnvelope.reset();
    }
    
    bool SamplerVoice::prepToGetSamples(int sampleCount, float masterVolume, float pitchOffset,
                                        float cutoffMultiple, float cutoffEnvelopeStrength,
                                        float resLinear)
    {
        if (adsrEnvelope.isIdle()) return true;

        if (adsrEnvelope.isPreStarting())
        {
            tempGain = masterVolume * tempNoteVolume * adsrEnvelope.getSample();
            if (!adsrEnvelope.isPreStarting())
            {
                tempGain = masterVolume * noteVolume * adsrEnvelope.getSample();
                sampleBuffer = newSampleBuffer;
                oscillator.indexPoint = sampleBuffer->startPoint;
                oscillator.isLooping = sampleBuffer->isLooping;
            }
        }
        else
            tempGain = masterVolume * noteVolume * adsrEnvelope.getSample();

        if (*glideSecPerOctave != 0.0f && glideSemitones != 0.0f)
        {
            float seconds = sampleCount / samplingRate;
            float semitones = 12.0f * seconds / *glideSecPerOctave;
            if (glideSemitones < 0.0f)
            {
                glideSemitones += semitones;
                if (glideSemitones > 0.0f) glideSemitones = 0.0f;
            }
            else
            {
                glideSemitones -= semitones;
                if (glideSemitones < 0.0f) glideSemitones = 0.0f;
            }
        }
        oscillator.setPitchOffsetSemitones(pitchOffset + glideSemitones);

        // negative value of cutoffMultiple means filters are disabled
        if (cutoffMultiple < 0.0f)
        {
            isFilterEnabled = false;
        }
        else
        {
            isFilterEnabled = true;
            double cutoffFrequency = noteFrequency * (1.0f + cutoffMultiple + cutoffEnvelopeStrength * filterEnvelope.getSample());
            leftFilter.setParameters(cutoffFrequency, resLinear);
            rightFilter.setParameters(cutoffFrequency, resLinear);
        }
        
        return false;
    }
    
    bool SamplerVoice::getSamples(int sampleCount, float *leftOutput, float *rightOutput)
    {
        for (int i=0; i < sampleCount; i++)
        {
            float leftSample, rightSample;
            if (oscillator.getSamplePair(sampleBuffer, sampleCount, &leftSample, &rightSample, tempGain)) return true;
            if (isFilterEnabled)
            {
                *leftOutput++ += leftFilter.process(leftSample);
                *rightOutput++ += rightFilter.process(rightSample);
            }
            else
            {
                *leftOutput++ += leftSample;
                *rightOutput++ += rightSample;
            }
        }
        return false;
    }

}
