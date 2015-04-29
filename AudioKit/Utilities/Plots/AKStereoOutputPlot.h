//
//  AKStereoOutputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plot the raw samples of the audio output to the DAC as left and right signals
NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface AKStereoOutputPlot : AKPlotView

#if TARGET_OS_IPHONE
@property IBInspectable UIColor *leftLineColor, *rightLineColor;
#else
@property IBInspectable NSColor *leftLineColor, *rightLineColor;
#endif

@property IBInspectable CGFloat lineWidth;

@end
NS_ASSUME_NONNULL_END
