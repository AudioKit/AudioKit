//
//  AKAudioInputFFTPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
/// Plots the FFT of the audio input
IB_DESIGNABLE
@interface AKAudioInputFFTPlot : UIView
@property IBInspectable UIColor *lineColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// Plots the FFT of the audio input
IB_DESIGNABLE
@interface AKAudioInputFFTPlot : NSView
@property IBInspectable NSColor *lineColor;
#endif

@property IBInspectable CGFloat lineWidth;

@end
