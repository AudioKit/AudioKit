//
//  AKArray.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKConstant.h"

#define akpa(__p__, ...)   [AKArray arrayFromConstants:__p__, __VA_ARGS__]
#define akpna(__n__, ...)  [AKArray arrayFromNumbers:__n__, __VA_ARGS__]

/** An array of AKParameter variables
 */
@interface AKArray : NSObject

// CSD Textual representation of the parameter's name.
- (NSString *)parameterString;

/// The array of parameters stored.
@property (nonatomic, strong) NSMutableArray *constants;

- (void)addConstant:(AKConstant *)constant;

/// Explicitly using a nil-terminated list of AKConstants to create the array
/// @param firstConstant At least one AKConstant is required
/// @param ...        Terminate list with a nil.
+ (id)arrayFromConstants:(AKConstant *) firstConstant, ...;

/// Explicitly using a nil-terminated list of NSNumbers to create the array
/// @param firstValue At least one NSNumber is required
/// @param ...        Terminate list with a nil.
+ (id)arrayFromNumbers:(NSNumber *)firstValue, ...;

/// Returns the number of elements in the array.
- (int)count;

/// Takes two AKArrays and intertwines x1, y1, x2, y2, etc.
/// @param pairingArray The second array, must be equal in size.
- (AKArray *)pairWith:(AKArray *)pairingArray;

@end
