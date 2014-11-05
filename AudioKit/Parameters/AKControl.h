//
//  AKControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter.h"

/** These are parameters that can change at control rate
 */
@interface AKControl : AKParameter

/// Converts pitch to frequency
- (instancetype)toCPS;
@end
