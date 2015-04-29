//
//  AKFloatPlot.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 3/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plots the floating point value given a minimum and maximum
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface AKFloatPlot : AKPlotView

#if TARGET_OS_IPHONE
@property IBInspectable UIColor *lineColor;
#else
@property IBInspectable NSColor *lineColor;
#endif

@property IBInspectable float minimum;
@property IBInspectable float maximum;

@property IBInspectable CGFloat lineWidth;

- (instancetype)initWithMinimum:(float)minimum maximum:(float)maximum;

- (void)updateWithValue:(float)value;

@end
NS_ASSUME_NONNULL_END
