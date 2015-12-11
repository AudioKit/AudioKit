//
//  AKMetronome.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/10/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

/// Metronome that ticks at a given tempo
@interface AKMetronome : AKInstrument

- (instancetype)initWithTempo:(float)tempo;
@end
