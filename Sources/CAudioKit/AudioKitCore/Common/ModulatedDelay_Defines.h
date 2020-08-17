// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

// MARK: - Constants inherent to the definition of Chorus and Flanger effects

// MARK: Chorus Inherent Constants
#define kChorusMinDelayMs            4.00f
#define kChorusMaxDelayMs           24.00f

// MARK: Flanger Inherent Constants
#define kFlangerMinDelayMs           0.01f
#define kFlangerMaxDelayMs          10.00f
#define kFlangerDefaultMix           0.50f // Conventionally, flanger uses a 50% mix

// MARK: - Suggested default values

// MARK: Chorus Defaults
#define kChorusDefaultModFreqHz      1.00f
#define kChorusDefaultDepth          0.25f
#define kChorusDefaultFeedback       0.00f
#define kChorusDefaultMix            0.25f

// MARK: Flanger Defaults
#define kFlangerDefaultModFreqHz     1.00f
#define kFlangerMinModFreqHz         0.10f
#define kFlangerMaxModFreqHz        10.00f
#define kFlangerDefaultDepth         0.25f
#define kFlangerDefaultFeedback      0.00f

// MARK: - Suggested ranges

// MARK: Chorus Ranges
#define kChorusMinModFreqHz          0.10f
#define kChorusMaxModFreqHz         10.00f
#define kChorusMinDepth              0.00f
#define kChorusMaxDepth              1.00f
#define kChorusMinFeedback           0.00f
#define kChorusMaxFeedback           0.95f
#define kChorusMinDryWetMix          0.00f
#define kChorusMaxDryWetMix          1.00f

// MARK: Flanger Ranges
#define kFlangerMinModFreqHz         0.10f
#define kFlangerMaxModFreqHz        10.00f
#define kFlangerMinDepth             0.00f
#define kFlangerMaxDepth             1.00f
#define kFlangerMinFeedback         -0.95f
#define kFlangerMaxFeedback          0.95f
#define kFlangerMinDryWetMix         0.00f
#define kFlangerMaxDryWetMix         1.00f

