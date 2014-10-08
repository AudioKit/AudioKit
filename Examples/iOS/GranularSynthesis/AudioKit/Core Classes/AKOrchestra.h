//
//  AKOrchestra.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKInstrument;
@class AKUserDefinedOperation;
@class AKEvent;
@class AKSequence;

/** AKOrchestra is an AKInstrument collection that can be run by the AKManager.
 */
@interface AKOrchestra : NSObject 

/// Determines the value from which to scale all other amplitudes
@property (nonatomic, assign) float zeroDBFullScaleValue;

/// The number of channels, ie. mono=1, stereo=2, hexaphonic=6.  Can affect both output and input.
@property (readonly) int numberOfChannels;

/// All the instruments in the orchestra, in order they need to be created.
@property (nonatomic, strong) NSMutableArray *instruments;


/// Adds an instrument to orchestra and informs the instrument which orchestra it now belongs to.
/// @param newInstrument Instrument that will be added to the orchestra.
- (void)addInstrument:(AKInstrument *)newInstrument;

// @returns The complete CSD File representation for the orchestra including UDOs and instruments.
- (NSString *)stringForCSD;

@end
