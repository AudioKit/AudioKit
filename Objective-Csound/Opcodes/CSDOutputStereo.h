//
//  CSDOutputStereo.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"


@interface CSDOutputStereo : CSDOpcode {
    CSDParam * inputLeft;
    CSDParam * inputRight;
}

-(NSString *) convertToCsd;

-(id) initWithInputLeft:(CSDParam *) inLeft
             InputRight:(CSDParam *) inRight;

@end
