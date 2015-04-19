//
//  MathTestInstrument.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "MathTestInstrument.h"

@implementation MathTestInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Instrument Properties
        _sum        = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _difference = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _product    = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _quotient   = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _inverse    = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _floor      = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _round      = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _fraction   = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _absolute   = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _log        = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _log10      = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        _squareRoot = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];

        AKConstant *three = akp(3.0);
        AKConstant *pointOneFour = akp(0.14);
        
        AKAssignment *sum        = [[AKAssignment alloc] initWithOutput:_sum        input:[three plus:pointOneFour]];
        AKAssignment *difference = [[AKAssignment alloc] initWithOutput:_difference input:[three minus:pointOneFour]];
        AKAssignment *product    = [[AKAssignment alloc] initWithOutput:_product    input:[three scaledBy:pointOneFour]];
        AKAssignment *quotient   = [[AKAssignment alloc] initWithOutput:_quotient   input:[three dividedBy:pointOneFour]];
        AKAssignment *inverse    = [[AKAssignment alloc] initWithOutput:_inverse    input:[three inverse]];
        AKAssignment *floor      = [[AKAssignment alloc] initWithOutput:_floor      input:[[three plus:pointOneFour] floor]];
        AKAssignment *round      = [[AKAssignment alloc] initWithOutput:_round      input:[[three minus:pointOneFour] round]];
        AKAssignment *fraction   = [[AKAssignment alloc] initWithOutput:_fraction   input:[[three plus:pointOneFour] fractionalPart]];
        AKAssignment *absolute   = [[AKAssignment alloc] initWithOutput:_absolute   input:[[three minus:quotient] absoluteValue]];
        AKAssignment *log        = [[AKAssignment alloc] initWithOutput:_log        input:[three log]];
        AKAssignment *log10      = [[AKAssignment alloc] initWithOutput:_log10      input:[three log10]];
        AKAssignment *squareRoot = [[AKAssignment alloc] initWithOutput:_squareRoot input:[three squareRoot]];
        
        [self connect:sum];
        [self connect:difference];
        [self connect:product];
        [self connect:quotient];
        [self connect:inverse];
        [self connect:floor];
        [self connect:round];
        [self connect:fraction];
        [self connect:absolute];
        [self connect:log];
        [self connect:log10];
        [self connect:squareRoot];
        
    }
    return self;
}
@end
