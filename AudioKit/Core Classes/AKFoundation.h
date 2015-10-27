//
//  AKFoundation.h
//  AudioKit
//
//  Auto-generated on 12/29/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFoundation_h
#define AKFoundation_h

@import Foundation;

# pragma mark - Compatibility Macros
#import "AKCompatibility.h"

# pragma mark - Core Classes
#import "AKSettings.h"
#import "AKManager.h"
#import "AKOrchestra.h"

# pragma mark - MIDI
#import "AKMidi.h"
#import "AKMidiEvent.h"
#import "AKMidiNote.h"

# pragma mark - Instruments
#import "AKInstrument.h"
#import "AKInstrumentProperty.h"
#import "AKMidiInstrument.h"

#pragma mark - Notes
#import "AKNote.h"
#import "AKNoteProperty.h"

# pragma mark - Parameters
#import "AKParameter.h"
#import "AKAudio.h"
#import "AKControl.h"
#import "AKConstant.h"

# pragma mark - Sequencing
#import "AKEvent.h"
#import "AKSequence.h"

#  pragma mark - Tables
#import "AKSoundFileTable.h"
#import "AKTable.h"

# pragma mark Table Generators
#import "AKHarmonicCosineTableGenerator.h"
#import "AKExponentialTableGenerator.h"
#import "AKFourierSeriesTableGenerator.h"
#import "AKLineTableGenerator.h"
#import "AKRandomDistributionTableGenerator.h"
#import "AKWindowTableGenerator.h"

// -----------------------------------------------------------------------------
#  pragma mark - Operations
// -----------------------------------------------------------------------------

#import "AKParameter+Operation.h"

// Operations - Analysis
#import "AKTrackedAmplitude.h"
#import "AKTrackedAmplitudeFromFSignal.h"
#import "AKTrackedFrequency.h"
#import "AKTrackedFrequencyFromFSignal.h"

// Operations - FFT
#import "AKCrossSynthesizedFFT.h"
#import "AKFFT.h"
#import "AKFFTProcessor.h"
#import "AKFFTTableReader.h"
#import "AKFFTTableWriter.h"
#import "AKFilteredFFT.h"
#import "AKMaskedFFT.h"
#import "AKMixedFFT.h"
#import "AKPhaseLockedVocoder.h"
#import "AKResynthesizedAudio.h"
#import "AKScaledFFT.h"
#import "AKSpectralVocoder.h"
#import "AKWarpedFFT.h"

// Operations - Math
#import "AKAssignment.h"
#import "AKDifference.h"
#import "AKInverse.h"
#import "AKMaximum.h"
#import "AKMinimum.h"
#import "AKMultipleInputMathOperation.h"
#import "AKProduct.h"
#import "AKSingleInputMathOperation.h"
#import "AKSum.h"
#import "AKTableValue.h"

// Operations - Signal Generators

// Operations - Signal Generators - Envelopes
#import "AKADSREnvelope.h"
#import "AKLine.h"
#import "AKLinearADSREnvelope.h"
#import "AKLinearEnvelope.h"

// Operations - Signal Generators - Granular Synthesis
#import "AKGranularSynthesisTexture.h"
#import "AKGranularSynthesizer.h"
#import "AKSinusoidBursts.h"

// Operations - Signal Generators - Loopers
#import "AKMonoSoundFileLooper.h"
#import "AKStereoSoundFileLooper.h"
#import "AKTableLooper.h"

// Operations - Signal Generators - Musical Controls
#import "AKPortamento.h"
#import "AKVibrato.h"

// Operations - Signal Generators - Oscillators
#import "AKFMOscillator.h"
#import "AKLowFrequencyOscillator.h"
#import "AKOscillator.h"
#import "AKPhasor.h"
#import "AKVCOscillator.h"

// Operations - Signal Generators - Physical Models
#import "AKMandolin.h"
#import "AKMarimba.h"
#import "AKPluckedString.h"
#import "AKStruckMetalBar.h"
#import "AKVibes.h"

// Operations - Signal Generators - Physical Models - PhISEM
#import "AKBambooSticks.h"
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
#import "AKFlute.h"
#import "AKSimpleWaveGuideModel.h"

// Operations - Signal Generators - Random Generators
#import "AKInterpolatedRandomNumberPulse.h"
#import "AKJitter.h"
#import "AKNoise.h"
#import "AKRandomNumbers.h"

// Operations - Signal Generators - Segment Arrays
#import "AKSegmentArray.h"
#import "AKSegmentArrayLoop.h"

// Operations - Signal Generators - Subtractive Synthesis
#import "AKAdditiveCosines.h"

// Operations - Signal Input and Output
#import "AKAudioInput.h"
#import "AKAudioOutput.h"
#import "AKFileInput.h"
#import "AKLog.h"
#import "AKMP3FileInput.h"
#import "AKMonoFileInput.h"
#import "AKParameterChangeLog.h"

