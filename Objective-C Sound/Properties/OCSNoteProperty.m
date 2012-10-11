//
//  OCSNoteProperty.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNoteProperty.h"
#import "OCSNote.h"

@interface OCSNoteProperty() {
    OCSNote *myNote;
    int pValue;
}
@end

@implementation OCSNoteProperty

@synthesize pValue;
@synthesize note=myNote;

- (id) init
{
    self = [super init];
    if (self) {
        pValue = 0;
    }
    return self;
}

- (void)setValue:(Float32)value {
    currentValue = value;
    if (minimumValue && value < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"%@ out of bounds, assigning to minimum", self);
    }
    if (maximumValue && value > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"%@ out of bounds, assigning to maximum", self);
    }
    [myNote updateProperties];
}

@end
