//
//  AKParameter+Operation.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter.h"
#import "AKArray.h"
#import "AKFTable.h"

@interface AKParameter (Operation)

/// The name of the class with the AK prefix.
- (NSString *)operationName;

// The opcode line for inclusion in instruments.
- (NSString *)stringForCSD;

// The text of the User Defined Opcode
- (NSString *)udoFile;

@end
