//
//  AKOrchestra.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKCompatibility.h"

@class AKInstrument;
@class AKEvent;
@class AKSequence;
@class AKParameter;

/** AKOrchestra is an AKInstrument collection that can be run by the AKManager.
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKOrchestra : NSObject

/** All UDOs that are required by the instrument are stored here and declared before any
 instrument blocks. */
@property (nonatomic, strong) NSMutableSet *userDefinedOperations;

/// Determines the value from which to scale all other amplitudes
@property (nonatomic, assign) float zeroDBFullScaleValue;

/// The number of channels, ie. mono=1, stereo=2, hexaphonic=6.  Can affect both output and input.
@property (readonly) UInt16 numberOfChannels;

/// Start the orchestra
+ (void)start;

/// Reset the orchestra with no instruments.
+ (void)reset;

/// Test the orchestra for a specified time
/// @param duration Testing run time in seconds
+ (void)testForDuration:(NSTimeInterval)duration;

/// Add an instrument to the orchestra
/// @param instrument Instrument to add to the orchestra
+ (void)addInstrument:(AKInstrument *)instrument;

/// Replace an instrument with the new parameters
/// @param instrument Instrument to respecify in the orchestra
+ (void)updateInstrument:(AKInstrument *)instrument;

/// Adds an instrument to orchestra and informs the instrument which orchestra it now belongs to.
/// @param instrument Instrument that will be added to the orchestra.
- (void)addInstrument:(AKInstrument *)instrument;

// @returns The initial CSD File representation for the orchestra including UDOs.
- (NSString *)stringForCSD;

@end
NS_ASSUME_NONNULL_END
