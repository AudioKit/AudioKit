//
//  AKArrayTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

/** Constructs a function table out of an NSArray.  If size is unspecififed,
 the array count is used, otherwise if isze is greater than the array count, 
 the rest of the table will be filled with zeroes.
 */

@interface AKArrayTable : AKFunctionTable

/// Create a function table from a parameter array
/// @param parameterArray The array to be stored in the function table.
- (instancetype)initWithArray:(AKArray *)parameterArray;

/// Create a function table from a parameter array, but define the size as something besides the array count.
/// @param parameterArray The array to be stored in the function table.
/// @param tableSize      The number of elements in the function table, the contents of the array, plus zeroes afterwards.
- (instancetype)initWithArray:(AKArray *)parameterArray size:(int)tableSize;

@end
