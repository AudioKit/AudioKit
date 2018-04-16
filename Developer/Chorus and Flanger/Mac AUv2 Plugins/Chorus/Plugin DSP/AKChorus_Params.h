//
//  AKChorus_Params.h
//  AKChorus AUv2 Plugin
//
//  Created by Shane Dunne, revision history on Githbub.
//

// Declare an enumeration of parameter-indices, which can be #include'd by both DSP (.cpp)
// and GUI (Objective-C) code.

#pragma once

// Parameters
enum
{
    kModFrequency = 0,
    kModDepth,
    kFeedback,
    kDryWetMix,

    kNumberOfParams
};
