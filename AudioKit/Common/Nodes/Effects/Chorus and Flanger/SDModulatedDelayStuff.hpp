//
//  SDModulatedDelayStuff.hpp
//  AudioKit For macOS
//
//  Created by Shane Dunne on 2018-01-20.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifndef SDModulatedDelayStuff_h
#define SDModulatedDelayStuff_h

#include <math.h>

class SDDelayLine {
    double sampleRateHz;
    float fbFraction;
    float *pBuffer;
    int capacity;
    int writeIndex;
    float readIndex;
    
public:
    SDDelayLine() {
        pBuffer = 0;
    }
    
    ~SDDelayLine() {
        if (pBuffer) delete[] pBuffer;
    }
    
    void init(double sampleRate, double maxDelayMs) {
        sampleRateHz = sampleRate;
        capacity = int(maxDelayMs * sampleRateHz / 1000.0);
        pBuffer = new float[capacity];
        for (int i=0; i < capacity; i++) pBuffer[i] = 0.0f;
        writeIndex = 0;
        readIndex = capacity - 1;
    }
    
    void setDelayMs(double delayMs) {
        float fReadWriteGap = float(delayMs * sampleRateHz / 1000.0);
        if (fReadWriteGap < 0.0f) fReadWriteGap = 0.0f;
        if (fReadWriteGap > capacity) fReadWriteGap = capacity;
        readIndex = writeIndex - fReadWriteGap;
        while (readIndex < 0.0f) readIndex += capacity;
    }
    
    void setFeedback(float feedback) {
        fbFraction = feedback;
    }
    
    float push(float sample) {
        if (!pBuffer) return sample;
        
        int ri = int(readIndex);
        float f = readIndex - ri;
        int rj = ri + 1; if (rj >= capacity) rj -= capacity;
        readIndex += 1.0f;
        if (readIndex >= capacity) readIndex -= capacity;
        
        float si = pBuffer[ri];
        float sj = pBuffer[rj];
        float outSample = (1.0 - f) * si + f * sj;
        
        pBuffer[writeIndex++] = sample + fbFraction * outSample;
        if (writeIndex >= capacity) writeIndex = 0;

        return outSample;
    }
    
};

class SDWaveTable {
    float *pWaveTable;
    int nTableSize;
    
public:
    SDWaveTable() {
        pWaveTable = 0;
        nTableSize = 0;
    }
    
    ~SDWaveTable() {
        if (pWaveTable) delete[] pWaveTable;
    }
    
    void init(int tableLength) {
        if (nTableSize == tableLength) return;
        nTableSize = tableLength;
        if (pWaveTable) delete[] pWaveTable;
        pWaveTable = new float[tableLength];
    }
    
    void initSinusoid(int tableLength) {
        init(tableLength);
        for (int i=0; i < tableLength; i++)
            pWaveTable[i] = sin(double(i)/tableLength * 2.0 * M_PI);
    }
    
    void initTriangle(int tableLength) {
        init(tableLength);
        for (int i=0; i < tableLength; i++)
            pWaveTable[i] = 2.0f * (0.5f - fabs((double(i)/tableLength) - 0.5)) - 1.0f;
    }
    
    float interp(float phase) {
        while (phase < 0) phase += 1.0;
        while (phase >= 1.0) phase -= 1.0f;
        
        float readIndex = phase * nTableSize;
        int ri = int(readIndex);
        float f = readIndex - ri;
        int rj = ri + 1; if (rj >= nTableSize) rj -= nTableSize;
        
        float si = pWaveTable[ri];
        float sj = pWaveTable[rj];
        return (1.0 - f) * si + f * sj;
    }
};

class SDTwoPhaseOscillator {
    double sampleRateHz;
    float phase;
    float phaseDelta;   // normalized frequency: cycles per sample
    SDWaveTable waveTable;
    
    void init(double sampleRate, float frequency, int tableLength) {
        sampleRateHz = sampleRate;
        phase = 0.0f;
        phaseDelta = frequency / sampleRate;
    }
    
public:
    void initSinusoid(double sampleRate, float frequency, int tableLength=256) {
        init(sampleRate, frequency, tableLength);
        waveTable.initSinusoid(tableLength);
    }
    
    void initTriangle(double sampleRate, float frequency, int tableLength=256) {
        init(sampleRate, frequency, tableLength);
        waveTable.initTriangle(tableLength);
    }
    
    void setFrequency(float frequency) {
        phaseDelta = frequency / sampleRateHz;
    }
    
    void getSamples(float* pSin, float* pCos) {
        *pSin = waveTable.interp(phase);
        *pCos = waveTable.interp(phase + 0.25f);
        phase += phaseDelta;
        if (phase >= 1.0f) phase -= 1.0f;
    }
    
};

#endif /* SDModulatedDelayStuff_h */
