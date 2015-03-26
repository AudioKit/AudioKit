//
//  AKAudioOutputRollingWaveformPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "CsoundObj.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
/// A Rolling Waveform for of the audio output
@interface AKAudioOutputRollingWaveformPlot : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
/// A Rolling Waveform for of the audio output
@interface AKAudioOutputRollingWaveformPlot : NSView <CsoundBinding>
#endif

@end
