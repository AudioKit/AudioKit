//
//  OCSFoundation.h
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#ifndef OCSFoundation_h
#define OCSFoundation_h

#import "OCSManager.h"
#import "OCSOrchestra.h"
#import "OCSInstrument.h"
#import "OCSSequence.h"
#import "OCSEvent.h"
#import "OCSNote.h"

#import "OCSParameter.h"
#import "OCSAudio.h"
#import "OCSControl.h"
#import "OCSInstrumentProperty.h"
#import "OCSConstant.h"
#import "OCSNoteProperty.h"

// Ftables

#import "OCSAdditiveCosineTable.h"
#import "OCSArrayTable.h"
#import "OCSCompositeWaveformsFromSines.h"
#import "OCSExponentialCurvesTable.h"
#import "OCSFTable.h"
#import "OCSLineSegmentTable.h"
#import "OCSRandomDistributionTable.h"
#import "OCSSineTable.h"
#import "OCSSoundFileTable.h"
#import "OCSWindowsTable.h"

// Operations

// Operations - Analysis
#import "OCSTrackedAmplitude.h"
#import "OCSTrackedFrequency.h"
#import "OCSTrackedFrequencySchouten.h"

// Operations - Mathematical Operations

// Operations - Mathematical Operations - Mininum and Maximum
#import "OCSMaxAudio.h"
#import "OCSMaxControl.h"
#import "OCSMinAudio.h"
#import "OCSMinControl.h"

// Operations - Mathematical Operations - Mixing
#import "OCSMixedAudio.h"
#import "OCSMixedControl.h"
#import "OCSProduct.h"
#import "OCSSum.h"
#import "OCSAssignment.h"
#import "OCSScaledControl.h"

// Operations - Mathematical Operations - Table Value
#import "OCSTableValue.h"
#import "OCSTableValueConstant.h"
#import "OCSTableValueControl.h"
#import "OCSParameter+Operation.h"

// Operations - Phase Vocoder Streaming
#import "OCSAudioFromFSignal.h"
#import "OCSCrossSynthesis.h"
#import "OCSFSignalFromMonoAudio.h"
#import "OCSFSignalFromMonoWithAttackAnalysis.h"
#import "OCSFSignalMix.h"
#import "OCSPhaseLockedVocoder.h"
#import "OCSScaledFSignal.h"
#import "OCSSpectralVocoder.h"
#import "OCSWarp.h"

// Operations - Signal Generators

// Operations - Signal Generators - Granular Synthesis
#import "OCSGrain.h"
#import "OCSSinusoidBursts.h"

// Operations - Signal Generators - Linear ADSR Envelopes
#import "OCSLinearADSRAudioEnvelope.h"
#import "OCSLinearADSRControlEnvelope.h"

// Operations - Signal Generators - Linear Envelopes
#import "OCSLinearAudioEnvelope.h"
#import "OCSLinearControlEnvelope.h"

// Operations - Signal Generators - Lines
#import "OCSLine.h"
#import "OCSLinearControl.h"

// Operations - Signal Generators - Oscillators

// Operations - Signal Generators - Oscillators - Low Frequency Oscillators
#import "OCSLowFrequencyOscillatingControl.h"
#import "OCSLowFrequencyOscillator.h"
#import "OCSLowFrequencyOscillatorConstants.h"
#import "OCSFMOscillator.h"
#import "OCSOscillatingControl.h"
#import "OCSOscillator.h"
#import "OCSSineOscillator.h"
#import "OCSVCOscillator.h"

// Operations - Signal Generators - Phasors
#import "OCSPhasingControl.h"
#import "OCSPhasor.h"

// Operations - Signal Generators - Physical Models

// Operations - Signal Generators - Physical Models - Mandolin
#import "OCSMandolin.h"

// Operations - Signal Generators - Physical Models - Marimba
#import "OCSMarimba.h"
#import "OCSPluckedString.h"
#import "OCSStruckMetalBar.h"
#import "OCSVibes.h"

// Operations - Signal Generators - Physical Models - PhISEM
#import "OCSBamboo.h"
#import "OCSCabasa.h"
#import "OCSCrunch.h"
#import "OCSDroplet.h"
#import "OCSGuiro.h"
#import "OCSSandPaper.h"
#import "OCSSekere.h"
#import "OCSSleighbells.h"
#import "OCSStick.h"
#import "OCSTambourine.h"

// Operations - Signal Generators - Physical Models - Waveguide
#import "OCSBeatenPlate.h"
#import "OCSBowedString.h"
#import "OCSSimpleWaveGuideModel.h"

// Operations - Signal Generators - Random Generators
#import "OCSJitter.h"
#import "OCSRandomAudio.h"
#import "OCSRandomControl.h"
#import "OCSRandomControlStream.h"

// Operations - Signal Generators - Segment Arrays
#import "OCSAudioSegmentArray.h"
#import "OCSControlSegmentArray.h"
#import "OCSControlSegmentArrayLoop.h"

// Operations - Signal Generators - Subtractive Synthesis
#import "OCSAdditiveCosines.h"

// Operations - Signal Input and Output

// Operations - Signal Input and Output - Looping Oscillators
#import "OCSLoopingOscillator.h"
#import "OCSLoopingOscillatorConstants.h"
#import "OCSLoopingStereoOscillator.h"
#import "OCSAudioInput.h"
#import "OCSAudioOutput.h"
#import "OCSFTablelooper.h"
#import "OCSFileInput.h"

// Operations - Signal Modifiers

// Operations - Signal Modifiers - Convolutions
#import "OCSConvolution.h"
#import "OCSStereoConvolution.h"

// Operations - Signal Modifiers - Delays
#import "OCSDelay.h"
#import "OCSVariableDelay.h"

// Operations - Signal Modifiers - Effects
#import "OCSCompressor.h"
#import "OCSDopplerEffect.h"
#import "OCSFlanger.h"
#import "OCSPortamento.h"
#import "OCSVibrato.h"

// Operations - Signal Modifiers - Filters

// Operations - Signal Modifiers - Filters - Butterworth Filters
#import "OCSBandPassButterworthFilter.h"
#import "OCSBandRejectButterworthFilter.h"
#import "OCSHighPassButterworthFilter.h"
#import "OCSLowPassButterworthFilter.h"
#import "OCSCombFilter.h"
#import "OCSDCBlock.h"
#import "OCSEqualizerFilter.h"
#import "OCSHighPassFilter.h"
#import "OCSHilbertTransformer.h"
#import "OCSLowPassControlFilter.h"
#import "OCSLowPassFilter.h"
#import "OCSMoogLadder.h"
#import "OCSMoogVCF.h"
#import "OCSThreePoleLowpassFilter.h"

// Operations - Signal Modifiers - Reverbs
#import "OCSBallWithinTheBoxReverb.h"
#import "OCSNReverb.h"
#import "OCSReverb.h"
#import "OCSReverbAllpass.h"

// Operations - Signal Modifiers - Volume and Spatialization
#import "OCSBalance.h"
#import "OCSPanner.h"


#endif