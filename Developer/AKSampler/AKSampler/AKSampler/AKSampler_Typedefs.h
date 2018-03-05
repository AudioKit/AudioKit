//
//  AKSampler_Typedefs.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne on 2018-03-04.
//
// This file is safe to include in either (Objective-)C or C++ contexts.

#pragma once

typedef struct
{
    int noteNumber;
    float noteHz;
    
    int min_note, max_note;
    int min_vel, max_vel;
    
    bool bLoop;
    float fLoopStart, fLoopEnd;
    float fStart, fEnd;

} AKSampleDescriptor;

typedef struct
{
    AKSampleDescriptor sd;
    
    float sampleRateHz;
    bool bInterleaved;
    int nChannels;
    int nSamples;
    float *pData;

} AKSampleDataDescriptor;

typedef struct
{
    AKSampleDescriptor sd;
    
    const char* path;
    
} AKSampleFileDescriptor;
