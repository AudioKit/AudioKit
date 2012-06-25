//
//  OCSParamArray.h
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamConstant.h"

/// Am array of OCSParam variables
@interface OCSParamArray : NSObject

/// CSD Textual representation of the parameter's name.
@property (nonatomic, strong) NSString *parameterString;


/// Using an array of floats to automatically create an array of OCSParams
/// @param numbers The array floats to be converted.
/// @param count   The size of the floating point numbers array.
+ (id)paramArrayFromFloats:(float *)numbers count:(NSUInteger)count;

/// Explicitly using a nil-terminated list of OCSParams to create the array
/// @param firstParam At least one OCSParamConstant is required
/// @param ...        Terminate list with a nil.
+ (id)paramArrayFromParams:(OCSParamConstant *) firstParam, ...;

@end
