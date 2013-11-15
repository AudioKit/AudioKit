//
//  OCSRandomControl.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 9/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSRandomControl.h"

@interface OCSRandomControl() {
    OCSControl *min;
    OCSControl *max;
}
@end

@implementation OCSRandomControl

-(instancetype)initWithMinimum:(OCSControl *)minimum
             maximum:(OCSControl *)maximum
{
    self = [super initWithString:[self operationName]];
    if (self) {
        min = minimum;
        max = maximum;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"%@ random %@, %@", self, min, max];
}

@end
