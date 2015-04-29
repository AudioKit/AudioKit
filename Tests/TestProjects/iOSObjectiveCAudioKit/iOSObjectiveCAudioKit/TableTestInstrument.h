//
//  TableTestInstrument.h
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface TableTestInstrument : AKInstrument

// Instrument Properties
@property AKInstrumentProperty *amplitude;

@property AKTable *sine;
@property AKTable *square;
@property AKTable *triangle;
@property AKTable *sawtooth;
@property AKTable *reverseSawtooth;
@end


