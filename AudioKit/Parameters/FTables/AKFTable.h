//
//  AKFTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKArray.h"

/** Generic AK Function Table definiton.

 By default, the table will not be normalized,
 but it maybe normalized by setting the isNormalized property to YES.

 Currently supported function table types are

 - Sound File (AKSoundFileTable)
 - Exponential Curves (AKExponentialCurvesTable)
 - Sines (AKSineTable)
 - Windows (AKWindowsTable)

 */
@interface AKFTable : AKConstant

// The unsupported types appear in an enumeration at the bottom of this file.  Add as necessary.
typedef enum
{
    kFTSoundFile = 1,
    kFTArray=2,
    kFTExponentialCurves=5,
    kFTStraightLines=7,
    kFTSines=10,
    kFTAdditiveCosines=11,
    kFTCompositeWaveformsFromSines=19,
    kFTWindows=20,
    kFTRandomDistributions=21,
    kFTExponentialCurvesFromBreakpoints=25,
    kFTStraightLinesFromBreakpoints=27,
} FTableType;


/// This can be set to normalize the table, or not. It is not normalized by default.
@property (nonatomic,assign) BOOL isNormalized;


/// Creates a function table at the most basic level.
/// @param fTableType  One of the supported GeneratingRoutines.
/// @param tableSize          Size of the table, or 0 if deferred calculation is desired.
/// @param parameters         An array of parameters that define the function table.
- (instancetype)initWithType:(FTableType)fTableType
                        size:(int)tableSize
                  parameters:(AKArray *)parameters;

/// Creates a function table without specifying a size, deferring that calculation.
/// @param fTableType  One of the supported GeneratingRoutines.
/// @param parameters         An array of parameters that define the function table.
- (instancetype)initWithType:(FTableType)fTableType
                  parameters:(AKArray *)parameters;

// The textual representation of the dynamic function table for Csound
- (NSString *)stringForCSD;

// The textual representation of the global function table for Csound
- (NSString *)fTableStringForCSD;


/// Returns an ftlen() wrapped around the output of this function table.
- (AKConstant *)length;

@end

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
