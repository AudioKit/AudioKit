//
//  AKTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/1/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKTableGenerator.h"
#import "AKConstant.h"

/** All purpose array of float values.  Often used for waveforms and 
 lookup tables at the time of note creation/initialization.
 */
@interface AKTable : NSObject

/// The number of elements in the table.  Often required to be a multiple of 2.
@property int size;

/// A reference lookup number for the table.
@property (readonly) int number;

/// An entirely optional name, can be useful for debugging.
@property NSString *name;

/// Creates an empty table with the default size (number of elements).
- (instancetype)init;

- (void)populateTableWithGenerator:(AKTableGenerator *)tableGenerator;

/// Creates an empty table with the given number of elements.
/// @param size Number of elements in the table
- (instancetype)initWithSize:(int)size;

- (instancetype)initWithArray:(NSArray *)array;

/// Creates an empty table with the default size (number of elements).
+ (instancetype)table;

- (void)populateTableWithIndexFunction:(float (^)(int))function;

- (void)populateTableWithFractionalWidthFunction:(float (^)(float))function;

+ (instancetype)standardSineWave;
+ (instancetype)standardSquareWave;
+ (instancetype)standardTriangleWave;
+ (instancetype)standardSawtoothWave;
+ (instancetype)standardReverseSawtoothWave;


/// Returns an ftlen() wrapped around the output of this table.
- (AKConstant *)length;
@end
