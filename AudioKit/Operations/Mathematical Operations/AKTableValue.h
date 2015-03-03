//
//  AKTableValue.h
//  AudioKit
//
//  Auto-generated on 2/27/15.
//  Customized by Aurelius Prochazka to have many more initializer options.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Accesses table values by direct indexing with cubic interpolation.
 */

@interface AKTableValue : AKAudio
/// Looks up the table value at a specific index with all options.
/// @param functionTable Function table to be inspected.
/// @param index Index at which to look up the value.
/// @param offset amount by which index is to be offset. For a table with origin at center, use tablesize/2. [Default Value: 0]
/// @param useWrappingIndex Normally limits results to minimum and maximum of index size, but if set to YES, wraps the index. [Default Value: NO]
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                              atIndex:(AKParameter *)index
                           withOffset:(AKConstant *)offset
                   usingWrappingIndex:(BOOL)useWrappingIndex;

/// Looks up the table value at a specific index with all options.
/// @param functionTable Function table to be inspected.
/// @param fractionalIndex Index at which to look up the value (from 0-1).
/// @param offset amount by which index is to be offset. For a table with origin at center, use .5. [Default Value: 0]
/// @param useWrappingIndex Normally limits results to minimum and maximum of index size, but if set to YES, wraps the index. [Default Value: NO]
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
               atFractionOfTotalWidth:(AKParameter *)fractionalIndex
                           withOffset:(AKConstant *)offset
                   usingWrappingIndex:(BOOL)useWrappingIndex;

/// Instantiates the table value with default values
/// @param functionTable Function table to be inspected.
/// @param index Index at which to look up the value
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                              atIndex:(AKParameter *)index;

/// Instantiates the table value with default values
/// @param functionTable Function table to be inspected.
/// @param index Index at which to look up the value
+ (instancetype)valueOfFunctionTable:(AKFunctionTable *)functionTable
                             atIndex:(AKParameter *)index;

/// Instantiates the table value with default values
/// @param functionTable Function table to be inspected.
/// @param fractionalIndex Index at which to look up the value (from 0-1).
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
               atFractionOfTotalWidth:(AKParameter *)fractionalIndex;
- (instancetype)initWithTable:(AKTable *)table
       atFractionOfTotalWidth:(AKParameter *)fractionalIndex;

/// Instantiates the table value with default values
/// @param functionTable Function table to be inspected.
/// @param fractionalIndex Index at which to look up the value (from 0-1).
+ (instancetype)valueOfFunctionTable:(AKFunctionTable *)functionTable
              atFractionOfTotalWidth:(AKParameter *)fractionalIndex;


/// amount by which index is to be offset. For a table with origin at center, use tablesize/2 (raw) or .5 (normalized). [Default Value: NO]
@property (nonatomic) AKConstant *offset;

/// Set an optional offset
/// @param offset amount by which index is to be offset. For a table with origin at center, use tablesize/2 (raw) or .5 (normalized). [Default Value: NO]
- (void)setOptionalOffset:(AKConstant *)offset;

/// Normally limits results to minimum and maximum of index size, but if set, wraps the index. [Default Value: NO]
@property BOOL useWrappingIndex;

@end
