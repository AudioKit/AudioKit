//
//  AKFTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKArray.h"
#import "AKTypes.h"

/** Generic AK Function Table definiton.

 By default, the table will not be normalized,
 but it maybe normalized by setting the isNormalized property to YES.

 Currently supported function table types are

 - Sound File (AKSoundFileTable)
 - Exponential Curves (AKExponentialCurvesTable)
 - Sines (AKSineTable)
 - Windows (AKWindowsTable)

 */
@interface AKFTable : AKConstant

/// This can be set to normalize the table, or not. It is not normalized by default.
@property (nonatomic,assign) BOOL isNormalized;

/// The parameters list which can be assigned by subclasses
@property AKArray *parameters;

/// The size of the FTable
@property int size;

/// Creates a function table at the most basic level.
/// @param fTableType  One of the supported GeneratingRoutines.
/// @param tableSize          Size of the table, or 0 if deferred calculation is desired.
/// @param parameters         An array of parameters that define the function table.
- (instancetype)initWithType:(AKFTableType)fTableType
                        size:(int)tableSize
                  parameters:(AKArray *)parameters;

/// Creates a function table without specifying a size, deferring that calculation.
/// @param fTableType  One of the supported GeneratingRoutines.
/// @param parameters         An array of parameters that define the function table.
- (instancetype)initWithType:(AKFTableType)fTableType
                  parameters:(AKArray *)parameters;

// The textual representation of the dynamic function table for Csound
- (NSString *)stringForCSD;

// The textual representation of the global function table for Csound
- (NSString *)fTableStringForCSD;


/// Returns an ftlen() wrapped around the output of this function table.
- (AKConstant *)length;

@end