//
//  AKTableValue.m
//  AudioKit
//
//  Auto-generated on 2/27/15.
//  Customized by Aurelius Prochazka to have many more intializer options.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's table3:
//  http://www.csounds.com/manual/html/table3.html
//

#import "AKTableValue.h"
#import "AKManager.h"

@implementation AKTableValue
{
    AKFunctionTable * _functionTable;
    AKParameter * _index;
    AKConstant *_useFractionalWidth;
}

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                              atIndex:(AKParameter *)index
                           withOffset:(AKConstant *)offset
                   usingWrappingIndex:(BOOL)useWrappingIndex
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _index = index;
        _offset = offset;
        _useWrappingIndex = useWrappingIndex;
        _useFractionalWidth = akp(NO);
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                              atIndex:(AKParameter *)index
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _index = index;
        // Default Values
        _offset = akp(0);
        _useWrappingIndex = NO;
        _useFractionalWidth = akp(NO);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)valueOfFunctionTable:(AKFunctionTable *)functionTable
                             atIndex:(AKParameter *)index
{
    return [[AKTableValue alloc] initWithFunctionTable:functionTable
                                               atIndex:index];
}


- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
               atFractionOfTotalWidth:(AKParameter *)fractionalIndex
                           withOffset:(AKConstant *)offset
                   usingWrappingIndex:(BOOL)useWrappingIndex
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _index = fractionalIndex;
        _offset = offset;
        _useWrappingIndex = useWrappingIndex;
        _useFractionalWidth = akp(YES);
        [self setUpConnections];
    }
    return self;
}

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
               atFractionOfTotalWidth:(AKParameter *)fractionalIndex
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _index = fractionalIndex;
        // Default Values
        _offset = akp(0);
        _useWrappingIndex = NO;
        _useFractionalWidth = akp(YES);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)valueOfFunctionTable:(AKFunctionTable *)functionTable
              atFractionOfTotalWidth:(AKParameter *)fractionalIndex;
{
    return [[AKTableValue alloc] initWithFunctionTable:functionTable
                                atFractionOfTotalWidth:fractionalIndex];
}

- (void)setOffset:(AKConstant *)offset {
    _offset = offset;
    [self setUpConnections];
}

- (void)setOptionalOffset:(AKConstant *)offset {
    [self setOffset:offset];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_functionTable, _index, _offset];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];
    
    [inlineCSDString appendString:@"table3("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];
    
    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ table3 ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    // Constant Values
    
    
    if ([_index class] == [AKAudio class]) {
        [inputsString appendFormat:@"%@, ", _index];
    } else {
        [inputsString appendFormat:@"AKAudio(%@), ", _index];
    }
    
    [inputsString appendFormat:@"%@, ", _functionTable];
    
    [inputsString appendFormat:@"%@, ", _useFractionalWidth];
    
    [inputsString appendFormat:@"%@, ", _offset];
    
    [inputsString appendFormat:@"%d", _useWrappingIndex];
    return inputsString;
}

@end
