//
//  AKFFTTableReader.m
//  AudioKit
//
//  Auto-generated on 9/5/15.
//  Customised by Daniel Clelland on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pvsftr:
//  http://www.csounds.com/manual/html/pvsftr.html
//

#import "AKFFTTableReader.h"
#import "AKManager.h"

@implementation AKFFTTableReader
{
    AKFSignal * _input;
    AKTable * _amplitudeTable;
}

- (instancetype)initWithInput:(AKFSignal *)input
               amplitudeTable:(AKTable *)amplitudeTable
               frequencyTable:(AKTable *)frequencyTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _amplitudeTable = amplitudeTable;
        _frequencyTable = frequencyTable;
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithInput:(AKFSignal *)input
               amplitudeTable:(AKTable *)amplitudeTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _amplitudeTable = amplitudeTable;
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)fftTableReaderWithInput:(AKFSignal *)input
                         amplitudeTable:(AKTable *)amplitudeTable
{
    return [[AKFFTTableReader alloc] initWithInput:input
                                    amplitudeTable:amplitudeTable];
}

- (void)setFrequencyTable:(AKTable *)frequencyTable {
    _frequencyTable = frequencyTable;
    [self setUpConnections];
}

- (void)setOptionalFrequencyTable:(AKTable *)frequencyTable {
    [self setFrequencyTable:frequencyTable];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_input];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"pvsftr("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"pvsftr "];
    [csdString appendString:[self inputsString]];
    
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    [inputsString appendFormat:@"%@, ", _input];
    
    [inputsString appendFormat:@"%@", _amplitudeTable];
    
    if (_frequencyTable) {
        [inputsString appendFormat:@", %@", _frequencyTable];
    }
    
    return inputsString;
}

@end
