//
//  AKBeatClock.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKFoundation.h"

@interface AKBeatClock : AKInstrument

@property AKInstrumentProperty *tempo;
@property AKInstrumentProperty *numberOfBeats;

@end
