//
//  AKPlotView.h
//  AudioKit
//
//  Created by Stéphane Peter on 4/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKCompatibility.h"

// Base class for all plot views

#if TARGET_OS_IPHONE
@import UIKit;

@interface AKPlotView : UIView
- (void)defaultValues;
- (void)updateUI;
@end

#define AKColor UIColor
#define AKBezierPath UIBezierPath

#define AK_DEVICE_ORIGIN (-1)

#elif TARGET_OS_MAC
@import Cocoa;

NS_ASSUME_NONNULL_BEGIN
@interface AKPlotView : NSView
- (void)defaultValues;
- (void)updateUI;

@property (nonatomic,strong,nullable) IBInspectable NSColor *backgroundColor;

@end
NS_ASSUME_NONNULL_END

#define AKColor NSColor
#define AKBezierPath NSBezierPath

#define AK_DEVICE_ORIGIN (1)

#endif


// Commonly used macro in the plot classes
#define AK_CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
