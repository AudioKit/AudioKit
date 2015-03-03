//
//  AKFunctionTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKConstant.h"
/** Generic AK Function Table definiton.

 By default, the table will not be normalized,
 but it maybe normalized by setting the isNormalized property to YES.

 */
@interface AKFunctionTable : AKConstant

/// This can be set to normalize the table, or not. It is not normalized by default.
@property (nonatomic,assign) BOOL isNormalized;

/// The parameters list which can be assigned by subclasses
@property NSArray *parameters;

/// The size of the FunctionTable
@property int size;

/// The number of the function table
- (int)number;

/// The name of the function
- (NSString *)functionName;

/// Creates a function table at the most basic level.
/// @param functionTableType  One of the supported GeneratingRoutines.
/// @param tableSize          Size of the table, or 0 if deferred calculation is desired.
/// @param parameters         An array of parameters that define the function table.
- (instancetype)initWithType:(int)functionTableType
                        size:(int)tableSize
                  parameters:(NSArray *)parameters;


// The textual representation of the dynamic function table for Csound
- (NSString *)stringForCSD;

/// Returns an ftlen() wrapped around the output of this function table.
- (AKConstant *)length;

@end