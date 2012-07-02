//
//  OCSTableValue.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Accesses table values by direct indexing with linear interpolation.
 */
@interface OCSTableValue : OCSOpcode

/// Output can be audio, control, or constant depending on the indexing parameter.
@property (nonatomic, strong) OCSParam *output;
/// Indexing Parameter.
@property (nonatomic, strong) OCSParam *index;
/// Function table read the data from.
@property (nonatomic, strong) OCSConstantParam *fTable;

/// Optional instruction to normalize the data.
@property (nonatomic, assign) BOOL normalizeResult;
/// Optional value by which index is to be offset. For a table with origin at center, use tablesize/2 (raw) or .5 (normalized). The default value is 0.
@property (nonatomic, strong) OCSParam *offset;
/// Optional instruction to wrap the data.  Without wrapping, (index < 0 treated as index=0; index > tablesize sticks at index=size)
@property (nonatomic, assign) BOOL wrapData;

/// Initialize the opcode as an audio operation.
/// @param                fTable Function table read the data from.
/// @param audioRateIndex Indexing Parameter.
- (id)initWithFTable:(OCSConstantParam *)fTable
    atAudioRateIndex:(OCSParam *)audioRateIndex;

/// Initialize the opcode as a control.
/// @param                  fTable Function table read the data from.
/// @param controlRateIndex Indexing Parameter.
- (id)initWithFTable:(OCSConstantParam *)fTable
  atControlRateIndex:(OCSControlParam *)controlRateIndex;

/// Initialize the opcode as a a constant.
/// @param               fTable Function table read the data from.
/// @param constantIndex Indexing Parameter.
- (id)initWithFTable:(OCSConstantParam *)fTable
     atConstantIndex:(OCSConstantParam *)constantIndex;




@end
