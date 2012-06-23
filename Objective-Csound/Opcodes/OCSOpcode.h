//
//  OCSOpcode.h
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamArray.h"
#import "OCSFunctionTable.h"

@interface OCSOpcode : NSObject 
@property (nonatomic, strong) NSString *opcode;

- (NSString *)opcodeName;
- (NSString *)convertToCsd;
@end
