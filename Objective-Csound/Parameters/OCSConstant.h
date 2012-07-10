//
//  OCSConstant.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"

/// These are i-Rate parameters, constant for a given opcode call or note
@interface OCSConstant : OCSControl

/// Creates a p-value parameter.  Nearly deprecated except for use with duration.
/// @param p P-Value, or column number.  
- (id)initWithPValue:(int)p;

/// Common method to create float parameters.  So much so that ocsp() macro was created and preferred.
/// @param value Value to set the parameter to.
+ (id)parameterWithFloat:(float)value;

/// Common method to create integer parameters.  So much so that ocspi() macro was created and preferred.
/// @param value Value to set the parameter to.
+ (id)parameterWithInt:(int)value;

/// Common method to create file locations.  So much so that ocspfn() macro was created and preferred.
/// @param filename String containing full path of file.
+ (id)parameterWithFilename:(NSString *)filename;

@end
