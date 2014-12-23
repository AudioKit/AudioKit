//
//  AKRandomControl.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's random:
//  http://www.csounds.com/manual/html/random.html
//

#import "AKRandomControl.h"
#import "AKManager.h"

@implementation AKRandomControl

- (instancetype)initWithLowerBound:(AKParameter *)lowerBound
                        upperBound:(AKParameter *)upperBound
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _lowerBound = lowerBound;
        _upperBound = upperBound;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _lowerBound = akp(0);    
        _upperBound = akp(1);    
    }
    return self;
}

+ (instancetype)control
{
    return [[AKRandomControl alloc] init];
}

- (void)setOptionalLowerBound:(AKParameter *)lowerBound {
    _lowerBound = lowerBound;
}
- (void)setOptionalUpperBound:(AKParameter *)upperBound {
    _upperBound = upperBound;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ random AKControl(%@), AKControl(%@)",
            self,
            _lowerBound,
            _upperBound];
}

@end
