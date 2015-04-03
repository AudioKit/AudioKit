//
//  AKAudioInputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plots the incoming audio source signal, usually the microphone
IB_DESIGNABLE
@interface AKAudioInputPlot : AKPlotView

// Can't simply use AKColor here as Xcode fails to interpret it correctly in IB
#if TARGET_OS_IPHONE
@property IBInspectable UIColor *lineColor;
#else
@property IBInspectable NSColor *lineColor;
#endif
@property IBInspectable CGFloat lineWidth;

@end
