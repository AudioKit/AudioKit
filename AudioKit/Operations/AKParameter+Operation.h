//
//  AKParameter+Operation.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"
#import "AKTable.h"
#import "AKSoundFileTable.h"

/** This category allows for operations to simply be considered as parameters to other operations.
 */
@interface AKParameter (Operation)

/// The name of the class with the AK prefix.
- (NSString *)operationName;

//- (NSString *)state;

// The opcode line for inclusion in instruments without giving it a name.
- (NSString *)inlineStringForCSD;

// The opcode line for inclusion in instruments.
- (NSString *)stringForCSD;

// The text of the User Defined Opcode
- (NSString *)udoString;

@end
