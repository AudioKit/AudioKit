//
//  OCSTableValue.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

/**
 Accesses table values by direct indexing with linear interpolation.
 */

@interface OCSTableValue : OCSParameter

/// Initialize the opcode as an audio operation.
/// @param fTable Function table read the data from.
/// @param index  Indexing Parameter.
- (id)initWithFTable:(OCSConstant *)fTable
             atIndex:(OCSParameter *)index;

/// Normalize data to a maximum of 1.
- (void)normalize;

/// Wrap around the fTable data for out of range indices.
- (void)wrap;

/// Amount by which index is to be offset. For a table with origin at center, use tablesize/2 (raw) or .5 (normalized).
- (void)offsetBy:(OCSConstant *)offsetAmount;

@end
