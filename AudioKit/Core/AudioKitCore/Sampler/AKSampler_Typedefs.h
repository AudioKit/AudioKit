//
//  AKSampler_Typedefs.h
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
// This file is safe to include in either (Objective-)C or C++ contexts.

#pragma once

typedef struct
{
    int noteNumber;
    float noteFrequency;
    
    int minimumNoteNumber, maximumNoteNumber;
    int minimumVelocity, maximumVelocity;
    
    bool isLooping;
    float loopStartPoint, loopEndPoint;
    float startPoint, endPoint;

} AKSampleDescriptor;

typedef struct
{
    AKSampleDescriptor sampleDescriptor;
    
    float sampleRate;
    bool isInterleaved;
    int channelCount;
    int sampleCount;
    float *data;

} AKSampleDataDescriptor;

typedef struct
{
    AKSampleDescriptor sampleDescriptor;
    
    const char *path;
    
} AKSampleFileDescriptor;
