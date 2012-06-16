//
//  CSDConstants.h
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#ifndef ExampleProject_CSDConstants_h
#define ExampleProject_CSDConstants_h

extern NSString *const FINAL_OUTPUT;

typedef enum
{
    kDecayTypeSimpleAveraging=1,
    kDecayTypeStretchedAveraging=2,
    kDecayTypeSimpleDrum=3,
    kDecayTypeStretchedDrum=4,
    kDecayTypeWeightedAveraging=5,
    kDecayTypeRecursiveFirstOrder=6
}PluckDecayTypes;

typedef enum
{
    kGenRoutineSoundFile = 1,
    kGenRoutinePFields=2,
    kGenRoutinePolynomial=3,
    kGenRoutineNormalizingFunction=4,
    kGenRoutineExponentialCurves=5,
    kGenRoutineCubicPolynomials=6,
    kGenRoutineStraightLines=7,
    kGenRoutineCubicSpline=8,
    kGenRoutineSinesWithThreeParameters=9,
    kGenRoutineSines=10,
    kGenRoutineCosines=11,
    kGenRoutineBessels=12,
    kGenRoutineChebyshevs1st=13,
    kGenRoutineChebysehvs2nt=14,
    kGenRoutineTwoPolynomials=15,
    kGenRoutineStartToEndCurves=16,
    kGenRoutineStepFunctions=17,
    kGenRoutineCompositeWaveforms=18,
    kGenRoutineCompositeWaveformsFromSines=19,
    kGenRoutineWindows=20,
    kGenRoutineRandomDistributions=21,
    kGenRoutineTextFile=23,
    kGenRoutineScaledFunctionTable=24,
    kGenRoutineExponentialCurvesFromBreakpoints=25,
    kGenRoutineStraightLinesFromBreakpoints=27,
    kGenRoutineTimeTaggedTrajectory=28,
    kGenRoutineHarmonicPartials=30,
    kGenRoutineTableMixer=31,
    kGenRoutineTableMixerWithInterpolation=32,
    kGenRoutineSineMixerUsingFFT=33,
    kGenRoutineSineMixerUsingOscil=34,
    kGenRoutineRandomFromHistogram=40,
    kGenRoutineRandomPairs=41,
    kGenRoutineRandomDistributionOfRanges=42,
    kGenRoutinePVOCEX=43,
    kGenRoutineMP3File=49,
    kGenRoutineMicrotuningScale=51,
    kGenRoutineMultichannel=52
}GenRoutineTypes;

typedef enum
{
    kWindowHamming=1,
    kWindowHanning=2,
    kWindowBartlettTriangle=3,
    kWindowBlackmanThreeTerm=4,
    kWindowBlackmanHarrisFourTerm=5,
    kWindowGaussian=6,
    kWindowKaiser=7,
    KWindowRectangle=8,
    kWindowSync=9
}WindowTypes;

typedef enum
{
    kRandomDistributionUniform=1,
    kRandomDistributionLinear=2,
    kRandomDistributionTriangular=3,
    kRandomDistributionExponential=4,
    kRandomDistributionBiexponential=5,
    kRandomDistributionGaussian=6,
    kRandomDistributionCauchy=7,
    kRandomDistributionPositiveCauchy=8,
    kRandomDistributionBeta=9,
    kRandomDistributionWeibull=10,
    kRandomDistributionPoisson=11
}RandomDistributionTypes;

#endif
