//
//  OCSParameter.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

/** OCS Parameters are arguments to Operations.  They come in three varieties for 
 audio rate, control rate, and constant values. When something is declared as an
 OCSParameter, it is at audio rate.  OCSControl and OCSConstant should be used for
 slower rate variables. 
 */

#define ocsp(__f__)  [OCSConstant constantWithFloat:__f__]
#define ocspi(__i__) [OCSConstant constantWithInt:__i__]
#define ocsps(__s__) [OCSConstant parameterWithString:__s__]
#define ocspfn(__fn__) [OCSConstant constantWithFilename:__fn__]

@interface OCSParameter : NSObject
{
    int _myID;
}

/// The CSD Text representation of the parameter's name
@property (nonatomic, strong) NSString *parameterString;

/// Helper method to avoid alloc and init each time.
/// @param name The name of the parameter as it should appear in the CSD File.
+ (id)parameterWithString:(NSString *)name;

/// Create a parameter available to all instruments in the orchestra.
+(id)globalParameter;

/// Create a parameter available to all instruments in the orchestra.
/// @param name The name of the parameter as it should appear in the CSD File.
+(id)globalParameterWithString:(NSString *)name;

- (instancetype)initWithString:(NSString *)name;

/// Allows insertion of math into parameters
/// @param expression A valid csound mathematical expression within an NSString.
- (instancetype)initWithExpression:(NSString *)expression;

/// Allows a parameter to be created using NSString style string formatting
/// @param format NSString style string format.
/// @param ...    Any necessary format values to insert.
+ (id)parameterWithFormat:(NSString *)format, ...;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void)resetID;

/// Helper function to create a new OCSParameter combined with the original
/// @param additionalParameter The additional parameter (should be of the same type)
- (id)plus:(OCSParameter *)additionalParameter;

/// Helper function to create a new OCSParameter with the CSD output scaled by another parameter
/// @param scalingFactor The scaling factor should be multiplied by
- (id)scaledBy:(OCSParameter *)scalingFactor;

/// Helper function to create a new OCSParameter with the CSD output scaled
/// @param divisor The scaling factor should be divided by
- (id)dividedBy:(OCSParameter *)divisor;

/// Helper function to return one-over-this-parameter
- (id)inverse;

/// Helper fucntion to convert logarithmic full scale decibel values to properly scaled amplitude
- (id)amplitudeFromFullScaleDecibel;

@end