// Operations - Signal Modifiers

// Operations - Signal Modifiers - Convolutions
#import "AKConvolution.h"
#import "AKStereoConvolution.h"

// Operations - Signal Modifiers - Delays
#import "AKDelay.h"
#import "AKMultitapDelay.h"
#import "AKVariableDelay.h"

// Operations - Signal Modifiers - Effects
#import "AKCompressor.h"
#import "AKCompressorExpander.h"
#import "AKDistortion.h"
#import "AKDopplerEffect.h"
#import "AKFlanger.h"
#import "AKPitchShifter.h"
#import "AKRingModulator.h"

// Operations - Signal Modifiers - Filters
#import "AKAntiresonantFilter.h"
#import "AKClipper.h"
#import "AKCombFilter.h"
#import "AKDCBlock.h"
#import "AKDecimator.h"
#import "AKDeclick.h"
#import "AKEqualizerFilter.h"
#import "AKHighPassFilter.h"
#import "AKHilbertTransformer.h"
#import "AKLowPassFilter.h"
#import "AKMoogLadder.h"
#import "AKMoogVCF.h"
#import "AKResonantFilter.h"
#import "AKStringResonator.h"
#import "AKThreePoleLowpassFilter.h"
#import "AKVariableFrequencyResponseBandPassFilter.h"

// Operations - Signal Modifiers - Filters - Butterworth Filters
#import "AKBandPassButterworthFilter.h"
#import "AKBandRejectButterworthFilter.h"
#import "AKHighPassButterworthFilter.h"
#import "AKLowPassButterworthFilter.h"

// Operations - Signal Modifiers - Filters - Parametric Equalizers
#import "AKHighShelfParametricEqualizerFilter.h"
#import "AKLowShelfParametricEqualizerFilter.h"
#import "AKPeakingParametricEqualizerFilter.h"

// Operations - Signal Modifiers - Reverbs
#import "AKBallWithinTheBoxReverb.h"
#import "AKFlatFrequencyResponseReverb.h"
#import "AKParallelCombLowPassFilterReverb.h"
#import "AKReverb.h"

// Operations - Signal Modifiers - Volume and Spatialization
#import "AK3DBinauralAudio.h"
#import "AKBalance.h"
#import "AKMix.h"
#import "AKPanner.h"

// Sound Fonts
#import "AKSoundFont.h"
#import "AKSoundFontInstrument.h"
#import "AKSoundFontInstrumentPlayer.h"
#import "AKSoundFontPreset.h"
#import "AKSoundFontPresetPlayer.h"

// Utilities
#import "AKSampler.h"
#import "AKTools.h"

// Utilities - Instruments

// Utilities - Instruments - Amplifiers
#import "AKAmplifier.h"
#import "AKStereoAmplifier.h"

// Utilities - Instruments - Analyzers
#import "AKAudioAnalyzer.h"

// Utilities - Instruments - Emulations
#import "AKBambooSticksInstrument.h"
#import "AKMandolinInstrument.h"
#import "AKMarimbaInstrument.h"
#import "AKPluckedStringInstrument.h"
#import "AKSekereInstrument.h"
#import "AKSleighbellsInstrument.h"
#import "AKStickInstrument.h"
#import "AKStruckMetalBarInstrument.h"
#import "AKTambourineInstrument.h"
#import "AKVibraphoneInstrument.h"

// Utilities - Instruments - File Players
#import "AKAudioFilePlayer.h"
#import "AKStereoAudioFilePlayer.h"

// Utilities - Instruments - Looper
#import "AKBeatClock.h"

// Utilities - Instruments - Microphone
#import "AKMicrophone.h"

// Utilities - Instruments - Processors
#import "AKDelayPedal.h"
#import "AKPitchShifterPedal.h"
#import "AKReverbPedal.h"

// Utilities - Instruments - Synthesizers
#import "AKFMOscillatorInstrument.h"
#import "AKVCOscillatorInstrument.h"

// Utilities - Plots
#import "AKAudioInputFFTPlot.h"
#import "AKAudioInputPlot.h"
#import "AKAudioInputRollingWaveformPlot.h"
#import "AKAudioOutputFFTPlot.h"
#import "AKAudioOutputPlot.h"
#import "AKAudioOutputRollingWaveformPlot.h"
#import "AKFloatPlot.h"
#import "AKInstrumentPropertyPlot.h"
#import "AKPlotView.h"
#import "AKStereoOutputPlot.h"
#import "AKTablePlot.h"

// Utilities - User Interface Elements
#import "AKLevelMeter.h"
#import "AKPropertyLabel.h"
#import "AKPropertySlider.h"

#endif
