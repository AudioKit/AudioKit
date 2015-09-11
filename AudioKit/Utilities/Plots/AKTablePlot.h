//
//  AKTablePlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/9/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTable.h"
#import "AKPlotView.h"

/// Plots the values of the given table
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface AKTablePlot : AKPlotView

#if TARGET_OS_IPHONE
@property IBInspectable UIColor *lineColor;
#else
@property IBInspectable NSColor *lineColor;
#endif
@property IBInspectable CGFloat lineWidth;

/// Defaults to 0.9
@property IBInspectable float scalingFactor;

@property (nonatomic,nullable) AKTable *table;

@end
NS_ASSUME_NONNULL_END
