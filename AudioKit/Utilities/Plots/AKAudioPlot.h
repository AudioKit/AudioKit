//
//  AKAudioPlot.h
//  AudioKit
//
//  Created by Stéphane Peter on 4/27/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKPlotView.h"

@class CsoundObj;

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE
@interface AKAudioPlot : AKPlotView

// Can't simply use AKColor here as Xcode fails to interpret it correctly in IB
#if TARGET_OS_IPHONE
@property IBInspectable UIColor *lineColor;
#else
@property IBInspectable NSColor *lineColor;
#endif
@property IBInspectable CGFloat lineWidth;

- (NSData *)bufferWithCsound:(CsoundObj *)cs;

@end
NS_ASSUME_NONNULL_END