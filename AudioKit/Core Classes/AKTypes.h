//
//  AKTypes.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

#ifndef AKTypes_h
#define AKTypes_h

typedef NS_OPTIONS(NSUInteger, AKLowFrequencyOscillatorType)
{
    AKLowFrequencyOscillatorTypeSine = 0,
    AKLowFrequencyOscillatorTypeTriangle = 1,
    AKLowFrequencyOscillatorTypeBipolarSquare = 2,
    AKLowFrequencyOscillatorTypeUnipolarSquare = 3,
    AKLowFrequencyOscillatorTypeSawTooth = 4,
    AKLowFrequencyOscillatorTypeDownSawTooth = 5
};

typedef NS_OPTIONS(NSUInteger, AKLoopingOscillatorType)
{
    AKLoopingOscillatorTypeNoLoop=0,
    AKLoopingOscillatorTypeNormal=1,
    AKLoopingOscillatorTypeForwardAndBack=2
};

typedef NS_OPTIONS(NSUInteger, AKPanMethod)
{
    AKPanMethodEqualPower = 0,
    AKPanMethodSquareRoot = 1,
    AKPanMethodLinear = 2,
    AKPanMethodAltEqualPower = 3,
};

typedef NS_OPTIONS(NSUInteger, AKVCOscillatorWaveformType)
{
    AKVCOscillatorWaveformTypeSawtooth  = 16,
    AKVCOscillatorWaveformTypeSquarePWM = 18,
    AKVCOscillatorWaveformTypeTriangleWithRamp = 20,
    AKVCOscillatorWaveformTypePulseUnnormalized = 22,
    AKVCOscillatorWaveformTypeIntegratedSawtooth = 24,
    AKVCOscillatorWaveformTypeSquareNoPWM = 26,
    AKVCOscillatorWaveformTypeTriangleNoRamp = 28
};

typedef NS_OPTIONS(NSUInteger, AKFSignalFromMonoAudioWindowType)
{
    AKFSignalFromMonoAudioWindowTypeHamming=0,
    AKFSignalFromMonoAudioWindowTypeVonHann=1,
    
};

typedef NS_OPTIONS(NSUInteger, AKScaledFSignalFormantRetainMethod)
{
    AKScaledFSignalFormantRetainMethodNone=0,
    AKScaledFSignalFormantRetainMethodLifteredCepstrum=1,
    AKScaledFSignalFormantRetainMethodTrueEnvelope=2,
};

typedef NS_OPTIONS(NSUInteger, AKStruckMetalBarBoundaryCondition)
{
    AKStruckMetalBarBoundaryConditionClamped=1,
    AKStruckMetalBarBoundaryConditionPivoting=2,
    AKStruckMetalBarBoundaryConditionFree=3,
};

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

typedef NS_OPTIONS(NSUInteger, AKFunctionTableType)
{
    AKFunctionTableTypeSoundFile = 1,
    AKFunctionTableTypeArray=2,
    AKFunctionTableTypeAdditiveCosines=11,
    AKFunctionTableTypeWeightedSumOfSinusoids=19,
    AKFunctionTableTypeWindows=20,
    AKFunctionTableTypeRandomDistributions=21,
    AKFunctionTableTypeExponentialCurves=25,
    AKFunctionTableTypeStraightLines=27,
};


#endif
