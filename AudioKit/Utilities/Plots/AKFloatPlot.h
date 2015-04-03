//
//  AKFloatPlot.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 3/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plots the floating point value given a minimum and maximum
IB_DESIGNABLE
@interface AKFloatPlot : AKPlotView

@property IBInspectable AKColor *lineColor;

@property IBInspectable float minimum;
@property IBInspectable float maximum;

@property IBInspectable CGFloat lineWidth;

- (instancetype)initWithMinimum:(float)minimum maximum:(float)maximum;

- (void)updateWithValue:(float)value;

@end
