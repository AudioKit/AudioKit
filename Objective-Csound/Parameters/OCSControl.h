//
//  OCSControl.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter.h"

/// These are parameters that can change at k-Rate, or control rate
@interface OCSControl : OCSParameter

/// Converts pitch to frequency
- (id)toCPS;
@end
