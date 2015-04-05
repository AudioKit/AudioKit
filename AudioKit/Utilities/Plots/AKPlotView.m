//
//  AKPlotView.m
//  AudioKit
//
//  Created by Stéphane Peter on 4/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"
#import "AKFoundation.h"

@implementation AKPlotView

- (void)defaultValues
{
    NSAssert(nil, @"You must override defaultValues in your subclass.");
}


#if !TARGET_INTERFACE_BUILDER // Don't do AKManager binding from within IB
# if TARGET_OS_IPHONE
- (void)didMoveToSuperview
# elif TARGET_OS_MAC
- (void)viewDidMoveToSuperview
# endif
{
    // Some of the subclasses don't implement the CsoundBinding protocol
    if (![self respondsToSelector:@selector(setup:)])
        return;
    
    if (self.superview) {
        [AKManager addBinding:self];
    } else {
        [AKManager removeBinding:self];
    }
}
#endif

- (void)updateUI {
#if TARGET_OS_IPHONE
    [self setNeedsDisplay];
#elif TARGET_OS_MAC
    [self setNeedsDisplay:YES];
#endif
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultValues];
    }
    return self;
}

// Needed to properly load from nib or storyboard
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultValues];
    }
    return self;
}

#if !TARGET_INTERFACE_BUILDER
- (void)dealloc
{
    if ([self respondsToSelector:@selector(setup:)])
        [AKManager removeBinding:self];
}
#endif

@end
