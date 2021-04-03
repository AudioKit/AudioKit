// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SamplerVoice.h"
#include <stdio.h>

#define MIDDLE_C_HZ 262.626f

namespace AudioKitCore
{
    void SamplerVoice::init(double sampleRate)
    {
        samplingRate = float(sampleRate);
        leftFilter.init(sampleRate);
        rightFilter.init(sampleRate);
        ampEnvelope.init();
        filterEnvelope.init();
        pitchEnvelope.init();
        vibratoLFO.waveTable.sinusoid();
        vibratoLFO.init(sampleRate/CORESAMPLER_CHUNKSIZE, 5.0f);
        restartVoiceLFO = false;
        volumeRamper.init(0.0f);
        tempGain = 0.0f;
    }

    void SamplerVoice::start(unsigned note, float sampleRate, float frequency, float volume, SampleBuffer *buffer)
    {
        sampleBuffer = buffer;
        oscillator.indexPoint = buffer->startPoint;
        oscillator.increment = (buffer->sampleRate / sampleRate) * (frequency / buffer->noteFrequency);
        oscillator.multiplier = 1.0;
        oscillator.isLooping = buffer->isLooping;
        
        noteVolume = volume;
        ampEnvelope.start();
        volumeRamper.init(0.0f);
        
        samplingRate = sampleRate;
        leftFilter.updateSampleRate(double(samplingRate));
        rightFilter.updateSampleRate(double(samplingRate));
        filterEnvelope.start();

        pitchEnvelope.start();

        pitchEnvelopeSemitones = 0.0f;

        voiceLFOSemitones = 0.0f;

        glideSemitones = 0.0f;
        if (*glideSecPerOctave != 0.0f && noteFrequency != 0.0 && noteFrequency != frequency)
        {
            // prepare to glide
            glideSemitones = -12.0f * log2f(frequency / noteFrequency);
            if (fabsf(glideSemitones) < 0.01f) glideSemitones = 0.0f;
        }
        noteFrequency = frequency;
        noteNumber = note;

        restartVoiceLFOIfNeeded();
    }
    
    void SamplerVoice::restartNewNote(unsigned note, float sampleRate, float frequency, float volume, SampleBuffer *buffer)
    {
        samplingRate = sampleRate;
        leftFilter.updateSampleRate(double(samplingRate));
        rightFilter.updateSampleRate(double(samplingRate));

        oscillator.increment = (sampleBuffer->sampleRate / sampleRate) * (frequency / sampleBuffer->noteFrequency);
        glideSemitones = 0.0f;
        if (*glideSecPerOctave != 0.0f && noteFrequency != 0.0 && noteFrequency != frequency)
        {
            // prepare to glide
            glideSemitones = -12.0f * log2f(frequency / noteFrequency);
            if (fabsf(glideSemitones) < 0.01f) glideSemitones = 0.0f;
        }

        pitchEnvelopeSemitones = 0.0f;

        voiceLFOSemitones = 0.0f;

        noteFrequency = frequency;
        noteNumber = note;
        tempNoteVolume = noteVolume;
        newSampleBuffer = buffer;
        ampEnvelope.restart();
        noteVolume = volume;
        filterEnvelope.restart();
        pitchEnvelope.restart();
        restartVoiceLFOIfNeeded();
    }

