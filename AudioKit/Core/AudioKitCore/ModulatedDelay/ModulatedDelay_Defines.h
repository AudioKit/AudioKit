//
//  AKModulatedDelay_Defines.h
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#pragma once

// Constants inherent to the definition of Chorus and Flanger effects
#define kChorusMinDelayMs       4.0f
#define kChorusMaxDelayMs       24.0f
#define kFlangerMinDelayMs      0.01f
#define kFlangerMaxDelayMs      10.0f

// Default parameter values: Chorus
#define kChorusDefaultModFreqHz     1.0f
#define kChorusMinModFreqHz         0.1f
#define kChorusMaxModFreqHz         10.0f
#define kChorusDefaultDepth         0.25f
#define kChorusDefaultFeedback      0.0f
#define kChorusDefaultMix           0.25

// Default parameter values: Flanger
#define kFlangerDefaultModFreqHz    1.0f
#define kFlangerMinModFreqHz        0.1f
#define kFlangerMaxModFreqHz        10.0f
#define kFlangerDefaultDepth        0.25f
#define kFlangerDefaultFeedback     0.0f
#define kFlangerDefaultMix          0.5f
