//
//  AKFFTTableWriter.m
//  AudioKit
//
//  Auto-generated on 9/5/15.
//  Customised by Daniel Clelland on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's pvsftw:
//  http://www.csounds.com/manual/html/pvsftw.html
//

#import "AKFFTTableWriter.h"
#import "AKManager.h"

@implementation AKFFTTableWriter
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

+ (instancetype)fftTableWriterWithInput:(AKFSignal *)input
                         amplitudeTable:(AKTable *)amplitudeTable
{
    return [[AKFFTTableWriter alloc] initWithInput:input
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

    [inlineCSDString appendString:@"pvsftw("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ pvsftw ", self];
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
