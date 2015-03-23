//
//  AKPropertySLider.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPropertySlider.h"
#import "AKFoundation.h"

@implementation AKPropertySlider

#if TARGET_OS_IPHONE
#define val value
#elif TARGET_OS_MAC
#define val doubleValue
#endif

#if TARGET_OS_IPHONE
#define max maximumValue
#elif TARGET_OS_MAC
#define max maxValue
#endif

#if TARGET_OS_IPHONE
#define min minimumValue
#elif TARGET_OS_MAC
#define min minValue
#endif

- (void)setProperty:(id)property
{
    if ([property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)property;
        self.min = p.minimum;
        self.max = p.maximum;
        self.val = p.value;
        _property = p;
    }
    else if ([property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)property;
        self.min = p.minimum;
        self.max = p.maximum;
        self.val = p.value;
        _property = p;
    }
}

#if TARGET_OS_IPHONE
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
#elif TARGET_OS_MAC

// TODO

#endif

@end
