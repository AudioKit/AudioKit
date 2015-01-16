//
//  AKOrchestra.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKInstrument;
@class AKUserDefinedOperation;
@class AKEvent;
@class AKSequence;
@class AKParameter;

/** AKOrchestra is an AKInstrument collection that can be run by the AKManager.
 */
@interface AKOrchestra : NSObject

/// Determines the value from which to scale all other amplitudes
@property (nonatomic, assign) float zeroDBFullScaleValue;

/// The number of channels, ie. mono=1, stereo=2, hexaphonic=6.  Can affect both output and input.
@property (readonly) int numberOfChannels;

/// All the instruments in the orchestra, in order they need to be created.
@property (nonatomic, strong) NSMutableArray *instruments;

/// Global function tables not added by a specific instrument
@property (nonatomic, strong) NSMutableSet *functionTables;

/// Start the orchestra
+ (void)start;

/// Reset the orchestra with no instruments.
+ (void)reset;

/// Test the orchestra for a specified time
/// @param duration Testing run time in seconds
+ (void)testForDuration:(float)duration;

/// Add an instrument to the orchestra
/// @param instrument Instrument to add to the orchestra
+ (void)addInstrument:(AKInstrument *)instrument;

/// Adds an instrument to orchestra and informs the instrument which orchestra it now belongs to.
/// @param newInstrument Instrument that will be added to the orchestra.
- (void)addInstrument:(AKInstrument *)newInstrument;

// @returns The complete CSD File representation for the orchestra including UDOs and instruments.
- (NSString *)stringForCSD;

@end
