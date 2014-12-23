//
//  AKSekere.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's sekere:
//  http://www.csounds.com/manual/html/sekere.html
//

#import "AKSekere.h"
#import "AKManager.h"

@implementation AKSekere

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
        _count = akp(64);    
        _dampingFactor = akp(0.1);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKSekere alloc] init];
}

- (void)setOptionalCount:(AKConstant *)count {
    _count = count;
}
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}

- (NSString *)stringForCSD {
    // Constant Values  
    AKConstant *_amplitude = akp(1);        
    AKConstant *_energyReturn = akp(0);        
    AKConstant *_maximumDuration = akp(1);        
    return [NSString stringWithFormat:
            @"%@ sekere %@, %@, %@, (1 - %@), %@",
            self,
            _amplitude,
            _maximumDuration,
            _count,
            _dampingFactor,
            _energyReturn];
}

@end
