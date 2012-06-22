//
//  OCSFunctionTable.h
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCSParamArray.h"

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
} GenRoutineType;

@interface OCSFunctionTable : NSObject
//f number  load-time  table-size  GEN  Routine  parameter1  parameter...  ; COMMENT
{
    NSString *text;
}

@property int   integerIdentifier;
@property float loadTime;
@property int   tableSize;
@property int   generatingRoutine;

@property (nonatomic, strong) NSString *parameters;
@property (nonatomic, strong) OCSParamConstant *output;
@property (readonly) NSString *text;

-(id) initWithSize:(int) size 
        GenRoutine:(GenRoutineType) gen 
        Parameters:(NSString *) params;


@end
