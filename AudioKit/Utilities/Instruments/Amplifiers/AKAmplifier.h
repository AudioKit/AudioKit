//
//  AKAmplifier.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

/** A monophonic amplification system with amplitude control.  
 This instrument is intended to be used as the last instrument in a processing chain.
 */
@interface AKAmplifier : AKInstrument

@property (nonatomic) AKInstrumentProperty *amplitude;

- (instancetype)initWithInput:(AKAudio *)audioSource;

@end
