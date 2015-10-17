//
//  AKBeatClock.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

/// Looping beat clock notifying of time passing
@interface AKBeatClock : AKInstrument

/// Tempo in quarter notes
@property AKInstrumentProperty *tempo;

/// Number of beats to notify for every period
@property AKInstrumentProperty *numberOfBeats;

@end
