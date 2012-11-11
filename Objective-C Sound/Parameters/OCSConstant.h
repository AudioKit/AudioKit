//
//  OCSConstant.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"

/// These are i-Rate parameters, constant for a given operation call or note
@interface OCSConstant : OCSControl

/// Common method to create float parameters.  So much so that ocsp() macro was created and preferred.
/// @param value Value to set the parameter to.
+ (id)constantWithFloat:(float)value;

/// Common method to create float parameters.  So much so that ocsp() macro was created and preferred.
/// @param number Value to set the parameter to.
+ (id)constantWithNumber:(NSNumber *)number;

/// Common method to create integer parameters.  So much so that ocspi() macro was created and preferred.
/// @param value Value to set the parameter to.
+ (id)constantWithInt:(int)value;

/// Common method to create file locations.  So much so that ocspfn() macro was created and preferred.
/// @param filename String containing full path of file.
+ (id)constantWithFilename:(NSString *)filename;

/// Take a control value and force the first value to be used as a constant
/// @param control Control value to be coerced into a constant
+ (id)constantWithControl:(OCSControl *)control;

@end
