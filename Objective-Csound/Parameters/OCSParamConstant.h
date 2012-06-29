//
//  OCSParamConstant.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamControl.h"

/// These are i-Rate parameters, constant for a given opcode call or note
@interface OCSParamConstant : OCSParamControl

///// Most common method.  So much so that ocsp() macro was created and preferred.
///// @param value Value to set the parameter to.
//- (id)initWithFloat:(float)value;
//
///// Creates an integer parameter.  Nearly deprecated since integers are usually
///// calculatable lengths or enumerated types.
///// @param value Value to set the parameter to.
//- (id)initWithInt:(int)value;

/// Creates a p-value parameter.  Nearly deprecated except for use with duration.
/// @param p P-Value, or column number.  
- (id)initWithPValue:(int)p;

/// Helper function to avoid alloc and init each time
/// @param value Value to set the parameter to.
+ (id)paramWithFloat:(float)value;

/// Helper function to avoid alloc and init each time
/// @param value Value to set the parameter to.
+ (id)paramWithInt:(int)value;

/// Helper function to avoid alloc and init each time
/// @param filename String containing full path of file.
+ (id)paramWithFilename:(NSString *)filename;

@end
