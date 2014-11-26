//
//  AKCabasa.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/26/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's cabasa:
//  http://www.csounds.com/manual/html/cabasa.html
//

#import "AKCabasa.h"

@implementation AKCabasa

- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
        _dampingFactor = dampingFactor;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
        // Default Values
        _count = akp(100);
        _dampingFactor = akp(0.93);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKCabasa alloc] init];
}

- (void)setOptionalCount:(AKConstant *)count {
    _count = count;
}

- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}

- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_maximumDuration = akp(1);
    AKConstant *_amplitude = akp(1);
    return [NSString stringWithFormat:
            @"%@ cabasa %@, %@, %@, %@",
            self,
            _amplitude,
            _maximumDuration,
            _count,
            _dampingFactor];
}


@end
