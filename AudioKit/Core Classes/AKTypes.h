//
//  AKTypes.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

#ifndef AKTypes_h
#define AKTypes_h

/// Window types for converting audio into the frequency domain
typedef NS_OPTIONS(NSUInteger, AKFFTWindowType)
{
    AKFFTWindowTypeHamming = 0,
    AKFFTWindowTypeVonHann = 1,
    
};

/// Formant retain methods when scaling in the frequency domain
typedef NS_OPTIONS(NSUInteger, AKScaledFFTFormantRetainMethod)
{
    AKScaledFFTFormantRetainMethodNone = 0,
    AKScaledFFTFormantRetainMethodLifteredCepstrum = 1,
    AKScaledFFTFormantRetainMethodTrueEnvelope = 2,
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
    AKFunctionTableTypeWeightedSumOfSinusoids=19,
    AKFunctionTableTypeWindow=20,
    AKFunctionTableTypeRandomDistributions=21,
    AKFunctionTableTypeExponentialCurves=25,
    AKFunctionTableTypeStraightLines=27,
};


#endif
