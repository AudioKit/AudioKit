//
//  OCSProduct.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSProduct : OCSOpcode {
    NSMutableArray *inputs;
    OCSParam *output;
}

@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
- (id)initWithInputs:(OCSParam *)firstInput,...;


@end
