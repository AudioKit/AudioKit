//
//  TableTestInstrument.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "TableTestInstrument.h"

@implementation TableTestInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Tables
        _sine            = [AKTable standardSineWave];
        _square          = [AKTable standardSquareWave];
        _triangle        = [AKTable standardTriangleWave];
        _sawtooth        = [AKTable standardSawtoothWave];
        _reverseSawtooth = [AKTable standardReverseSawtoothWave];
    }
    return self;
}
@end
