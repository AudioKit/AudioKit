//
//  OCSFTable.h
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamArray.h"

/** Generic OCS Function Table definiton.  By default, the table will not be normalized,
 but it maybe normalized by setting the isNormalized property to YES.

 Currently supported function table types are

 - Sound File (OCSSoundFileTable)
 - Exponential Curves (OCSExponentialCurvesTable)
 - Sines (OCSSineTable)
 - Windows (OCSWindowsTable)
 
 */
@interface OCSFTable : NSObject

// The unsupported types appear in an enumeration at the bottom of this file.  Add as necessary.
typedef enum
{
    kFTSoundFile = 1,
    kFTArray=2,
    kFTExponentialCurves=5,
    kFTSines=10,
    kFTWindows=20,
    kFTExponentialCurvesFromBreakpoints=25,
} FTableType;


/// The output is a globally accessibly constant parameter
@property (nonatomic, strong) OCSConstantParam *output;

/// This can be set to normalize the table, or not. It is not normalized by default.
@property (nonatomic,assign) BOOL isNormalized;
           

/// Creates a function table at the most basic level.
/// @param fTableType  One of the supported GeneratingRoutines.
/// @param tableSize          Size of the table, or 0 if deferred calculation is desired.
/// @param parameters         An array of parameters that define the function table. 
- (id)initWithType:(FTableType)fTableType
              size:(int)tableSize
        parameters:(OCSParamArray *)parameters;

/// Creates a function table without specifying a size, deferring that calculation.
/// @param fTableType  One of the supported GeneratingRoutines.
/// @param parameters         An array of parameters that define the function table. 
- (id)initWithType:(FTableType)fTableType
        parameters:(OCSParamArray *)parameters;

/// @returns The textual representation of the function table for Csound
- (NSString *)stringForCSD;

/// Returns an ftlen() wrapped around the output of this function table.
- (id) length;

@end

// Unsupported Generating Routines
typedef enum
{
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
    kFTScaledFTable=24,
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
