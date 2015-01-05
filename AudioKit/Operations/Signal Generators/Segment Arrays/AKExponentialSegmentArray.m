//
//  AKExponentialSegmentArray.m
//  AKLinearSegmentArray
//
//  Created by Aurelius Prochazka on 1/4/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKExponentialSegmentArray.h"

@implementation AKExponentialSegmentArray
{
    AKConstant *value1;
    NSMutableArray *segments;
}

- (instancetype)initWithInitialValue:(AKConstant *)initialValue
                         targetValue:(AKConstant *)targetValue
                       afterDuration:(AKConstant *)duration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        value1      = initialValue;
        segments = [[NSMutableArray alloc] init];
        [self addValue:targetValue afterDuration:duration];
    }
    
    return self;
}

- (void)addValue:(AKConstant *)value
   afterDuration:(AKConstant *)duration;
{
    [segments addObject:duration];
    [segments addObject:value];
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ expseg %@, %@",
            self,
            value1,
            [segments componentsJoinedByString:@", "]];
}

@end