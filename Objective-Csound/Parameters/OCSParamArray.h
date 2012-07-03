//
//  OCSParamArray.h
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConstantParam.h"

/// Am array of OCSParam variables
@interface OCSParamArray : NSObject

/// CSD Textual representation of the parameter's name.
- (NSString *)parameterString;
@property (nonatomic, strong) NSArray *params;

/// Explicitly using a nil-terminated list of OCSParams to create the array
/// @param firstParam At least one OCSConstantParam is required
/// @param ...        Terminate list with a nil.
+ (id)paramArrayFromParams:(OCSConstantParam *) firstParam, ...;

/// Returns the number of elements in the array.
- (int)count;

@end
