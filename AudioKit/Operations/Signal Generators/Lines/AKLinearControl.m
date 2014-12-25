//
//  AKLinearControl.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's line:
//  http://www.csounds.com/manual/html/line.html
//

#import "AKLinearControl.h"
#import "AKManager.h"

@implementation AKLinearControl

- (instancetype)initWithFirstPoint:(AKConstant *)firstPoint
                       secondPoint:(AKConstant *)secondPoint
             durationBetweenPoints:(AKConstant *)durationBetweenPoints
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _firstPoint = firstPoint;
        _secondPoint = secondPoint;
        _durationBetweenPoints = durationBetweenPoints;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _firstPoint = akp(0);
        _secondPoint = akp(1);
        _durationBetweenPoints = akp(1);
    }
    return self;
}

+ (instancetype)control
{
    return [[AKLinearControl alloc] init];
}

- (void)setOptionalFirstPoint:(AKConstant *)firstPoint {
    _firstPoint = firstPoint;
}
- (void)setOptionalSecondPoint:(AKConstant *)secondPoint {
    _secondPoint = secondPoint;
}
- (void)setOptionalDurationBetweenPoints:(AKConstant *)durationBetweenPoints {
    _durationBetweenPoints = durationBetweenPoints;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ line ", self];

    [csdString appendFormat:@"%@, ", _firstPoint];
    
    [csdString appendFormat:@"%@, ", _durationBetweenPoints];
    
    [csdString appendFormat:@"%@", _secondPoint];
    return csdString;
}

@end
