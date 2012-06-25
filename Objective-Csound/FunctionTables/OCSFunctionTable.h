//
//  OCSFunctionTable.h
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamArray.h"

/** Generic OCS Function Table definiton.  

 Currently supported function table types are

 - Sound File (OCSSoundFileTable)
 - Exponential Curves (OCSExponentialCurvesTable)
 - Sines (OCSSineTable)
 - Windows (OCSWindowsTable)
 
 */
@interface OCSFunctionTable : NSObject

// The unsupported types appear in an enumeration at the bottom of this file.  Add as necessary.
typedef enum
{
    kGenSoundFile = 1,
    kGenExponentialCurves=5,
    kGenSines=10,
    kGenWindows=20,
} GenRoutineType;


/// The output is a globally accessibly constant parameter
@property (nonatomic, strong) OCSParamConstant *output;

/// @param tableSizeOrZero       Size of the table, or 0 if deferred calculation is desired.
/// @param generatingRoutineType One of the supported GeneratingRoutines.
/// @param parametersAsString    A string containing the parameters separated by spaces. 
- (id)initWithSize:(int)tableSizeOrZero 
        GenRoutine:(GenRoutineType)generatingRoutineType 
        Parameters:(NSString *)parametersAsString;

/// @returns The textual representation of the function table for Csound
- (NSString *)stringForCSD;

@end

// Unsupported Generating Routines
typedef enum
{
    kGenPFields=2,
    kGenPolynomial=3,
    kGenNormalizingFunction=4,
    kGenCubicPolynomials=6,
    kGenStraightLines=7,
    kGenCubicSpline=8,
    kGenSinesWithThreeParameters=9,
    kGenCosines=11,
    kGenBessels=12,
    kGenChebyshevs1st=13,
    kGenChebysehvs2nt=14,
    kGenTwoPolynomials=15,
    kGenStartToEndCurves=16,
    kGenStepFunctions=17,
    kGenCompositeWaveforms=18,
    kGenCompositeWaveformsFromSines=19,
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
} CurrentlyUnsupportedGenRoutineType;
