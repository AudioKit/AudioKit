//
//  AKPlotView.h
//  AudioKit
//
//  Created by Stéphane Peter on 4/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <TargetConditionals.h>

// Base class for all plot views

#if TARGET_OS_IPHONE
@import UIKit;

@interface AKPlotView : UIView

@end

#define AKColor UIColor

#elif TARGET_OS_MAC
@import Cocoa;

@interface AKPlotView : NSView

@end

#define AKColor NSColor

#endif

// Commonly used macro in the plot classes
#define AK_CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
