//
//  OCSNoteProperty.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNoteProperty.h"

@implementation OCSNoteProperty

- (void)setValue:(Float32)value {
    currentValue = value;
    if (value < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", [self output]);
    }
    if (value > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"%@ out of bounds, assigning to maximum", [self output]);
    }
}

@end
