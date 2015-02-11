//
//  FMOscillator.h
//  TouchRegions
//
//  Created by Aurelius Prochazka on 8/7/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"
#import "AKFoundation.h"

@interface FMOscillator : AKInstrument

@property AKInstrumentProperty *frequency;
@property AKInstrumentProperty *carrierMultiplier;
@property AKInstrumentProperty *modulatingMultiplier;
@property AKInstrumentProperty *modulationIndex;
@property AKInstrumentProperty *amplitude;
@end
