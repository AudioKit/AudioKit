//
//  OCSFileLength.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Returns the size of a stored function table.
 
 Returns the size (number of points, excluding guard point) of stored function table, number x. While most units referencing a stored table will automatically take its size into account (so tables can be of arbitrary length), this function reports the actual size if that is needed. Note that ftlen will always return a power-of-2 value, i.e. the function table guard point (see f Statement) is not included.As of Csound version 3.53, ftlen works with deferred function tables (see GEN01).
 
 ftlen differs from nsamp in that nsamp gives the number of sample frames loaded, while ftlen gives the total number of samples without the guard point. For example, with a stereo sound file of 10000 samples, ftlen() would return 19999 (i.e. a total of 20000 mono samples, not including a guard point), but nsamp() returns 10000.
 */

@interface OCSFileLength : OCSOpcode

@property (nonatomic, strong) OCSParam *output;

/// Calculates the size of a function table.
/// @param functionTable Function statement to return the size of
- (id)initWithFunctionTable:(OCSFunctionTable *)functionTable;

@end
