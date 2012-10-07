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
}
@end

@implementation OCSNoteProperty

- (id) initWithNote:(OCSNote *)note
       initialValue:(float)initialValue
           minValue:(float)minValue
           maxValue:(float)maxValue
{
    self = [super initWithValue:initialValue minValue:minValue maxValue:maxValue];
    if (self) {
        myNote = note;
    }
    return self;
}

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
    // AOP This is the automatic playback of the note that Adam doesn't like
    [myNote play];
}

@end
