//
//  MathTestInstrument.h
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface MathTestInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *sum;
@property AKInstrumentProperty *difference;
@property AKInstrumentProperty *product;
@property AKInstrumentProperty *quotient;
@property AKInstrumentProperty *inverse;
@property AKInstrumentProperty *floor;
@property AKInstrumentProperty *round;
@property AKInstrumentProperty *fraction;
@property AKInstrumentProperty *absolute;
@property AKInstrumentProperty *log;
@property AKInstrumentProperty *log10;
@property AKInstrumentProperty *squareRoot;

@end
