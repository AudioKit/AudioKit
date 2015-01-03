//
//  AKSekere.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sekere:
//  http://www.csounds.com/manual/html/sekere.html
//

#import "AKSekere.h"
#import "AKManager.h"

@implementation AKSekere

- (instancetype)initWithCount:(AKConstant *)count
                dampingFactor:(AKConstant *)dampingFactor
                    amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
        _dampingFactor = dampingFactor;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _count = akp(64);
        _dampingFactor = akp(0.1);
        _amplitude = akp(1);
    }
    return self;
}

+ (instancetype)sekere
{
    return [[AKSekere alloc] init];
}

- (void)setOptionalCount:(AKConstant *)count {
    _count = count;
}
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}
- (void)setOptionalAmplitude:(AKConstant *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_energyReturn = akp(0);        
    AKConstant *_maximumDuration = akp(1);        
    [csdString appendFormat:@"%@ sekere ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    [csdString appendFormat:@"%@, ", _maximumDuration];
    
    [csdString appendFormat:@"%@, ", _count];
    
    [csdString appendFormat:@"(1 - %@), ", _dampingFactor];
    
    [csdString appendFormat:@"%@", _energyReturn];
    return csdString;
}

@end
