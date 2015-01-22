//
//  AKTypes.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

#ifndef AKTypes_h
#define AKTypes_h

/// Low frequency oscillator waveforms
typedef NS_OPTIONS(NSUInteger, AKLowFrequencyOscillatorType)
{
    AKLowFrequencyOscillatorTypeSine = 0,
    AKLowFrequencyOscillatorTypeTriangle = 1,
    AKLowFrequencyOscillatorTypeBipolarSquare = 2,
    AKLowFrequencyOscillatorTypeUnipolarSquare = 3,
    AKLowFrequencyOscillatorTypeSawTooth = 4,
    AKLowFrequencyOscillatorTypeDownSawTooth = 5
};

/// Sound file looper direction
typedef NS_OPTIONS(NSUInteger, AKSoundFileLooperMode)
{
    AKSoundFileLooperModeNoLoop=0,
    AKSoundFileLooperModeNormal=1,
    AKSoundFileLooperModeForwardAndBack=2
};

/// Function table looper direction
typedef NS_OPTIONS(NSUInteger, AKFunctionTableLooperMode)
{
    AKFunctionTableLooperModeNormal=0,
    AKFunctionTableLooperModeBackward=1,
    AKFunctionTableLooperModeForwardAndBack=2
};

/// Different ways of panning between left and right
typedef NS_OPTIONS(NSUInteger, AKPanMethod)
{
    AKPanMethodEqualPower = 0,
    AKPanMethodSquareRoot = 1,
    AKPanMethodLinear = 2,
    AKPanMethodAltEqualPower = 3,
};

/// Various waveforms offered by the AKVCOscillator
typedef NS_OPTIONS(NSUInteger, AKVCOscillatorWaveformType)
{
    AKVCOscillatorWaveformTypeSawtooth  =  0,
    AKVCOscillatorWaveformTypeSquarePWM = 2,
    AKVCOscillatorWaveformTypeTriangleWithRamp = 4,
    AKVCOscillatorWaveformTypePulseUnnormalized = 6,
    AKVCOscillatorWaveformTypeIntegratedSawtooth = 8,
    AKVCOscillatorWaveformTypeSquareNoPWM = 10,
    AKVCOscillatorWaveformTypeTriangleNoRamp = 12
};

/// Window types for converting audio into the frequency domain
typedef NS_OPTIONS(NSUInteger, AKFSignalFromMonoAudioWindowType)
{
    AKFSignalFromMonoAudioWindowTypeHamming=0,
    AKFSignalFromMonoAudioWindowTypeVonHann=1,
    
};

/// Formant retain methods when scaling in the frequency domain
typedef NS_OPTIONS(NSUInteger, AKScaledFSignalFormantRetainMethod)
{
    AKScaledFSignalFormantRetainMethodNone=0,
    AKScaledFSignalFormantRetainMethodLifteredCepstrum=1,
    AKScaledFSignalFormantRetainMethodTrueEnvelope=2,
};

/// Boundary conditions for ends of the struck metal bar physical model
typedef NS_OPTIONS(NSUInteger, AKStruckMetalBarBoundaryCondition)
{
    AKStruckMetalBarBoundaryConditionClamped=1,
    AKStruckMetalBarBoundaryConditionPivoting=2,
    AKStruckMetalBarBoundaryConditionFree=3,
};

/// Random numbers are created within a distribution cover defined by this type
typedef NS_OPTIONS(NSUInteger, AKRandomDistributionType)
{
    AKRandomDistributionTypeUniform=1,
    AKRandomDistributionTypeLinear=2,
    AKRandomDistributionTypeTriangular=3,
    AKRandomDistributionTypeExponential=4,
    AKRandomDistributionTypeBiexponential=5,
    AKRandomDistributionTypeGaussian=6,
    AKRandomDistributionTypeCauchy=7,
    AKRandomDistributionTypePositiveCauchy=8,
    AKRandomDistributionTypePoisson=11
};

/// Various types of window function tables
typedef NS_OPTIONS(NSUInteger, AKWindowTableType)
{
    AKWindowTableTypeHamming=1,
    AKWindowTableTypeHanning=2,
    AKWindowTableTypeBartlettTriangle=3,
    AKWindowTableTypeBlackmanThreeTerm=4,
    AKWindowTableTypeBlackmanHarrisFourTerm=5,
    AKWindowTableTypeGaussian=6,
    AKWindowTableTypeKaiser=7,
    AKWindowTableTypeRectangle=8,
    AKWindowTableTypeSync=9
};

/// MIDI note on/off, control and system exclusive constants
typedef NS_OPTIONS(NSUInteger, AKMidiConstant)
{
    AKMidiConstantNoteOff = 8,
    AKMidiConstantNoteOn = 9,
    AKMidiConstantPolyphonicAftertouch = 10,
    AKMidiConstantControllerChange = 11,
    AKMidiConstantProgramChange = 12,
    AKMidiConstantAftertouch = 13,
    AKMidiConstantPitchWheel = 14,
    AKMidiConstantSysex = 240
};

/// Types of function tables currently supported in AudioKit
typedef NS_OPTIONS(NSUInteger, AKFunctionTableType)
{
    AKFunctionTableTypeSoundFile = 1,
    AKFunctionTableTypeArray=2,
    AKFunctionTableTypeAdditiveCosines=11,
    AKFunctionTableTypeExponentialCurvesVariableGrowth=16,
    AKFunctionTableTypeWeightedSumOfSinusoids=19,
    AKFunctionTableTypeWindows=20,
    AKFunctionTableTypeRandomDistributions=21,
    AKFunctionTableTypeExponentialCurves=25,
    AKFunctionTableTypeStraightLines=27,
};


#endif
