//
//  OCSFunctionTable.h
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamArray.h"

typedef enum
{
    kGenSoundFile = 1,
    kGenPFields=2,
    kGenPolynomial=3,
    kGenNormalizingFunction=4,
    kGenExponentialCurves=5,
    kGenCubicPolynomials=6,
    kGenStraightLines=7,
    kGenCubicSpline=8,
    kGenSinesWithThreeParameters=9,
    kGenSines=10,
    kGenCosines=11,
    kGenBessels=12,
    kGenChebyshevs1st=13,
    kGenChebysehvs2nt=14,
    kGenTwoPolynomials=15,
    kGenStartToEndCurves=16,
    kGenStepFunctions=17,
    kGenCompositeWaveforms=18,
    kGenCompositeWaveformsFromSines=19,
    kGenWindows=20,
    kGenRandomDistributions=21,
    kGenTextFile=23,
    kGenScaledFunctionTable=24,
    kGenExponentialCurvesFromBreakpoints=25,
    kGenStraightLinesFromBreakpoints=27,
    kGenTimeTaggedTrajectory=28,
    kGenHarmonicPartials=30,
    kGenTableMixer=31,
    kGenTableMixerWithInterpolation=32,
    kGenSineMixerUsingFFT=33,
    kGenSineMixerUsingOscil=34,
    kGenRandomFromHistogram=40,
    kGenRandomPairs=41,
    kGenRandomDistributionOfRanges=42,
    kGenPVOCEX=43,
    kGenMP3File=49,
    kGenMicrotuningScale=51,
    kGenMultichannel=52
} GenRoutineType;

@interface OCSFunctionTable : NSObject
//f number  load-time  table-size  GEN  Routine  parameter1  parameter...  ; COMMENT
{
    int tableSize;
    int generatingRoutine;
    NSString *parameters;

}

//@property int   integerIdentifier;
//@property float loadTime;
//@property int   tableSize;
//@property int   generatingRoutine;
//
//@property (nonatomic, strong) NSString *parameters;
//@property (readonly) NSString *text;
@property (nonatomic, strong) OCSParamConstant *output;

- (id)initWithSize:(int)size 
        GenRoutine:(GenRoutineType)gen 
        Parameters:(NSString *)params;
- (NSString *)convertToCsd;

@end
