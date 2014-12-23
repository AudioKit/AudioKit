//
//  AKControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"

/** These are parameters that can change at control rate
 */
@interface AKControl : AKAudio

/// Converts pitch to frequency
- (instancetype)toCPS;

@end
