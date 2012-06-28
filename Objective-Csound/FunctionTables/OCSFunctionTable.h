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
    kFTSoundFile = 1,
    kFTExponentialCurves=5,
    kFTSines=10,
    kFTWindows=20,
} FunctionTableType;


/// The output is a globally accessibly constant parameter
@property (nonatomic, strong) OCSParamConstant *output;
/// @param functionTableType  One of the supported GeneratingRoutines.
/// @param tableSizeOrZero    Size of the table, or 0 if deferred calculation is desired.
/// @param parametersAsString A string containing the parameters separated by spaces. 
- (id)initWithType:(FunctionTableType)functionTableType
              size:(int)tableSizeOrZero 
        parameters:(NSString *)parametersAsString;

/// @returns The textual representation of the function table for Csound
- (NSString *)stringForCSD;

@end

// Unsupported Generating Routines
typedef enum
{
    kFTPFields=2,
    kFTPolynomial=3,
    kFTNormalizingFunction=4,
    kFTCubicPolynomials=6,
    kFTStraightLines=7,
    kFTCubicSpline=8,
    kFTSinesWithThreeParameters=9,
    kFTCosines=11,
    kFTBessels=12,
    kFTChebyshevs1st=13,
    kFTChebysehvs2nt=14,
    kFTTwoPolynomials=15,
    kFTStartToEndCurves=16,
    kFTStepFunctions=17,
    kFTCompositeWaveforms=18,
    kFTCompositeWaveformsFromSines=19,
    kFTRandomDistributions=21,
    kFTTextFile=23,
    kFTScaledFunctionTable=24,
    kFTExponentialCurvesFromBreakpoints=25,
    kFTStraightLinesFromBreakpoints=27,
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
