//
//  OCSParameter.h
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

/** OCS Parameters are arguments to Csound opcodes.  They come in three varieties for 
 audio rate, control rate, and constant values. When something is declared as an
 OCSParameter, it is at audio rate.  OCSControl and OCSConstant should be used for
 slower rate variables. 
 */

#define ocsp(__f__)  [OCSConstant parameterWithFloat:__f__]
#define ocspi(__i__) [OCSConstant parameterWithFloat:__i__]
#define ocsps(__s__) [OCSConstant parameterWithString:__s__]
#define ocspfn(__fn__) [OCSConstant parameterWithFilename:__fn__]

@interface OCSParameter : NSObject
{
    NSString *type; 
    NSString *parameterString;
    int _myID;
}

/// The CSD Text representation of the parameter's name
@property (nonatomic, strong) NSString *parameterString;

/// Returns an instance with the give name for the parameter
/// @param name The name of the parameter as it should appear in the CSD File.
- (id)initWithString:(NSString *)name;

/// Helper method to avoid alloc and init each time.
/// @param name The name of the parameter as it should appear in the CSD File.
+ (id)parameterWithString:(NSString *)name;

/// Allows insertion of math into parameters
/// @param expression A valid csound mathematical expression within an NSString.
- (id)initWithExpression:(NSString *)expression;

/// Allows a parameter to be created using NSString style string formatting
/// @param format NSString style string format.
/// @param ...    Any necessary format values to insert.
+ (id)parameterWithFormat:(NSString *)format, ...;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void) resetID;

/// Helper function to create a new OCSParameter with the CSD output scaled
/// @param scalingFactor The floating point number by which to scale.
- (id)scaledBy:(float)scalingFactor;

/// Helper fucntion to convert logarithmic full scale decibel values to properly scaled amplitude
- (id)amplitudeFromFullScaleDecibel;
@end
