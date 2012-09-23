//
//  OCSNote.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSNoteProperty.h"

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

- (void)kill;
- (void)updateProperties;

/// Provides the scoreline to the CSD File.
- (NSString *)stringForCSD;

- (NSString *)killStringForCSD;

@end
