//
//  AKPhrase.h
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 12/12/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKNote;
@class AKInstrument;

/** A collection of notes and start times that can be played by an instrument.
 */
@interface AKPhrase : NSObject

/// Add a note to the beginning of the phrase
/// @param note Note to be added at time zero
- (void)addNote:(AKNote *)note;

/// Add a note to the phrase at a specific time
/// @param note Note to be added
/// @param time Time the note will be played
- (void)addNote:(AKNote *)note atTime:(float)time;

/// Play the phrase
/// @param instrument Instrument that will play the notes in the phrase
- (void)playUsingInstrument:(AKInstrument *)instrument;

@end
