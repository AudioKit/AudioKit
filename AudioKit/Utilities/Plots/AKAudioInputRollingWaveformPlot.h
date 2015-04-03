//
//  AKAudioInputRollingWaveformPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
/// A Rolling Waveform for of the audio input
IB_DESIGNABLE
@interface AKAudioInputRollingWaveformPlot : UIView
@property (nonatomic) IBInspectable UIColor *plotColor;
#elif TARGET_OS_MAC
@import Cocoa;
/// A Rolling Waveform for of the audio input
IB_DESIGNABLE
@interface AKAudioInputRollingWaveformPlot : NSView
@property (nonatomic) IBInspectable NSColor *plotColor;
#endif

@end
