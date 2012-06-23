//
//  OCSAssignment.h
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSAssignment : OCSOpcode {
    OCSParam *input;
    OCSParam *output;
}

@property (nonatomic, strong) OCSParam *output;

- (id)initWithInput:(OCSParam *)in;

@end

