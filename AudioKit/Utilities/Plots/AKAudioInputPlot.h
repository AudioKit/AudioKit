//
//  AKAudioInputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#if TARGET_OS_IPHONE
@import UIKit;
/// Plots the incoming audio source signal, usually the microphone
IB_DESIGNABLE
@interface AKAudioInputPlot : UIView
@property IBInspectable UIColor *lineColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// Plots the incoming audio source signal, usually the microphone
IB_DESIGNABLE
@interface AKAudioInputPlot : NSView
@property IBInspectable NSColor *lineColor;
#endif

@property IBInspectable CGFloat lineWidth;

@end
