//
//  AudioKit.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for AudioKit.
FOUNDATION_EXPORT double AudioKitVersionNumber;

//! Project version string for AudioKit.
FOUNDATION_EXPORT const unsigned char AudioKitVersionString[];

#import <AudioKit/AKTrackedAmplitudeAudioUnit.h>
#import <AudioKit/AKBandPassButterworthFilterAudioUnit.h>
#import <AudioKit/AKBandRejectButterworthFilterAudioUnit.h>
#import <AudioKit/AKHighPassButterworthFilterAudioUnit.h>
#import <AudioKit/AKLowPassButterworthFilterAudioUnit.h>
#import <AudioKit/AKClipperAudioUnit.h>
#import <AudioKit/AKCombFilterAudioUnit.h>
#import <AudioKit/AKBitCrusherAudioUnit.h>
#import <AudioKit/AKTanhDistortionAudioUnit.h>
#import <AudioKit/AKVariableDelayAudioUnit.h>
#import <AudioKit/AKDCBlockAudioUnit.h>
#import <AudioKit/AKEqualizerFilterAudioUnit.h>
#import <AudioKit/AKFlatFrequencyResponseReverbAudioUnit.h>
#import <AudioKit/AKFormantFilterAudioUnit.h>
#import <AudioKit/AKToneComplementFilterAudioUnit.h>
#import <AudioKit/AKHighShelfParametricEqualizerFilterAudioUnit.h>
#import <AudioKit/AKToneFilterAudioUnit.h>
#import <AudioKit/AKLowShelfParametricEqualizerFilterAudioUnit.h>
#import <AudioKit/AKPeakingParametricEqualizerFilterAudioUnit.h>
#import <AudioKit/AKStringResonatorAudioUnit.h>
#import <AudioKit/AKRolandTB303FilterAudioUnit.h>
#import <AudioKit/AKThreePoleLowpassFilterAudioUnit.h>
#import <AudioKit/AKModalResonanceFilterAudioUnit.h>
#import <AudioKit/AKMoogLadderAudioUnit.h>
#import <AudioKit/AKChowningReverbAudioUnit.h>
#import <AudioKit/AKCostelloReverbAudioUnit.h>
#import <AudioKit/AKLinearTransformationAudioUnit.h>
#import <AudioKit/AKFMOscillatorAudioUnit.h>
#import <AudioKit/AKOscillatorAudioUnit.h>
#import <AudioKit/AKPhasorAudioUnit.h>
#import <AudioKit/AKSawtoothOscillatorAudioUnit.h>
#import <AudioKit/AKSquareWaveOscillatorAudioUnit.h>
#import <AudioKit/AKTriangleOscillatorAudioUnit.h>
#import <AudioKit/AKPinkNoiseAudioUnit.h>
#import <AudioKit/AKWhiteNoiseAudioUnit.h>

#import <AudioKit/AKCustomModifierAudioUnit.h>
#import <AudioKit/AKCustomGeneratorAudioUnit.h>

#import <AudioKit/AKTesterAudioUnit.h>
