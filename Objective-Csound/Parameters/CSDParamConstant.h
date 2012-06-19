//
//  CSDParamConstant.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

// These are i-Rate parameters, constant for a given opcode call or note

#import "CSDParamControl.h"

@interface CSDParamConstant : CSDParamControl

-(id)initWithFloat:(float)aFloat;
-(id)initWithInt:(int)aInt;
-(id)initWithPValue:(int)aPValue;
-(id)initWithContinuous:(CSDContinuous *)continuous;
+(id)paramWithFloat:(float)aFloat;
+(id)paramWithInt:(int)aInt;
+(id)paramWithPValue:(int)aPValue;
+(id)paramWithContinuous:(CSDContinuous *)continuous;

@end
