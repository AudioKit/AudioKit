//
//  AKAudioFFTPlot.h
//  AudioKit
//
//  Created by Stéphane Peter on 4/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKPlotView.h"

@class CsoundObj;

NS_ASSUME_NONNULL_BEGIN
@interface AKAudioFFTPlot : AKPlotView

#if TARGET_OS_IPHONE
@property IBInspectable UIColor *lineColor;
#else
@property IBInspectable NSColor *lineColor;
#endif
@property IBInspectable CGFloat lineWidth;

- (NSMutableData *)bufferWithCsound:(CsoundObj *)cs;

@end
NS_ASSUME_NONNULL_END
