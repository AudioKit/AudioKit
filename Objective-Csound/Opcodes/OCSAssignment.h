//
//  OCSAssignment.h
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/// Simply a wrapper for the equal sign
@interface OCSAssignment : OCSOpcode 

@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
- (id)initWithInput:(OCSParam *)in;

@end

