//
//  OCSProduct.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Multiplies any number of a-rate signals.
 
 Based on http://www.csounds.com/manual/html/product.html
 */

@interface OCSProduct : OCSOpcode {
    NSMutableArray *inputs;
    OCSParam *output;
}

@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
- (id)initWithOperands:(OCSParam *)firstOperand,...;


@end
