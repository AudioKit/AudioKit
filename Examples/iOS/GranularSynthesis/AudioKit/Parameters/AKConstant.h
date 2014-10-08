//
//  AKConstant.h	
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"

/// These are i-Rate parameters, constant for a given operation call or note
@interface AKConstant : AKControl

/// Common method to create float parameters.  So much so that akp() macro was created and preferred.
/// @param value Value to set the parameter to.
+ (instancetype)constantWithFloat:(float)value;

/// Common method to create float parameters.  So much so that akp() macro was created and preferred.
/// @param number Value to set the parameter to.
+ (instancetype)constantWithNumber:(NSNumber *)number;

/// Common method to create integer parameters.  So much so that akpi() macro was created and preferred.
/// @param value Value to set the parameter to.
+ (instancetype)constantWithInt:(int)value;

/// Common method to create file locations.  So much so that akpfn() macro was created and preferred.
/// @param filename String containing full path of file.
+ (instancetype)constantWithFilename:(NSString *)filename;

/// Take a control value and force the first value to be used as a constant
/// @param control Control value to be coerced into a constant
+ (instancetype)constantWithControl:(AKControl *)control;

/// Initialize the constant with a number
/// @param value Number value of the constant
- (instancetype)initWithValue:(NSNumber *)value;

@end
