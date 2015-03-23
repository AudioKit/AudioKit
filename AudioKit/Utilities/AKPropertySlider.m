//
//  AKNotePropertySLider.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPropertySlider.h"

@implementation AKPropertySlider

- (void)setProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        self.minimumValue = p.minimum;
        self.maximumValue = p.maximum;
        self.value = p.value;
        _property = p;
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        self.minimumValue = p.minimum;
        self.maximumValue = p.maximum;
        self.value = p.value;
        _property = p;
    }
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([_property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)_property;
        p.value = self.value;
    }
    else if ([_property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)_property;
        p.value = self.value;
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

@end
