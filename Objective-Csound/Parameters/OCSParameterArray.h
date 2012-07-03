//
//  OCSParameterArray.h
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConstant.h"

/// Am array of OCSParameter variables
@interface OCSParameterArray : NSObject

/// CSD Textual representation of the parameter's name.
- (NSString *)parameterString;
@property (nonatomic, strong) NSArray *params;

/// Explicitly using a nil-terminated list of OCSParameters to create the array
/// @param firstParam At least one OCSConstant is required
/// @param ...        Terminate list with a nil.
+ (id)paramArrayFromParams:(OCSConstant *) firstParam, ...;

/// Returns the number of elements in the array.
- (int)count;

@end
