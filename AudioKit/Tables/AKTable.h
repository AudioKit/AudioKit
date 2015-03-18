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

/// Run a mathematical function on each value of the function table
/// @param function Function to run on each table value
- (void)operateOnTableWithFunction:(float (^)(float))function;

/// Populate the table with given function on integer elements
/// @param function Function to applied to each index element
- (void)populateTableWithIndexFunction:(float (^)(int))function;

/// Populate a table based on a float value from zero to one.
/// @param function Function to be applied to a value that varies from 0 to 1.
- (void)populateTableWithFractionalWidthFunction:(float (^)(float))function;

/// Scale table by a constant scaling factor
/// @param scalingFactor Amount by which to scale each element of the table
- (void)scaleBy:(float)scalingFactor;

/// Create a table in which the maximum absolute value is 1 by scaling the whole table appropriately.
- (void)normalize;

/// Return absolute value of the table
- (void)absoluteValue;

+ (instancetype)standardSineWave;
+ (instancetype)standardSquareWave;
+ (instancetype)standardTriangleWave;
+ (instancetype)standardSawtoothWave;
+ (instancetype)standardReverseSawtoothWave;


/// Returns an ftlen() wrapped around the output of this table.
- (AKConstant *)length;
@end
