//
//  OCSParam.h
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

/** OCS Parameters are arguments to Csound opcodes.  They come in three varieties for 
 audio rate, control rate, and constant values. When something is declared as an
 OCSParam, it is at audio rate.  OCSParamControl and OCSParamConstant should be used for
 slower rate variables. 
 */

@interface OCSParam : NSObject
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
+ (id)paramWithString:(NSString *)name;

/// Allows insertion of math into parameters
/// @param expression A valid csound mathematical expression within an NSString.
- (id)initWithExpression:(NSString *)expression;

/// Allows a parameter to be created using NSString style string formatting
/// @param format NSString style string format.
/// @param ...    Any necessary format values to insert.
+ (id)paramWithFormat:(NSString *)format, ...;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void) resetID;
@end