    void SamplerVoice::restartNewNoteLegato(unsigned note, float sampleRate, float frequency)
    {
        samplingRate = sampleRate;
        leftFilter.updateSampleRate(double(samplingRate));
        rightFilter.updateSampleRate(double(samplingRate));

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

    void SamplerVoice::restartSameNote(float volume, SampleBuffer *buffer)
    {
        tempNoteVolume = noteVolume;
        newSampleBuffer = buffer;
        ampEnvelope.restart();
        noteVolume = volume;
        filterEnvelope.restart();
        pitchEnvelope.restart();
        restartVoiceLFOIfNeeded();
    }
    
    void SamplerVoice::release(bool loopThruRelease)
    {
        if (!loopThruRelease) oscillator.isLooping = false;
        ampEnvelope.release();
        filterEnvelope.release();
        pitchEnvelope.release();
    }
    
    void SamplerVoice::stop()
    {
        noteNumber = -1;
        ampEnvelope.reset();
        volumeRamper.init(0.0f);
        filterEnvelope.reset();
        pitchEnvelope.reset();
    }

    bool SamplerVoice::prepToGetSamples(int sampleCount, float masterVolume, float pitchOffset,
                                        float cutoffMultiple, float keyTracking,
                                        float cutoffEnvelopeStrength, float cutoffEnvelopeVelocityScaling,
                                        float resLinear, float pitchADSRSemitones,
                                        float voiceLFODepthSemitones, float voiceLFOFrequencyHz)
    {
        if (ampEnvelope.isIdle()) return true;

        if (ampEnvelope.isPreStarting())
        {
            tempGain = masterVolume * tempNoteVolume;
            volumeRamper.reinit(ampEnvelope.getSample(), sampleCount);
            // This can execute as part of the voice-stealing mechanism, and will be executed rarely.
            // To test, set MAX_POLYPHONY in CoreSampler.cpp to something small like 2 or 3.
            if (!ampEnvelope.isPreStarting())
            {
                tempGain = masterVolume * noteVolume;
                volumeRamper.reinit(ampEnvelope.getSample(), sampleCount);
                sampleBuffer = newSampleBuffer;
                oscillator.increment = (sampleBuffer->sampleRate / samplingRate) * (noteFrequency / sampleBuffer->noteFrequency);
                oscillator.indexPoint = sampleBuffer->startPoint;
                oscillator.isLooping = sampleBuffer->isLooping;
            }
        }
        else
        {
            tempGain = masterVolume * noteVolume;
            volumeRamper.reinit(ampEnvelope.getSample(), sampleCount);
        }

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

        float pitchCurveAmount = 1.0f; // >1 = faster curve, 0 < curve < 1 = slower curve - make this a parameter
        if (pitchCurveAmount < 0) { pitchCurveAmount = 0; }
        pitchEnvelopeSemitones = pow(pitchEnvelope.getSample(), pitchCurveAmount) * pitchADSRSemitones;

        vibratoLFO.setFrequency(voiceLFOFrequencyHz);
        voiceLFOSemitones = vibratoLFO.getSample() * voiceLFODepthSemitones;

        float pitchOffsetModified = pitchOffset + glideSemitones + pitchEnvelopeSemitones + voiceLFOSemitones;
        oscillator.setPitchOffsetSemitones(pitchOffsetModified);

        // negative value of cutoffMultiple means filters are disabled
        if (cutoffMultiple < 0.0f)
        {
            isFilterEnabled = false;
        }
        else
        {
            isFilterEnabled = true;
            float noteHz = noteFrequency * powf(2.0f, (pitchOffsetModified) / 12.0f);
            float baseFrequency = MIDDLE_C_HZ + keyTracking * (noteHz - MIDDLE_C_HZ);
            float envStrength = ((1.0f - cutoffEnvelopeVelocityScaling) + cutoffEnvelopeVelocityScaling * noteVolume);
            double cutoffFrequency = baseFrequency * (1.0f + cutoffMultiple + cutoffEnvelopeStrength * envStrength * filterEnvelope.getSample());
            leftFilter.setParameters(cutoffFrequency, resLinear);
            rightFilter.setParameters(cutoffFrequency, resLinear);
        }
        
        return false;
    }
    
    bool SamplerVoice::getSamples(int sampleCount, float *leftOutput, float *rightOutput)
    {
        for (int i=0; i < sampleCount; i++)
        {
            float gain = tempGain * volumeRamper.getNextValue();
            float leftSample, rightSample;
            if (oscillator.getSamplePair(sampleBuffer, sampleCount, &leftSample, &rightSample, gain))
                return true;
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

    void SamplerVoice::restartVoiceLFOIfNeeded() {
        if (restartVoiceLFO || !hasStartedVoiceLFO) {
            vibratoLFO.phase = 0;
            hasStartedVoiceLFO = true;
        }
    }

}
