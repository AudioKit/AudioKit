//
//  OCSParameter+Operation.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter.h"
#import "OCSParameterArray.h"
#import "OCSFTable.h"

@interface OCSParameter (Operation)

/// The name of the class with the OCS prefix.
- (NSString *)operationName;

/// The opcode line for inclusion in instruments.
- (NSString *) stringForCSD;

@end
