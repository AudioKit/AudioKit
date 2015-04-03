//
//  AKAudioOutputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
/// Plot the raw samples of the audio output to the DAC
IB_DESIGNABLE
@interface AKAudioOutputPlot : UIView
@property IBInspectable UIColor *lineColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// Plot the raw samples of the audio output to the DAC
IB_DESIGNABLE
@interface AKAudioOutputPlot : NSView
@property IBInspectable NSColor *lineColor;
#endif

@property IBInspectable CGFloat lineWidth;

@end
