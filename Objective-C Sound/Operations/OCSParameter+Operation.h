//
//  OCSParameter+Operation.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter.h"
#import "OCSArray.h"
#import "OCSFTable.h"

@interface OCSParameter (Operation)

/// The name of the class with the OCS prefix.
- (NSString *)operationName;

/// The opcode line for inclusion in instruments.
- (NSString *) stringForCSD;

/// The text of the User Defined Opcode
- (NSString *) udoFile;

@end
