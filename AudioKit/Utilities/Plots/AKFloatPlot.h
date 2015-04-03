//
//  AKFloatPlot.h
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 3/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
/// Plots the floating point value given a minimum and maximum
IB_DESIGNABLE
@interface AKFloatPlot : UIView
@property IBInspectable UIColor *lineColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// Plots the floating point value given a minimum and maximum
IB_DESIGNABLE
@interface AKFloatPlot : NSView
@property IBInspectable NSColor *lineColor;
#endif

@property IBInspectable float minimum;
@property IBInspectable float maximum;

@property IBInspectable CGFloat lineWidth;

- (instancetype)initWithMinimum:(float)minimum maximum:(float)maximum;

- (void)updateWithValue:(float)value;

@end
