//
//  OCSOperation.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameterArray.h"
#import "OCSFTable.h"

/** Generic function all OCS Opcodes need access to. */

@interface OCSOperation : NSObject 

/// The name of the class with the OCS prefix.
- (NSString *)operationName;

/// The opcode line for inclusion in instruments.
- (NSString *) stringForCSD;

/// Helper to allow the parameter string to appear in formatted strings.
- (NSString *)description;

@end
