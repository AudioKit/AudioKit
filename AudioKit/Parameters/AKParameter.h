//
//  AKParameter.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/5/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

/** Parameters are arguments to Operations.  They come in three varieties for 
 audio rate, control rate, and constant values. When something is declared as an
 AKParameter, it is at audio rate.  AKControl and AKConstant should be used for
 slower rate variables. 
 */

// -----------------------------------------------------------------------------
#  pragma mark - Shortcuts for AKConstant creation
// -----------------------------------------------------------------------------

#define akp(__f__)  [AKConstant constantWithFloat:__f__]
#define akpi(__i__) [AKConstant constantWithInt:__i__]
#define akps(__s__) [AKConstant parameterWithString:__s__]
#define akpfn(__fn__) [AKConstant constantWithFilename:__fn__]

#import <Foundation/Foundation.h>
#import "AKCompatibility.h"

NS_ASSUME_NONNULL_BEGIN
@interface AKParameter : NSObject

// -----------------------------------------------------------------------------
#  pragma mark - Initialization and String Representation
// -----------------------------------------------------------------------------

/// The CSD Text representation of the parameter's name.
@property NSString *parameterString;

@property NSString *state;
@property NSArray  *dependencies;

/// The unique ID number for the parameter.
@property (readonly) NSUInteger parameterID;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

/// Helper method to avoid alloc and init each time.
/// @param name The name of the parameter as it should appear in the output file.
+ (instancetype)parameterWithString:(NSString *)name;

/// Create a parameter available to all instruments in the orchestra.
+ (instancetype)globalParameter;

/// Create a parameter available to all instruments in the orchestra.
/// @param name The name of the parameter as it should appear in the output File.
+ (instancetype)globalParameterWithString:(NSString *)name;

/// Allows a parameter to be created using NSString style string formatting
/// @param format NSString style string format.
/// @param ...    Any necessary format values to insert.
+ (instancetype)parameterWithFormat:(NSString *)format, ...;

- (instancetype)initWithString:(NSString *)name;

/// Allows insertion of math into parameters
/// @param expression A valid csound mathematical expression within an NSString.
- (instancetype)initWithExpression:(NSString *)expression;

// -----------------------------------------------------------------------------
#  pragma mark - Current, Initial, Minimum, and Maximum Properties
// -----------------------------------------------------------------------------

/// Current value of the parameter.
@property (nonatomic, assign) float value;

/// Alternative to "value", works better on OSX.
@property (nonatomic, assign) float floatValue;

/// Start value for initialization.
@property (nonatomic, assign) float initialValue;

/// Minimum Value allowed.
@property (nonatomic, assign) float minimum;

/// Maximum Value allowed.
@property (nonatomic, assign) float maximum;

// -----------------------------------------------------------------------------
#  pragma mark - Initialization and Range Definition
// -----------------------------------------------------------------------------

/// Initialize the control with an initial value and bounds.
/// @param initialValue Initial value.
- (instancetype)initWithValue:(float)initialValue;

/// Initialize the control with bounds.
/// @param minimum Minimum value.
/// @param maximum Maximum value.
- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;

/// Initialize the control with an initial value and bounds.
/// @param initialValue Initial value.
/// @param minimum Minimum value.
/// @param maximum Maximum value.
- (instancetype)initWithValue:(float)initialValue
                      minimum:(float)minimum
                      maximum:(float)maximum;

/// Scale the property in its own range given another range and value
/// @param value   Source value.
/// @param minimum Minimum value in source range.
/// @param maximum Maximum value in source range.
- (void)scaleWithValue:(float)value
               minimum:(float)minimum
               maximum:(float)maximum;

/// Sets the current value to the initial value.
- (void)reset;

/// Randomize the current value between the minimum and maximum values
- (void)randomize;

// -----------------------------------------------------------------------------
#  pragma mark - Helper Functions
// -----------------------------------------------------------------------------

/// Helper function to create a new AKParameter added to the additional parameter
/// @param additionalParameter The additional parameter (should be of the same type)
- (instancetype)plus:(AKParameter *)additionalParameter;

/// Helper function to create a new AKParameter subtracted from the additional parameter
/// @param subtrahend The subtracted parameter (should be of the same type)
- (instancetype)minus:(AKParameter *)subtrahend;

/// Helper function to create a new AKParameter with the output scaled by another parameter
/// @param scalingFactor The scaling factor should be multiplied by
- (instancetype)scaledBy:(AKParameter *)scalingFactor;

/// Helper function to create a new AKParameter with the output scaled
/// @param divisor The scaling factor should be divided by
- (instancetype)dividedBy:(AKParameter *)divisor;

/// Helper function to return one-over-this-parameter
- (instancetype)inverse;

/// Helper function to create an integer
- (instancetype)floor;

/// Helper function to create an integer
- (instancetype)round;

/// Helper function to return fractional part
- (instancetype)fractionalPart;

/// Helper function to return absolute value
- (instancetype)absoluteValue;

/// Helper function to return natural log
- (instancetype)log;

/// Helper function to return log base 10
- (instancetype)log10;

/// Helper function to return square root
- (instancetype)squareRoot;

/// Helper function to convert logarithmic full scale decibel values to properly scaled amplitude
- (instancetype)amplitudeFromFullScaleDecibel;

@end
NS_ASSUME_NONNULL_END

