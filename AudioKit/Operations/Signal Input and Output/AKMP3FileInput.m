//
//  AKMP3FileInput.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Customized by Aurelius Prochazka on 12/25/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's mp3in:
//  http://www.csounds.com/manual/html/mp3in.html
//

#import "AKMP3FileInput.h"
#import "AKManager.h"

@implementation AKMP3FileInput
{
    NSString *_filename;
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _filename = filename;
    }
    return self;
}

+ (instancetype)mp3WithFilename:(NSString *)filename
{
    return [[AKMP3FileInput alloc] initWithFilename:filename];
}


- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ mp3in ", self];

    [csdString appendFormat:@"\"%@\"", _filename];
    return csdString;
}

@end
