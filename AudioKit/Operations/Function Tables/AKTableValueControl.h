//
//  AKTableValueControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Accesses table values by direct indexing with linear interpolation.
 */

@interface AKTableValueControl : AKControl

/// Initialize the opcode as an audio operation.
/// @param functionTable Function table read the data from.
/// @param index  Indexing Parameter.
- (instancetype)initWithFunctionTable:(AKConstant *)functionTable
                              atIndex:(AKControl *)index;

/// Normalize data to a maximum of 1.
- (void)normalize;

/// Wrap around the functionTable data for out of range indices.
- (void)wrap;

/// Set the offset amount.
/// @param offsetAmount Amount by which index is to be offset. For a table with origin at center, use tablesize/2 (raw) or .5 (normalized).
- (void)offsetBy:(AKConstant *)offsetAmount;


@end
