//
//  OCSOutputMono.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"


@interface OCSOutputMono : OCSOpcode {
    OCSParam *input;
}

- (id)initWithInput:(OCSParam *) i;

@end
