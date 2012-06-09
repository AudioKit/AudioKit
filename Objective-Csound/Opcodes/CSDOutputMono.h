//
//  CSDOutputMono.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"


@interface CSDOutputMono : CSDOpcode {
    CSDParam * input;
}

-(NSString *) convertToCsd;

-(id) initWithInput:(CSDParam *) i;

@end
