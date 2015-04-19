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
#import "AKCompatibility.h"

/** All purpose array of float values.  Often used for waveforms and 
 lookup tables at the time of note creation/initialization.
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKTable : NSObject

/// The number of elements in the table.  Often required to be a multiple of 2.
@property NSUInteger size;

/// All continguous values of the table, up to size.
@property (nonatomic, readonly, nullable) float *values;

/// A reference lookup number for the table.
@property (readonly) int number;

/// An entirely optional name, can be useful for debugging.
@property (nullable) NSString *name;

/// Creates an empty table with the default size (number of elements).
- (instancetype)init;

- (void)populateTableWithGenerator:(AKTableGenerator *)tableGenerator;

/// Creates an empty table with the given number of elements.
/// @param size Number of elements in the table
- (instancetype)initWithSize:(NSUInteger)size;

/// Creates a table from an array of objects.
/// @param array An array of NSNumber instances.
- (instancetype)initWithArray:(NSArray *)array;

/// Creates an empty table with the default size (number of elements).
+ (instancetype)table;

/// Access one of the values of the table
/// @param index The index of the value, must be less than size
- (float)valueAtIndex:(NSUInteger)index;

/// Access one of the values of the table
/// @param fractionalWidth The fractional distance into the table, must be less than 1
- (float)valueAtFractionalWidth:(float)fractionalWidth;

/// Run a mathematical function on each value of the function table
/// @param function Function to run on each table value
- (void)operateOnTableWithFunction:(float (^)(float))function;

/// Populate the table with given function on integer elements
/// @param function Function to applied to each index element
- (void)populateTableWithIndexFunction:(float (^)(NSUInteger))function;

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
NS_ASSUME_NONNULL_END
