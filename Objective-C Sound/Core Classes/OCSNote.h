//
//  OCSNote.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSNoteProperty.h"

/** OCSNote is a representation of a sound object that is created by an
 OCSInstrument and has at least one of the two following qualities:
 a) The note has a duration, it starts and some finite time later, it ends.
 b) The note is created concurrently with other notes created by the instrument
 */

@interface OCSNote : NSObject

@property (nonatomic, strong) OCSInstrument *instrument;
@property (nonatomic, strong) NSMutableDictionary *properties;

/// Unique Identifier for the event
@property (readonly) float eventNumber;

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

- (id)initWithInstrument:(OCSInstrument *)anInstrument;

- (void)play;
- (void)kill;
- (void)updateProperties;

/// Provides the scoreline to the CSD File.
- (NSString *)stringForCSD;

- (NSString *)killStringForCSD;

- (void) addProperty:(OCSNoteProperty *)newProperty
            withName:(NSString *)name;

@end
