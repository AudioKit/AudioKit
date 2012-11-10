//
//  OCSArray.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConstant.h"

#define ocspa(__p__, ...)   [OCSArray arrayFromParams:__p__, __VA_ARGS__]
#define ocspna(__n__, ...)  [OCSArray arrayFromNumbers:__n__, __VA_ARGS__]

/// Am array of OCSParameter variables
@interface OCSArray : NSObject

/// CSD Textual representation of the parameter's name.
- (NSString *)parameterString;

/// The array of parameters stored.
@property (nonatomic, strong) NSArray *params;

/// Explicitly using a nil-terminated list of OCSParameters to create the array
/// @param firstParam At least one OCSConstant is required
/// @param ...        Terminate list with a nil.
+ (id)arrayFromParams:(OCSConstant *) firstParam, ...;

/// Explicitly using a nil-terminated list of NSNumbers to create the array
/// @param firstValue At least one NSNumber is required
/// @param ...        Terminate list with a nil.
+ (id)arrayFromNumbers:(NSNumber *)firstValue, ...;

/// Returns the number of elements in the array.
- (int)count;

/// Takes two OCSArrays and intertwines x1, y1, x2, y2, etc.
/// @param pairingArray The second array, must be equal in size.
- (OCSArray *)pairWith:(OCSArray *)pairingArray;

- (id)fTableString;

@end
