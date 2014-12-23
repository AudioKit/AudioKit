//
//  AKFSignal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"

/** Phase Vocoder Streaming output type 
 */

@interface AKFSignal : AKParameter

/// Creates an f-signal
/// @param aString Label for the f-signal
- (instancetype)initWithString:(NSString *)aString;

@end
