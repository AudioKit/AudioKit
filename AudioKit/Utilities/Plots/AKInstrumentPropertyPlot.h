//
//  AKInstrumentPropertyPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrumentProperty.h"

#if TARGET_OS_IPHONE
@import UIKit;
/// Plot of the given instrument property
IB_DESIGNABLE
@interface AKInstrumentPropertyPlot : UIView
@property IBInspectable UIColor *lineColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// Plot of the given instrument property
IB_DESIGNABLE
@interface AKInstrumentPropertyPlot : NSView
@property IBInspectable NSColor *lineColor;
#endif

@property AKInstrumentProperty *property;
@property AKInstrumentProperty *plottedValue;

@property IBInspectable CGFloat lineWidth;

- (instancetype)initWithProperty:(AKInstrumentProperty *)property;

@end
