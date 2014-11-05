//
//  AKParameter.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

/** Parameters are arguments to Operations.  They come in three varieties for 
 audio rate, control rate, and constant values. When something is declared as an
 AKParameter, it is at audio rate.  AKControl and AKConstant should be used for
 slower rate variables. 
 */

#define akp(__f__)  [AKConstant constantWithFloat:__f__]
#define akpi(__i__) [AKConstant constantWithInt:__i__]
#define akps(__s__) [AKConstant parameterWithString:__s__]
#define akpfn(__fn__) [AKConstant constantWithFilename:__fn__]

#import <Foundation/Foundation.h>

@interface AKParameter : NSObject
{
    int _myID;
}

// The CSD Text representation of the parameter's name
@property (nonatomic, strong) NSString *parameterString;

/// Helper method to avoid alloc and init each time.
/// @param name The name of the parameter as it should appear in the output file.
+ (instancetype)parameterWithString:(NSString *)name;

/// Create a parameter available to all instruments in the orchestra.
+ (instancetype)globalParameter;

/// Create a parameter available to all instruments in the orchestra.
/// @param name The name of the parameter as it should appear in the output File.
+ (instancetype)globalParameterWithString:(NSString *)name;

- (instancetype)initWithString:(NSString *)name;

/// Allows insertion of math into parameters
/// @param expression A valid csound mathematical expression within an NSString.
- (instancetype)initWithExpression:(NSString *)expression;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

/// Helper function to create a new AKParameter combined with the original
/// @param additionalParameter The additional parameter (should be of the same type)
- (instancetype)plus:(AKParameter *)additionalParameter;

/// Helper function to create a new AKParameter with the output scaled by another parameter
/// @param scalingFactor The scaling factor should be multiplied by
- (instancetype)scaledBy:(AKParameter *)scalingFactor;

/// Helper function to create a new AKParameter with the output scaled
/// @param divisor The scaling factor should be divided by
- (instancetype)dividedBy:(AKParameter *)divisor;

/// Helper function to return one-over-this-parameter
- (instancetype)inverse;

/// Helper fucntion to convert logarithmic full scale decibel values to properly scaled amplitude
- (instancetype)amplitudeFromFullScaleDecibel;

@end
