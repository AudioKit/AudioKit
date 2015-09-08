//
//  AKPropertyLabel.m
//  AudioKitPlayground
//
//  Created by Aurelius Prochazka on 3/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPropertyLabel.h"
#import "AKFoundation.h"

@implementation AKPropertyLabel


- (void)setProperty:(AKParameter *)property
{
    _property = property;
    [self.property addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
    [self setNeedsDisplay];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    [self setNeedsDisplay];
}


#if TARGET_OS_IPHONE
#define text text
#elif TARGET_OS_MAC
#define text stringValue
#endif

- (void)setNeedsDisplay
{
    if ([_property isKindOfClass:[AKInstrumentProperty class]])
    {
        AKInstrumentProperty *p = (AKInstrumentProperty *)_property;
        self.text = [NSString stringWithFormat:@"%g", p.value];
    }
    else if ([_property isKindOfClass:[AKNoteProperty class]])
    {
        AKNoteProperty *p = (AKNoteProperty *)_property;
        self.text = [NSString stringWithFormat:@"%g", p.value];
    }
    
    [super setNeedsDisplay];
}

@end
