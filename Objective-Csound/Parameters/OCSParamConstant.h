//
//  OCSParamConstant.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

// These are i-Rate parameters, constant for a given opcode call or note

#import "OCSParamControl.h"

@interface OCSParamConstant : OCSParamControl

-(id)initWithFloat:(float)aFloat;
-(id)initWithInt:(int)aInt;
-(id)initWithPValue:(int)aPValue;
+(id)paramWithFloat:(float)aFloat;
+(id)paramWithInt:(int)aInt;
+(id)paramWithPValue:(int)aPValue;

@end
