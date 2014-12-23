//
//  AKRandomControl.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's random:
//  http://www.csounds.com/manual/html/random.html
//

#import "AKRandomControl.h"
#import "AKManager.h"

@implementation AKRandomControl

- (instancetype)initWithLowerBound:(AKControl *)lowerBound
                        upperBound:(AKControl *)upperBound
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

- (void)setOptionalLowerBound:(AKControl *)lowerBound {
    _lowerBound = lowerBound;
}
- (void)setOptionalUpperBound:(AKControl *)upperBound {
    _upperBound = upperBound;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ random %@, %@",
            self,
            _lowerBound,
            _upperBound];
}

@end
