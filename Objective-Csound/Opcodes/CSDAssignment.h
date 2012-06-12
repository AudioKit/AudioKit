//
//  CSDAssignment.h
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDAssignment : CSDOpcode {
    CSDParam * input;
    CSDParam * output;
}

@property (nonatomic, strong) CSDParam * output;

-(id) initWithInput:(CSDParam *)in;

@end

