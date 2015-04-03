//
//  AKAudioOutputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKPlotView.h"

/// Plot the raw samples of the audio output to the DAC
IB_DESIGNABLE
@interface AKAudioOutputPlot : AKPlotView

#if TARGET_OS_IPHONE
@property IBInspectable UIColor *lineColor;
#else
@property IBInspectable NSColor *lineColor;
#endif
@property IBInspectable CGFloat lineWidth;

@end
