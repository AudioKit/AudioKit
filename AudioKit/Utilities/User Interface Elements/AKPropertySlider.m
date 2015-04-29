//
//  AKPropertySLider.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPropertySlider.h"
#import "AKFoundation.h"
#import "AKTools.h"

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

- (void)setProperty:(AKParameter *)property
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
    
    [property addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    
#if TARGET_OS_IPHONE
    [self addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
#elif TARGET_OS_MAC
    [self setAction:@selector(changed:)];
    [self setTarget:self];
#endif
    
}

- (void)changed:(AKPropertySlider *)sender
{
    [AKTools setProperty:_property withSlider:sender];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"value"]) {
        [AKTools setSlider:self withProperty:_property];
    } else {
        [NSException raise:@"Unexpected Keypath" format:@"%@", keyPath];
    }
    
}

@end
