//
//  AKMP3FileInput.m
//  AudioKit
//
//  Auto-generated on 3/13/15.
//  Customized by Aurlius Prochazka on 3/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's mp3in:
//  http://www.csounds.com/manual/html/mp3in.html
//

#import "AKMP3FileInput.h"
#import "AKManager.h"

@implementation AKMP3FileInput
{
    NSString * _filename;
}

- (instancetype)initWithFilename:(NSString *)filename
                       startTime:(AKConstant *)startTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = filename;
        _startTime = startTime;
}
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = filename;
        // Default Values
        _startTime = akp(0);
    }
    return self;
}

+ (instancetype)mp3WithFilename:(NSString *)filename
{
    return [[AKMP3FileInput alloc] initWithFilename:filename];
}

- (void)setStartTime:(AKConstant *)startTime {
    _startTime = startTime;
}

- (void)setOptionalStartTime:(AKConstant *)startTime {
    [self setStartTime:startTime];
}

- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ mp3in ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];
    
    [inputsString appendFormat:@"\"%@\", ", _filename];
    
    [inputsString appendFormat:@"%@", _startTime];
    return inputsString;
}

@end
