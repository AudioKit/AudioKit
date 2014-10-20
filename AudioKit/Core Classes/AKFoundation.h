//
//  AKFoundation.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#ifndef AKFoundation_h
#define AKFoundation_h

#import <Foundation/Foundation.h>

#import "AKManager.h"
#import "AKOrchestra.h"
#import "AKInstrument.h"
#import "AKSequence.h"
#import "AKEvent.h"
#import "AKNote.h"

#import "AKParameter.h"
#import "AKAudio.h"
#import "AKControl.h"
#import "AKInstrumentProperty.h"
#import "AKConstant.h"
#import "AKNoteProperty.h"

#import "AKSampler.h"

// Ftables

#import "AKAdditiveCosineTable.h"
#import "AKArrayTable.h"
#import "AKCompositeWaveformsFromSines.h"
#import "AKExponentialCurvesTable.h"
#import "AKFTable.h"
#import "AKLineSegmentTable.h"
#import "AKRandomDistributionTable.h"
#import "AKSineTable.h"
#import "AKSoundFileTable.h"
#import "AKWindowsTable.h"

// Operations
#import "AKParameter+Operation.h"

// Operations - Analysis
#import "AKTrackedAmplitude.h"
#import "AKTrackedAmplitudeFromFSignal.h"
#import "AKTrackedFrequency.h"
#import "AKTrackedFrequencyFromFSignal.h"

// Operations - Mathematical Operations
#import "AKAssignment.h"
#import "AKScaledControl.h"

// Operations - Mathematical Operations - Mininum and Maximum
#import "AKMaxAudio.h"
#import "AKMaxControl.h"
#import "AKMinAudio.h"
#import "AKMinControl.h"

// Operations - Mathematical Operations - Mixing
#import "AKMixedAudio.h"
#import "AKMixedControl.h"
#import "AKProduct.h"
#import "AKSum.h"

// Operations - Mathematical Operations - Table Value
#import "AKTableValue.h"
#import "AKTableValueConstant.h"
#import "AKTableValueControl.h"

// Operations - Phase Vocoder Streaming
#import "AKAudioFromFSignal.h"
#import "AKCrossSynthesis.h"
#import "AKFSignalFromMonoAudio.h"
#import "AKFSignalFromMonoWithAttackAnalysis.h"
#import "AKFSignalMix.h"
#import "AKPhaseLockedVocoder.h"
#import "AKScaledFSignal.h"
#import "AKSpectralVocoder.h"
#import "AKWarp.h"

// Operations - Signal Generators

// Operations - Signal Generators - Granular Synthesis
#import "AKGranularSynthesisTexture.h"
#import "AKSinusoidBursts.h"

// Operations - Signal Generators - Linear ADSR Envelopes
#import "AKLinearADSRAudioEnvelope.h"
#import "AKLinearADSRControlEnvelope.h"

// Operations - Signal Generators - Linear Envelopes
#import "AKLinearAudioEnvelope.h"
#import "AKLinearControlEnvelope.h"

// Operations - Signal Generators - Lines
#import "AKLine.h"
#import "AKLinearControl.h"

// Operations - Signal Generators - Oscillators
#import "AKFMOscillator.h"
#import "AKOscillatingControl.h"
#import "AKOscillator.h"
#import "AKSineOscillator.h"
#import "AKVCOscillator.h"

// Operations - Signal Generators - Oscillators - Low Frequency Oscillators
#import "AKLowFrequencyOscillatingControl.h"
#import "AKLowFrequencyOscillator.h"
#import "AKLowFrequencyOscillatorConstants.h"

// Operations - Signal Generators - Phasors
#import "AKPhasingControl.h"
#import "AKPhasor.h"

// Operations - Signal Generators - Physical Models
#import "AKPluckedString.h"
#import "AKStruckMetalBar.h"
#import "AKVibes.h"

// Operations - Signal Generators - Physical Models - Mandolin
#import "AKMandolin.h"

// Operations - Signal Generators - Physical Models - Marimba
#import "AKMarimba.h"

// Operations - Signal Generators - Physical Models - PhISEM
#import "AKBamboo.h"
#import "AKCabasa.h"
#import "AKCrunch.h"
#import "AKDroplet.h"
#import "AKGuiro.h"
#import "AKSandPaper.h"
#import "AKSekere.h"
#import "AKSleighbells.h"
#import "AKStick.h"
#import "AKTambourine.h"

// Operations - Signal Generators - Physical Models - Waveguide
#import "AKBeatenPlate.h"
#import "AKBowedString.h"
#import "AKSimpleWaveGuideModel.h"

// Operations - Signal Generators - Random Generators
#import "AKInterpolatedRandomNumberPulse.h"
#import "AKJitter.h"
#import "AKRandomAudio.h"
#import "AKRandomControl.h"

// Operations - Signal Generators - Segment Arrays
#import "AKAudioSegmentArray.h"
#import "AKControlSegmentArray.h"
#import "AKControlSegmentArrayLoop.h"

// Operations - Signal Generators - Subtractive Synthesis
#import "AKAdditiveCosines.h"

// Operations - Signal Input and Output
#import "AKAudioInput.h"
#import "AKAudioOutput.h"
#import "AKFTableLooper.h"
#import "AKFileInput.h"
#import "AKMonoFileInput.h"

// Operations - Signal Input and Output - Looping Oscillators
#import "AKLoopingOscillator.h"
#import "AKLoopingOscillatorConstants.h"
#import "AKLoopingStereoOscillator.h"

// Operations - Signal Modifiers

// Operations - Signal Modifiers - Convolutions
#import "AKConvolution.h"
#import "AKStereoConvolution.h"

// Operations - Signal Modifiers - Delays
#import "AKDelay.h"
#import "AKVariableDelay.h"

// Operations - Signal Modifiers - Effects
#import "AKCompressor.h"
#import "AKDopplerEffect.h"
#import "AKFlanger.h"
#import "AKPortamento.h"
#import "AKVibrato.h"

// Operations - Signal Modifiers - Filters
#import "AKCombFilter.h"
#import "AKDCBlock.h"
#import "AKEqualizerFilter.h"
#import "AKHighPassFilter.h"
#import "AKHilbertTransformer.h"
#import "AKLowPassControlFilter.h"
#import "AKLowPassFilter.h"
#import "AKMoogLadder.h"
#import "AKMoogVCF.h"
#import "AKResonantFilter.h"
#import "AKThreePoleLowpassFilter.h"
#import "AKVariableFrequencyResponseBandPassFilter.h"

// Operations - Signal Modifiers - Filters - Butterworth Filters
#import "AKBandPassButterworthFilter.h"
#import "AKBandRejectButterworthFilter.h"
#import "AKHighPassButterworthFilter.h"
#import "AKLowPassButterworthFilter.h"

// Operations - Signal Modifiers - Filters - declick
#import "AKDeclick.h"

// Operations - Signal Modifiers - Reverbs
#import "AKBallWithinTheBoxReverb.h"
#import "AKFlatFrequencyResponseReverb.h"
#import "AKParallelCombLowPassFilterReverb.h"
#import "AKReverb.h"

// Operations - Signal Modifiers - Volume and Spatialization
#import "AKBalance.h"
#import "AKPanner.h"

#endif