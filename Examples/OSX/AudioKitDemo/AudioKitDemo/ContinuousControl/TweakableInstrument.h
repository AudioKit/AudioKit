//
//  TweakableInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface TweakableInstrument : AKInstrument

@property AKInstrumentProperty *amplitude;
@property AKInstrumentProperty *frequency;
@property AKInstrumentProperty *modulation;
@property AKInstrumentProperty *modIndex;

@end
