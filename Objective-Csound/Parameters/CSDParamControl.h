//
//  CSDParamControl.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
// These are parameters that can change at k-Rate, or control rate

#import "CSDParam.h"

@interface CSDParamControl : CSDParam
-(id)initWithContinuous:(CSDContinuous *)continuous;
+(id)paramWithContinuous:(CSDContinuous *)continuous;

@end
