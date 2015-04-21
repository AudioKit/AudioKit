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
        _tableValue = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        AKTableValue *tableValue = [[AKTableValue alloc] initWithTable:[AKTable standardSineWave]
                                                atFractionOfTotalWidth:akp(0.25)];
        AKAssignment *assignment = [[AKAssignment alloc] initWithOutput:_tableValue input:tableValue];
        [self connect:assignment];

    }
    return self;
}
@end
