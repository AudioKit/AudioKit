//
//  OscillatorInstrument.h
//  TableDemo
//
//  Created by Aurelius Prochazka on 4/17/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface OscillatorInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;
@property AKInstrumentProperty *frequency;
@property AKOscillator *oscillator;

@end
