//
//  OCSOutputStereo.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"


@interface OCSOutputStereo : OCSOpcode {
    OCSParam *inputLeft;
    OCSParam *inputRight;
}

- (id)initWithMonoInput:(OCSParam *) in;
- (id)initWithInputLeft:(OCSParam *) inLeft
             InputRight:(OCSParam *) inRight;

@end
