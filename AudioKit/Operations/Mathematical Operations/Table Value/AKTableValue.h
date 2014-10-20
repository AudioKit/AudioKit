//
//  AKTableValue.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Accesses table values by direct indexing with linear interpolation.
 */

@interface AKTableValue : AKAudio

/// Initialize the opcode as an audio operation.
/// @param fTable Function table read the data from.
/// @param index  Indexing Parameter.
- (instancetype)initWithFTable:(AKConstant *)fTable
                       atIndex:(AKAudio *)index;

/// Normalize data to a maximum of 1.
- (void)normalize;

/// Wrap around the fTable data for out of range indices.
- (void)wrap;

/// Set the offset amount.
/// @param offsetAmount Amount by which index is to be offset. For a table with origin at center, use tablesize/2 (raw) or .5 (normalized).
- (void)offsetBy:(AKConstant *)offsetAmount;

@end
