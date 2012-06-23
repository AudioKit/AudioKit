//
//  OCSSum.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSSum : OCSOpcode {
    NSMutableArray *inputs;
    OCSParam *output;
}

@property (nonatomic, strong) OCSParam *output;

- (id)initWithInputs:(OCSParam *)firstInput,...;

@end
