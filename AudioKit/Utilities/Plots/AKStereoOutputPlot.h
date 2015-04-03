//
//  AKStereoOutputPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
/// Plot the raw samples of the audio output to the DAC as left and right signals
IB_DESIGNABLE
@interface AKStereoOutputPlot : UIView
@property IBInspectable UIColor *leftLineColor, *rightLineColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// Plot the raw samples of the audio output to the DAC as keft and right signals
IB_DESIGNABLE
@interface AKStereoOutputPlot : NSView
@property IBInspectable NSColor *leftLineColor, *rightLineColor;
#endif

@property IBInspectable CGFloat lineWidth;

@end
