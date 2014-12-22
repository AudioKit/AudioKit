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

typedef NS_OPTIONS(NSUInteger, AKFTableType)
{
    AKFTableTypeSoundFile = 1,
    AKFTableTypeArray=2,
    AKFTableTypeExponentialCurves=5,
    AKFTableTypeStraightLines=7,
    AKFTableTypeSines=10,
    AKFTableTypeAdditiveCosines=11,
    AKFTableTypeCompositeWaveformsFromSines=19,
    AKFTableTypeWindows=20,
    AKFTableTypeRandomDistributions=21,
    AKFTableTypeExponentialCurvesFromBreakpoints=25,
    AKFTableTypeStraightLinesFromBreakpoints=27,
};

// Unsupported Generating Routines
typedef enum
{
    kFTPolynomial=3,
    kFTNormalizingFunction=4,
    kFTCubicPolynomials=6,
    kFTCubicSpline=8,
    kFTSinesWithThreeParameters=9,
    kFTBessels=12,
    kFTChebyshevs1st=13,
    kFTChebysehvs2nt=14,
    kFTTwoPolynomials=15,
    kFTStartToEndCurves=16,
    kFTStepFunctions=17,
    kFTCompositeWaveforms=18,
    kFTTextFile=23,
    kFTScaledFTable=24,
    kFTTimeTaggedTrajectory=28,
    kFTHarmonicPartials=30,
    kFTTableMixer=31,
    kFTTableMixerWithInterpolation=32,
    kFTSineMixerUsingFFT=33,
    kFTSineMixerUsingOscil=34,
    kFTRandomFromHistogram=40,
    kFTRandomPairs=41,
    kFTRandomDistributionOfRanges=42,
    kFTPVOCEX=43,
    kFTMP3File=49,
    kFTMicrotuningScale=51,
    kFTMultichannel=52
} CurrentlyUnsupported;



#endif
